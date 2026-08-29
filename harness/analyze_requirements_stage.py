#!/usr/bin/env python3
"""Read-only Opt107 requirements-stage timeline extractor.

The script reads immutable run artifacts and writes only JSON to stdout.  It
does not inspect the delivered project workspace and does not infer timings
from file mtimes.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path
from typing import Any


REQUIRED_FILES = (
    "timing-distribution.json",
    "agent-events.jsonl",
    "failures.json",
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def item_number(item_id: str) -> int:
    match = re.fullmatch(r"item_(\d+)", item_id)
    if not match:
        raise ValueError(f"unexpected item id: {item_id}")
    return int(match.group(1))


def completed_items(events_path: Path) -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []
    with events_path.open(encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, 1):
            try:
                event = json.loads(line)
            except json.JSONDecodeError as error:
                raise ValueError(f"invalid JSONL at line {line_number}: {error}") from error
            if event.get("type") != "item.completed":
                continue
            item = event.get("item")
            if isinstance(item, dict) and isinstance(item.get("id"), str):
                items.append(item)
    return items


def classify(command: str) -> tuple[str, str]:
    if "SKILL.md" in command and "sed -n" in command:
        return "entry_authority_read", "required entrypoint read"
    if "domainry-development-context.py" in command:
        return "resolver", "fresh requirements_entry and TODO/stage initialization"
    if "domainry-cli version --json" in command:
        return "cli_identity", "required embedded CLI identity"
    if "requirements-and-domain-truth.md" in command:
        return "requirements_authority_read", "required authority + PRD template + source authority"
    if "domain-truth-and-settlement.md" in command:
        return "conditional_authority_read", "triggered by settlement/calculation requirements"
    if "sed -n '1,95p' .domainry/development" in command:
        return "todo_read", "current requirements/domain-truth TODO scope"
    if " sync" in command:
        return "gate_sync", "valid but foldable into atomic finalize"
    if " list --stage requirements" in command:
        return "gate_list", "valid but foldable into atomic finalize"
    if " list --stage domain_truth_design" in command:
        return "gate_list", "valid but foldable into atomic finalize"
    if " attach --gate-id" in command:
        return "gate_attach_batch", "15 repeated attachments in one shell loop"
    if "stage-close --stage requirements" in command:
        return "invalid_stage_close", "conflicts with TODO atomic-transition contract"
    if command.rstrip().endswith(" resume\"") or command.rstrip().endswith(" resume'"):
        return "resume", "returned repair_required after requirements was prematurely closed"
    if "development-gates" in command and "resume.json" in command:
        return "resume_packet_read", "packet incorrectly disclosed apply authority before atomic transition"
    if "references/development-guide.md" in command and "wc -l" in command:
        return "premature_later_authority_read", "read four later-stage references before model opened"
    if "references/development-guide.md" in command:
        return "duplicate_later_authority_read", "duplicate whole/subset guide read before model opened"
    if "references/backend-model.md" in command:
        return "duplicate_later_authority_read", "duplicate backend-model read before model opened"
    if "git -C" in command and "sed -n '98,250p'" in command:
        return "premature_todo_model_read", "inspected later TODO sections before model opened"
    if "stage-transition --from-stage requirements --to-stage model" in command:
        return "stage_transition", "failed if requirements attempt closed; later retry succeeds"
    if "status --require-complete" in command:
        return "redundant_status", "diagnostic after known transition-contract failure"
    if "stage-open --stage requirements --kind repair" in command:
        return "repair_open", "workaround forced by invalid close/resume sequence"
    return "other", ""


def active_ms(output: str) -> int | None:
    matches = re.findall(r"CLI_ACTIVE_MS=(\d+)", output)
    return int(matches[-1]) if matches else None


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("run_dir", type=Path)
    args = parser.parse_args()
    run_dir = args.run_dir.resolve()
    missing = [name for name in REQUIRED_FILES if not (run_dir / name).is_file()]
    if missing:
        raise SystemExit(f"missing required run files: {', '.join(missing)}")

    timing = json.loads((run_dir / "timing-distribution.json").read_text(encoding="utf-8"))
    failures = json.loads((run_dir / "failures.json").read_text(encoding="utf-8"))
    items = completed_items(run_dir / "agent-events.jsonl")

    boundary_item: int | None = None
    for item in items:
        command = str(item.get("command", ""))
        output = str(item.get("aggregated_output", ""))
        if (
            item.get("type") == "command_execution"
            and "stage-transition --from-stage requirements --to-stage model" in command
            and item.get("exit_code") == 0
            and '"state":"transitioned"' in output
        ):
            boundary_item = item_number(item["id"])
            break
    if boundary_item is None:
        raise SystemExit("successful requirements -> model boundary not found")

    timeline: list[dict[str, Any]] = []
    commands = 0
    file_changes = 0
    premature_reads = 0
    duplicate_reads = 0
    failed_commands = 0
    for item in items:
        number = item_number(item["id"])
        if number > boundary_item:
            continue
        item_type = item.get("type")
        if item_type == "command_execution":
            commands += 1
            command = str(item.get("command", ""))
            category, finding = classify(command)
            if category.startswith("premature_"):
                premature_reads += 1
            if category.startswith("duplicate_"):
                duplicate_reads += 1
            if item.get("exit_code") not in (0, None):
                failed_commands += 1
            timeline.append({
                "item": item["id"],
                "type": item_type,
                "category": category,
                "exit_code": item.get("exit_code"),
                "cli_active_ms_from_wrapper": active_ms(str(item.get("aggregated_output", ""))),
                "finding": finding,
                "command": command,
            })
        elif item_type == "file_change":
            file_changes += 1
            timeline.append({
                "item": item["id"],
                "type": item_type,
                "category": "requirements_authoring",
                "paths": [change.get("path") for change in item.get("changes", [])],
            })

    stage = timing["stages"]["requirements"]
    requirements_failures = [row for row in failures if row.get("stage") == "requirements"]
    result = {
        "contract_version": "domainry-eval-requirements-timeline-v1",
        "run_id": timing["run_id"],
        "baseline_eligible": timing["baseline_eligible"],
        "source_files": {
            name: {
                "path": str(run_dir / name),
                "sha256": sha256(run_dir / name),
                "bytes": (run_dir / name).stat().st_size,
            }
            for name in REQUIRED_FILES
        },
        "boundary": {
            "successful_transition_item": f"item_{boundary_item}",
            "requirements_settled_epoch_ms": timing["milestones"]["requirements_settled_epoch_ms"],
        },
        "timing": {
            "wall_ms": stage["wall_ms"],
            "initial_ms": stage["initial_ms"],
            "repair_ms": stage["repair_ms"],
            "cli_active_ms": stage["cli_active_ms"],
            "orchestration_idle_ms": stage["orchestration_idle_ms"],
            "inter_attempt_unallocated_ms": timing["unallocated"]["requirements_inter_attempt_ms"],
        },
        "inventory": {
            "completed_command_items_through_boundary": commands,
            "file_change_items_through_boundary": file_changes,
            "failed_command_items_through_boundary": failed_commands,
            "premature_later_stage_reads": premature_reads,
            "duplicate_later_stage_reads": duplicate_reads,
            "attach_operations_in_item_13": 15,
        },
        "requirements_failures": requirements_failures,
        "timeline": timeline,
    }
    print(json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
