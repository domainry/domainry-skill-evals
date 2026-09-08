#!/usr/bin/env python3
"""Run Claude Code as the evaluated Agent and emit a Codex-compatible event stream.

The driver launches ``claude_agent.py --model <model> <prompt>`` inside the
isolated environment it prepared (``HOME``, ``CODEX_HOME``, ``TMPDIR``).
This adapter:

* points ``CLAUDE_CONFIG_DIR`` at the isolated ``CODEX_HOME`` so the Agent sees
  exactly the frozen candidate under ``skills/<skill_name>`` and nothing else;
* restores the API credentials the driver staged as ``CODEX_HOME/auth.json``
  (a JSON object of ``ANTHROPIC_*`` environment variables) into the child
  environment only, never onto disk elsewhere;
* translates ``claude -p --output-format stream-json`` events into the Codex
  ``thread.started`` / ``item.started`` / ``item.completed`` /
  ``turn.completed`` shapes the driver already understands, with cumulative
  token usage.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys

EXIT_CODE_PATTERN = re.compile(r"^\s*Exit code (\d+)\b")


def emit(event: dict) -> None:
    sys.stdout.write(json.dumps(event, ensure_ascii=False) + "\n")
    sys.stdout.flush()


def load_staged_auth(codex_home: str) -> dict[str, str]:
    path = os.path.join(codex_home, "auth.json")
    try:
        with open(path, encoding="utf-8") as stream:
            document = json.load(stream)
    except (OSError, json.JSONDecodeError):
        return {}
    return {
        key: str(value)
        for key, value in document.items()
        if isinstance(key, str) and key.startswith("ANTHROPIC_") and isinstance(value, str)
    }


def tool_result_text(content: object) -> str:
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for block in content:
            if isinstance(block, dict) and block.get("type") == "text":
                parts.append(str(block.get("text", "")))
        return "\n".join(parts)
    return ""


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", required=True)
    parser.add_argument("--max-turns", type=int, default=0)
    parser.add_argument("prompt")
    arguments = parser.parse_args()

    codex_home = os.environ.get("CODEX_HOME")
    if not codex_home or not os.path.isdir(os.path.join(codex_home, "skills")):
        sys.stderr.write("claude_agent: CODEX_HOME with a skills directory is required\n")
        return 64
    environment = dict(os.environ)
    environment["CLAUDE_CONFIG_DIR"] = codex_home
    environment.update(load_staged_auth(codex_home))
    for key in ("CLAUDECODE", "CLAUDE_CODE_ENTRYPOINT", "CLAUDE_CODE_SESSION_ID"):
        environment.pop(key, None)
    environment.setdefault("DISABLE_AUTOUPDATER", "1")
    environment.setdefault("DISABLE_TELEMETRY", "1")

    command = [
        "claude", "-p", arguments.prompt, "--model", arguments.model,
        "--output-format", "stream-json", "--verbose", "--dangerously-skip-permissions",
    ]
    if arguments.max_turns > 0:
        command += ["--max-turns", str(arguments.max_turns)]
    process = subprocess.Popen(
        command, env=environment, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
        stderr=sys.stderr, text=True, bufsize=1,
    )
    assert process.stdout is not None

    usage_seen: set[str] = set()
    totals = {"input": 0, "cached": 0, "output": 0, "reasoning": 0}
    open_commands: dict[str, str] = {}
    session_announced = False

    def announce(session_id: object) -> None:
        nonlocal session_announced
        if session_announced or not isinstance(session_id, str) or not session_id:
            return
        session_announced = True
        emit({"type": "thread.started", "thread_id": session_id})

    def usage_event() -> dict:
        return {"type": "turn.completed", "usage": {
            "input_tokens": totals["input"], "cached_input_tokens": totals["cached"],
            "output_tokens": totals["output"], "reasoning_output_tokens": totals["reasoning"],
        }}

    for raw in process.stdout:
        raw = raw.strip()
        if not raw:
            continue
        try:
            event = json.loads(raw)
        except json.JSONDecodeError:
            continue
        kind = event.get("type")
        announce(event.get("session_id"))
        if kind == "assistant":
            message = event.get("message") or {}
            message_id = message.get("id")
            usage = message.get("usage") or {}
            if isinstance(message_id, str) and message_id not in usage_seen and usage:
                usage_seen.add(message_id)
                cached = int(usage.get("cache_read_input_tokens") or 0)
                totals["input"] += int(usage.get("input_tokens") or 0) + int(
                    usage.get("cache_creation_input_tokens") or 0) + cached
                totals["cached"] += cached
                totals["output"] += int(usage.get("output_tokens") or 0)
                emit(usage_event())
            for block in message.get("content") or []:
                if not isinstance(block, dict):
                    continue
                if block.get("type") == "text" and block.get("text"):
                    emit({"type": "item.completed", "item": {
                        "id": message_id, "type": "agent_message", "text": block["text"]}})
                elif block.get("type") == "tool_use" and block.get("name") == "Bash":
                    tool_id = str(block.get("id"))
                    command_text = str((block.get("input") or {}).get("command", ""))
                    open_commands[tool_id] = command_text
                    emit({"type": "item.started", "item": {
                        "id": tool_id, "type": "command_execution", "command": command_text,
                        "status": "in_progress"}})
        elif kind == "user":
            message = event.get("message") or {}
            for block in message.get("content") or []:
                if not isinstance(block, dict) or block.get("type") != "tool_result":
                    continue
                tool_id = str(block.get("tool_use_id"))
                if tool_id not in open_commands:
                    continue
                command_text = open_commands.pop(tool_id)
                output = tool_result_text(block.get("content"))
                result = event.get("tool_use_result") or {}
                if isinstance(result, dict) and isinstance(result.get("stdout"), str):
                    output = result["stdout"] + (("\n" + result["stderr"]) if result.get("stderr") else "")
                is_error = bool(block.get("is_error"))
                match = EXIT_CODE_PATTERN.match(tool_result_text(block.get("content")))
                exit_code = int(match.group(1)) if match else (1 if is_error else 0)
                emit({"type": "item.completed", "item": {
                    "id": tool_id, "type": "command_execution", "command": command_text,
                    "aggregated_output": output, "exit_code": exit_code,
                    "status": "failed" if exit_code else "completed"}})
        elif "total_cost_usd" in event or kind == "result":
            usage = event.get("usage") or {}
            if usage:
                cached = int(usage.get("cache_read_input_tokens") or 0)
                total_input = int(usage.get("input_tokens") or 0) + int(
                    usage.get("cache_creation_input_tokens") or 0) + cached
                if total_input >= totals["input"]:
                    totals.update(input=total_input, cached=cached,
                                  output=int(usage.get("output_tokens") or 0))
                details = usage.get("output_tokens_details") or {}
                totals["reasoning"] = int(details.get("thinking_tokens") or 0)
                emit(usage_event())
            emit({"type": "turn.completed", "usage": usage_event()["usage"],
                  "stop_reason": event.get("stop_reason"), "is_error": event.get("is_error", False)})
    code = process.wait()
    return code


if __name__ == "__main__":
    sys.exit(main())
