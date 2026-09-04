#!/usr/bin/env python3
"""Extract Builder CLI invocations from a fresh Codex JSONL event stream."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import re


COMMAND_FAMILIES = (
    (re.compile(r"\bmodel\s+capability\b"), "model_capability"),
    (re.compile(r"\bmodel\s+plan\b"), "model_plan"),
    (re.compile(r"\bapply\s+model\b"), "apply_model"),
    (re.compile(r"\bapply\s+finalize\b"), "apply_finalize"),
    (re.compile(r"\bverify\b"), "verify"),
)
CLI_MARKER = re.compile(r"(?:domainry-cli|DOMAINRY_CLI)")


def family_for(command: str) -> str | None:
    if not CLI_MARKER.search(command):
        return None
    for pattern, family in COMMAND_FAMILIES:
        if pattern.search(command):
            return family
    return None


def parse_output(raw: str) -> object:
    raw = raw.strip()
    if not raw:
        return ""
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        pass
    decoder = json.JSONDecoder()
    parsed: list[tuple[int, object]] = []
    for offset, character in enumerate(raw):
        if character not in "[{":
            continue
        try:
            value, length = decoder.raw_decode(raw[offset:])
        except json.JSONDecodeError:
            continue
        parsed.append((offset + length, value))
    return max(parsed, key=lambda item: item[0])[1] if parsed else raw


def extract(events_path: Path) -> list[dict[str, object]]:
    artifacts: list[dict[str, object]] = []
    with events_path.open(encoding="utf-8") as stream:
        for line_number, line in enumerate(stream, 1):
            try:
                event = json.loads(line)
            except json.JSONDecodeError as error:
                raise ValueError(f"invalid Codex JSONL at line {line_number}: {error}") from error
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
                raise ValueError(f"Builder CLI event has no exit code at line {line_number}")
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
