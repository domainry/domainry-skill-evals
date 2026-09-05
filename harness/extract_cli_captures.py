#!/usr/bin/env python3
"""Extract Builder CLI invocations from a fresh Codex JSONL event stream."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
import shlex


CLI_MARKER = re.compile(r"(?:domainry-cli|DOMAINRY_CLI)")
SHELL_SEPARATORS = {";", "&&", "||", "|", "&"}
METADATA_ARGUMENTS = {"--help", "-h", "help", "--version", "-V", "version"}


def _is_metadata_argument(argument: str) -> bool:
    return (
        argument in METADATA_ARGUMENTS
        or argument.startswith("--help=")
        or argument.startswith("--version=")
    )


def _command_words(command: str) -> list[str]:
    """Best-effort argv extraction for direct and ``shell -lc`` events."""
    try:
        outer = shlex.split(command)
    except ValueError:
        return []
    script = command
    for flag in ("-lc", "-c"):
        if flag in outer:
            index = outer.index(flag)
            if index + 1 < len(outer):
                script = outer[index + 1]
                break
    # Codex commonly sends multi-line shell programs. Domainry scoring commands
    # are standalone lines; preserving the boundary prevents later prose or
    # commands from becoming their arguments.
    script = script.replace("\n", " ; ")
    try:
        lexer = shlex.shlex(script, posix=True, punctuation_chars=";&|")
        lexer.whitespace_split = True
        lexer.commenters = ""
        return list(lexer)
    except ValueError:
        return []


def _is_cli_executable(word: str) -> bool:
    if "=" in word:
        return False
    return Path(word).name == "domainry-cli" or word in {
        "$DOMAINRY_CLI", "${DOMAINRY_CLI}", "DOMAINRY_CLI",
    }


def _family_from_args(arguments: list[str]) -> str | None:
    if not arguments or _is_metadata_argument(arguments[0]):
        return None
    family = None
    consumed = 0
    if arguments[:2] == ["model", "capability"]:
        family, consumed = "model_capability", 2
    elif arguments[:2] == ["model", "plan"]:
        family, consumed = "model_plan", 2
    elif arguments[:2] == ["apply", "model"]:
        family, consumed = "apply_model", 2
    elif arguments[:2] == ["apply", "finalize"]:
        family, consumed = "apply_finalize", 2
    elif arguments[0] == "verify":
        family, consumed = "verify", 1
    if family is None:
        return None
    if any(_is_metadata_argument(argument) for argument in arguments[consumed:]):
        return None
    return family


def family_for(command: str) -> str | None:
    if not CLI_MARKER.search(command):
        return None
    words = _command_words(command)
    for index, word in enumerate(words):
        if not _is_cli_executable(word):
            continue
        arguments = []
        for argument in words[index + 1:]:
            if argument in SHELL_SEPARATORS:
                break
            arguments.append(argument)
        family = _family_from_args(arguments)
        if family is not None:
            return family
    return None


def _json_envelope_rank(value: dict[str, object]) -> int:
    """Prefer explicit CLI envelopes over incidental JSON log objects."""
    if isinstance(value.get("contract_version"), str):
        return 3
    if any(key in value for key in (
        "state", "issue_count", "diagnostics", "telemetry", "artifact", "error",
    )):
        return 2
    return 1


def _embedded_json_objects(raw: str) -> list[tuple[int, dict[str, object]]]:
    """Decode complete JSON objects beginning on their own output line.

    Advancing past a successfully decoded document prevents nested arrays or
    objects inside its strings from becoming candidates. Requiring the rest of
    the ending line to be whitespace also rejects fragments such as the
    ``[1]`` in a human diagnostic like ``reports[1].field``.
    """
    decoder = json.JSONDecoder()
    objects: list[tuple[int, dict[str, object]]] = []
    cursor = 0
    while cursor < len(raw):
        line_end = raw.find("\n", cursor)
        if line_end < 0:
            line_end = len(raw)
        start = cursor
        while start < line_end and raw[start] in " \t\r":
            start += 1
        if start < len(raw) and raw[start] == "{":
            try:
                value, length = decoder.raw_decode(raw[start:])
            except json.JSONDecodeError:
                pass
            else:
                end = start + length
                ending_line = raw.find("\n", end)
                if ending_line < 0:
                    ending_line = len(raw)
                if not raw[end:ending_line].strip() and isinstance(value, dict):
                    objects.append((start, value))
                    cursor = end
                    if cursor < len(raw) and raw[cursor] == "\n":
                        cursor += 1
                    continue
        cursor = line_end + 1
    return objects


def parse_output(raw: str) -> object:
    raw = raw.strip()
    if not raw:
        return ""
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        pass
    parsed = _embedded_json_objects(raw)
    if not parsed:
        return raw
    # Position is only a tie-breaker between equally authoritative envelopes;
    # it can never make a later JSON fragment outrank a contract envelope.
    return max(parsed, key=lambda item: (_json_envelope_rank(item[1]), item[0]))[1]


def extract(events_path: Path, *, strict: bool = True) -> list[dict[str, object]]:
    artifacts: list[dict[str, object]] = []
    with events_path.open(encoding="utf-8") as stream:
        for line_number, line in enumerate(stream, 1):
            try:
                event = json.loads(line)
            except json.JSONDecodeError as error:
                if strict:
                    raise ValueError(f"invalid Codex JSONL at line {line_number}: {error}") from error
                continue
            if event.get("type") != "item.completed":
                continue
            item = event.get("item")
            if not isinstance(item, dict) or item.get("type") != "command_execution":
                continue
            command = item.get("command")
            family = family_for(command) if isinstance(command, str) else None
            if family is None:
                continue
            exit_code = item.get("exit_code")
            if not isinstance(exit_code, int):
                if strict:
                    raise ValueError(f"Builder CLI event has no exit code at line {line_number}")
                continue
            raw = item.get("aggregated_output", "")
            artifacts.append({
                "family": family,
                "command": command,
                "exit_code": exit_code,
                "output": parse_output(raw if isinstance(raw, str) else str(raw)),
                "raw_output": raw,
                "event_item_id": item.get("id"),
                "event_line": line_number,
            })
    return artifacts


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("events", type=Path)
    parser.add_argument("run_dir", type=Path)
    arguments = parser.parse_args()
    output_dir = arguments.run_dir / "cli"
    output_dir.mkdir(parents=True, exist_ok=True)
    if any(output_dir.iterdir()):
        raise SystemExit(f"refusing to overwrite non-empty capture directory: {output_dir}")
    artifacts = extract(arguments.events)
    for index, artifact in enumerate(artifacts, 1):
        path = output_dir / f"{index:03d}-{artifact['family']}.json"
        path.write_text(json.dumps(artifact, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({
        "contract_version": "domainry-codex-cli-capture-v1",
        "captured": len(artifacts),
        "families": [artifact["family"] for artifact in artifacts],
    }, separators=(",", ":")))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
