import importlib.util
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "extract_cli_captures", ROOT / "harness/extract_cli_captures.py")
MOD = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MOD)


def completed(command, output, exit_code=0):
    return json.dumps({"type": "item.completed", "item": {
        "id": "item_1", "type": "command_execution", "command": command,
        "aggregated_output": output, "exit_code": exit_code,
    }})


def test_extracts_only_exact_builder_command_families(tmp_path):
    events = tmp_path / "events.jsonl"
    events.write_text("\n".join([
        completed("sed -n '1,20p' SKILL.md", "domainry-cli model plan"),
        completed('"$DOMAINRY_CLI" model plan --json --project .', '{"state":"planned"}'),
        completed('/candidate/bin/domainry-cli apply model --json --project .',
                  'progress\n{"state":"applied"}'),
    ]) + "\n")
    artifacts = MOD.extract(events)
    assert [row["family"] for row in artifacts] == ["model_plan", "apply_model"]
    assert artifacts[0]["output"] == {"state": "planned"}
    assert artifacts[1]["output"] == {"state": "applied"}


def test_failed_attempt_is_preserved(tmp_path):
    events = tmp_path / "events.jsonl"
    events.write_text(completed(
        'DOMAINRY_CLI=/candidate/domainry-cli; "$DOMAINRY_CLI" verify --json --project .',
        '{"state":"repair_required"}', 1) + "\n")
    artifact = MOD.extract(events)[0]
    assert artifact["family"] == "verify"
    assert artifact["exit_code"] == 1
