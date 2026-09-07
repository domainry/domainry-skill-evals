import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCHEMAS = ROOT / "docs/schemas"


def test_output_schemas_are_valid_json_with_unique_ids():
    documents = [json.loads(path.read_text()) for path in sorted(SCHEMAS.glob("*.json"))]
    ids = [document["$id"] for document in documents]
    assert len(documents) == 9
    assert len(ids) == len(set(ids))
    assert "domainry-eval-run-lifecycle-v1" in ids
    assert "domainry-business-flow-evidence-v1" in ids
    assert "domainry-bf06-evaluator-certificates-v1" in ids
    assert "domainry-m1-evaluator-result-v3" in ids
    assert "domainry-builder-eval-v3" in ids
    assert "domainry-eval-freeze-manifest-v1" in ids
    assert "domainry-eval-progress-v1" in ids
    assert "domainry-eval-event-observations-v1" in ids
    assert "domainry-eval-stage-timing-v1" in ids


def test_lifecycle_schema_contains_every_budget_terminal_state():
    lifecycle = json.loads((SCHEMAS / "run-lifecycle-v1.schema.json").read_text())
    states = set(lifecycle["properties"]["state"]["enum"])
    assert {
        "baseline_first_scoring_failure",
        "baseline_first_command_failure",
        "budget_exhausted_wall_clock",
        "budget_exhausted_tokens",
        "budget_exhausted_cli_invocations",
        "budget_exhausted_cli_retries",
        "invalid_agent_session_context",
        "environment_invalid_candidate_drift",
        "environment_invalid_freeze_drift",
        "environment_invalid_auth_cleanup",
        "environment_invalid_auth_sanitization",
        "environment_invalid_service_drift",
        "flow_evidence_conflict",
        "flow_evidence_archive_drift",
    } <= states


def test_output_schemas_expose_independent_diagnostics_and_token_breakdown():
    lifecycle = json.loads((SCHEMAS / "run-lifecycle-v1.schema.json").read_text())
    progress = json.loads((SCHEMAS / "progress-v1.schema.json").read_text())
    scorecard = json.loads((SCHEMAS / "scorecard-v3.schema.json").read_text())
    timing = json.loads((SCHEMAS / "stage-timing-v1.schema.json").read_text())

    assert {
        "first_failure", "scoring_first_failure", "diagnostic_first_failure",
        "first_scoring_failure", "command_first_failure",
    } <= lifecycle["properties"].keys()
    assert "diagnostic_cli" in lifecycle["properties"]
    assert {"checkpoint", "checkpoint_restore"} <= lifecycle["properties"].keys()
    assert "token_usage" in lifecycle["properties"]["usage"]["properties"]
    assert "diagnostic_cli" in progress["properties"]
    assert "command_first_failure" in progress["properties"]
    assert "token_usage" in progress["properties"]["agent"]["properties"]
    assert "C2_usage_breakdown" in scorecard["properties"]
    assert "C4_diagnostic_cli" in scorecard["properties"]
    assert "diagnostic_intervals" in timing["properties"]
    freeze = json.loads((SCHEMAS / "freeze-manifest-v1.schema.json").read_text())
    assert "checkpoint" in freeze["properties"]
