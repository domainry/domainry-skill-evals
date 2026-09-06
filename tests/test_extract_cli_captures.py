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


def test_separate_stdout_stderr_are_preserved_when_provider_exposes_them(tmp_path):
    events = tmp_path / "events.jsonl"
    event = json.loads(completed(
        '/candidate/domainry-cli verify fixture --json --project .',
        'combined output', 1))
    event["item"]["stdout"] = '{"state":"failed"}\n'
    event["item"]["stderr"] = 'fixture error\n'
    events.write_text(json.dumps(event) + "\n")

    artifact = MOD.extract(events)[0]
    assert artifact["family"] == "verify_fixture"
    assert artifact["stdout"] == '{"state":"failed"}\n'
    assert artifact["stderr"] == 'fixture error\n'
    assert artifact["raw_output"] == "combined output"
    assert artifact["output_streams_status"] == "separate"


def test_tolerant_mode_salvages_valid_events_for_driver_sealing(tmp_path):
    events = tmp_path / "events.jsonl"
    events.write_text("not-json\n" + completed(
        '"$DOMAINRY_CLI" model plan --json --project .', '{"state":"planned"}') + "\n")
    artifacts = MOD.extract(events, strict=False)
    assert [row["family"] for row in artifacts] == ["model_plan"]


def test_evaluator_observations_bind_command_start_and_completion(tmp_path):
    events = tmp_path / "events.jsonl"
    command = '"$DOMAINRY_CLI" model plan --json --project .'
    started = {"type": "item.started", "item": {
        "id": "item_7", "type": "command_execution", "command": command,
    }}
    completed_event = json.loads(completed(command, '{"state":"valid"}'))
    completed_event["item"]["id"] = "item_7"
    events.write_text(
        json.dumps(started) + "\n" + json.dumps(completed_event) + "\n")
    observations = tmp_path / "agent-event-observations.jsonl"
    observations.write_text("\n".join([
        json.dumps({
            "contract_version": MOD.OBSERVATION_CONTRACT,
            "event_line": 1,
            "observed_epoch": 101.25,
        }),
        json.dumps({
            "contract_version": MOD.OBSERVATION_CONTRACT,
            "event_line": 2,
            "observed_epoch": 104.75,
        }),
    ]) + "\n")

    artifact = MOD.extract(events, observations_path=observations)[0]
    assert artifact["observed_started_epoch"] == 101.25
    assert artifact["observed_completed_epoch"] == 104.75
    assert artifact["observed_started_event_line"] == 1
    assert artifact["observed_completed_event_line"] == 2
    assert artifact["duration_seconds"] == 3.5


def test_metadata_and_help_invocations_are_not_scoring_captures(tmp_path):
    events = tmp_path / "events.jsonl"
    events.write_text("\n".join([
        completed("/candidate/domainry-cli verify --help", "usage", 0),
        completed("/candidate/domainry-cli --help", "usage", 0),
        completed("/candidate/domainry-cli --version --json", '{"version":"v1"}', 0),
        completed("/candidate/domainry-cli help verify", "usage", 0),
        completed("/candidate/domainry-cli verify --version", "version", 0),
    ]) + "\n")
    assert MOD.extract(events) == []


def test_verify_fixture_diagnostic_does_not_consume_scored_verify_attempt(tmp_path):
    events = tmp_path / "events.jsonl"
    events.write_text("\n".join([
        completed(
            "/candidate/domainry-cli verify fixture --json --project /tmp/project",
            '{"contract_version":"domainry-managed-runtime-acceptance-fixture-projection-v1","actor_count":3}',
            0,
        ),
        completed(
            "/candidate/domainry-cli verify --json --project /tmp/project",
            '{"state":"verified_and_stopped"}',
            0,
        ),
    ]) + "\n")
    artifacts = MOD.extract(events)
    assert [(row["family"], row["exit_code"]) for row in artifacts] == [
        ("verify_fixture", 0),
        ("verify", 0),
    ]
    assert artifacts[0]["output_streams_status"] == "aggregated_only"
    assert artifacts[0]["stdout"] is None
    assert artifacts[0]["stderr"] is None
    assert MOD.family_for(
        "/candidate/domainry-cli verify fixture --json --project /tmp/project"
    ) == "verify_fixture"


def test_help_text_inside_an_ordinary_argument_does_not_hide_execution(tmp_path):
    events = tmp_path / "events.jsonl"
    events.write_text(completed(
        "/candidate/domainry-cli verify --json --project /tmp/project--help-copy",
        '{"state":"verified_and_stopped"}', 0,
    ) + "\n")
    artifacts = MOD.extract(events)
    assert len(artifacts) == 1
    assert artifacts[0]["family"] == "verify"
    assert MOD.family_for(
        '/candidate/domainry-cli verify --json --note "ordinary --help text"'
    ) == "verify"


def test_real_baseline_help_then_verify_shape_captures_only_item_160(tmp_path):
    events = tmp_path / "events.jsonl"
    help_event = json.loads(completed(
        "/bin/zsh -lc '/candidate/domainry-cli verify --help'", "domainry-cli usage", 0))
    help_event["item"]["id"] = "item_156"
    verify_event = json.loads(completed(
        "/bin/zsh -lc '/candidate/domainry-cli verify --json --project /tmp/project "
        "--address 127.0.0.1:19286'",
        '{"contract_version":"domainry-project-verify-v2","state":"failed",'
        '"error":"finalization receipt is stale for current project-owned source"}', 1))
    verify_event["item"]["id"] = "item_160"
    events.write_text(json.dumps(help_event) + "\n" + json.dumps(verify_event) + "\n")
    artifacts = MOD.extract(events)
    assert [(row["event_item_id"], row["family"], row["exit_code"])
            for row in artifacts] == [("item_160", "verify", 1)]


def test_mixed_baseline07_output_selects_full_envelope_not_tail_fragment(tmp_path):
    diagnostics = [
        {
            "code": "backend.report.field_not_found",
            "message": "backend.report.field_not_found",
            "file": "backend/model/40-crm-reporting-export.json",
            "json_pointer": "/reports/1/object_sql_v1/sql",
            "constraint": "report.runtime_contract",
            "owner": "domainry-plane-authoring",
            "stage": "authoring_contract",
            "repair_facts": {"field_key": "owner_org_id", "object": "lead"},
        },
        {
            "code": "report.definition.object_sql_invalid",
            "message": "backend.report.field_not_found at object_sql_v1.sql",
            "file": "$.candidate.value.object_sql_v1",
            "constraint": "report.definition.object_sql_invalid",
            "owner": "report",
            "stage": "capability_assembly",
            "repair_facts": {"severity": "error"},
        },
        {
            "code": "ledger.runtime_manifest_invalid",
            "message": (
                "compiled Runtime manifest is invalid: "
                "reports[1].object_sql_v1.sql: backend.report.field_not_found"),
            "file": "backend/model/00-project.json",
            "constraint": "ledger.runtime_manifest_invalid",
            "owner": "domainry-plane-compiler",
            "stage": "runtime_manifest",
            "repair_facts": {"compile_before_publish": True},
        },
    ]
    envelope = {
        "artifact": ".domainry/builder/disposable/model-preflight-result.json",
        "contract_version": "domainry-model-preflight-envelope-v1",
        "state": "repair_required",
        "issue_count": 3,
        "diagnostics": diagnostics,
    }
    raw = "\n".join([
        json.dumps(envelope, separators=(",", ":")),
        "backend.report.field_not_found: backend.report.field_not_found",
        "report.definition.object_sql_invalid: backend.report.field_not_found at object_sql_v1.sql",
        "ledger.runtime_manifest_invalid: reports[1].object_sql_v1.sql is invalid",
        "error: Builder validation found 3 issue(s)",
    ])
    events = tmp_path / "events.jsonl"
    events.write_text(completed(
        '"$DOMAINRY_CLI" model plan --json --project .', raw, 1) + "\n")

    artifact = MOD.extract(events)[0]
    assert artifact["output"] == envelope
    assert artifact["output"]["diagnostics"] == diagnostics
    assert artifact["output"] != [1]
    assert artifact["raw_output"] == raw


def test_parse_output_preserves_pure_json_and_returns_non_json_text():
    pure = {"contract_version": "test-v1", "state": "failed"}
    assert MOD.parse_output(json.dumps(pure)) == pure
    assert MOD.parse_output("progress only\nerror: no structured result") == (
        "progress only\nerror: no structured result")
