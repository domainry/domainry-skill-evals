import importlib.util
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("scorer", ROOT / "harness/scorer.py")
MOD = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MOD)


def test_c5_matches_current_builder_workflow():
    assert MOD.C5_STAGES == ("requirements", "model", "apply", "verify")


def test_unknown_stage_is_not_emitted():
    result = MOD.normalize_stage_seconds({
        "verify": {"started": 10, "ended": 20},
        "acceptance": {"started": 20, "ended": 30},
    })
    assert result == {
        "requirements": None,
        "model": None,
        "apply": None,
        "verify": 10,
    }


def write_run(tmp_path, families):
    run = tmp_path / "run"
    cli = run / "cli"
    cli.mkdir(parents=True)
    (run / "meta.json").write_text(json.dumps({
        "benchmark": "m1-crm",
        "candidate_id": "pkg+tree",
        "skill_version": "pkg",
        "run_id": "fresh-01",
        "agent_declared_done": True,
        "human_interventions": 0,
    }))
    (run / "checklist-results.json").write_text(json.dumps({"results": [
        {"id": "M01", "priority": "P0", "status": "pass", "mechanism": "custom"},
    ]}))
    outputs = {
        "model_plan": {"state": "valid"},
        "apply_model": {"state": "implementation_ready"},
        "apply_finalize": {"state": "finalized"},
        "verify": {"state": "verified_and_stopped"},
        "acceptance_check": {"state": "passed"},
    }
    for index, family in enumerate(families, 1):
        (cli / f"{index:03d}-{family}.json").write_text(json.dumps({
            "family": family,
            "exit_code": 0,
            "output": outputs.get(family, {"state": "passed"}),
        }))
    return run


def test_current_cli_funnel_can_prove_pass_at_1(tmp_path, capsys):
    run = write_run(tmp_path, [
        "model_capability", "model_plan", "apply_model",
        "apply_finalize", "verify", "acceptance_check",
    ])
    MOD.main(run)
    capsys.readouterr()
    scorecard = json.loads((run / "scorecard.json").read_text())
    assert scorecard["scorer_schema"] == "domainry-builder-eval-v3"
    assert scorecard["candidate_id"] == "pkg+tree"
    assert scorecard["pass_at_1"] is True
    assert scorecard["A6_rework_rounds"] == 0
    assert "A1_validate_first_pass" not in scorecard


def test_final_receipts_cannot_impersonate_first_pass(tmp_path, capsys):
    run = write_run(tmp_path, [])
    state = run / "project/.domainry/builder"
    (state / "receipts").mkdir(parents=True)
    (state / "runtime").mkdir()
    (state / "blueprint-validation.json").write_text(json.dumps({
        "parse_status": "valid", "unsupported_capabilities": [],
    }))
    (state / "model-apply.json").write_text(json.dumps({
        "state": "applied", "preflight": {"issue_count": 0},
    }))
    (state / "receipts/finalization.json").write_text(json.dumps({
        "checks": [{"status": "passed"}],
    }))
    (state / "receipts/verification.json").write_text(json.dumps({
        "checks": [{"status": "passed"}],
    }))
    (state / "receipts/package.json").write_text(json.dumps({
        "receipt_sha256": "package",
    }))
    (state / "runtime/runtime-process.json").write_text(json.dumps({
        "state": "stopped", "cohort_state": "current", "stopped_at": "now",
    }))
    MOD.main(run)
    capsys.readouterr()
    scorecard = json.loads((run / "scorecard.json").read_text())
    assert scorecard["A1_plan_first_pass"] is True
    assert scorecard["A4_verify_first_pass"] is True
    assert scorecard["pass_at_1"] is None


def test_benchmark_or_platform_mismatch_is_not_agent_false_done(tmp_path, capsys):
    run = write_run(tmp_path, [
        "model_plan", "apply_model", "apply_finalize", "verify",
    ])
    (run / "checklist-results.json").write_text(json.dumps({"results": [
        {"id": "M01", "priority": "P0", "status": "fail", "mechanism": "reuse"},
    ]}))
    (run / "failures.json").write_text(json.dumps([
        {"stage": "acceptance", "owner": "benchmark_defect", "note": "bad oracle"},
        {"stage": "verify", "owner": "cli_platform", "note": "platform defect"},
    ]))
    MOD.main(run)
    capsys.readouterr()
    scorecard = json.loads((run / "scorecard.json").read_text())
    assert scorecard["A7_oracle_done_mismatch"] is True
    assert scorecard["A7_false_done"] is False
    assert scorecard["A7_false_done_classification"] == "benchmark_or_platform_mismatch"


def test_convergence_and_budget_terminal_states_are_not_pass_at_1(tmp_path, capsys):
    run = write_run(tmp_path, [
        "model_plan", "apply_model", "apply_finalize", "verify",
    ])
    (run / "lifecycle.json").write_text(json.dumps({
        "run_kind": "convergence",
        "parent_run_id": "baseline-01",
        "state": "completed",
        "measurement_complete": True,
    }))
    MOD.main(run)
    capsys.readouterr()
    scorecard = json.loads((run / "scorecard.json").read_text())
    assert scorecard["pass_at_1"] is None
    assert scorecard["pass_at_1_eligible"] is False
    assert scorecard["run_outcome_pass"] is True

    (run / "lifecycle.json").write_text(json.dumps({
        "run_kind": "baseline",
        "state": "budget_exhausted_wall_clock",
        "measurement_complete": False,
    }))
    MOD.main(run)
    capsys.readouterr()
    scorecard = json.loads((run / "scorecard.json").read_text())
    assert scorecard["pass_at_1"] is False
    assert scorecard["run_outcome_pass"] is False


def test_b3_uses_explicit_reuse_eligibility(tmp_path, capsys):
    run = write_run(tmp_path, [
        "model_plan", "apply_model", "apply_finalize", "verify",
    ])
    (run / "checklist-results.json").write_text(json.dumps({"results": [
        {"id": "M01", "priority": "P0", "status": "pass", "mechanism": "reuse",
         "reuse_eligible": True},
        {"id": "M02", "priority": "P0", "status": "pass", "mechanism": "custom",
         "reuse_eligible": True},
        {"id": "M06", "priority": "P0", "status": "pass", "mechanism": "custom",
         "reuse_eligible": False},
    ]}))
    MOD.main(run)
    capsys.readouterr()
    scorecard = json.loads((run / "scorecard.json").read_text())
    assert scorecard["B3_platform_reuse_rate"] == 0.5


def test_measured_run_does_not_derive_unobserved_stages_from_receipts(tmp_path, capsys):
    run = write_run(tmp_path, ["model_plan", "apply_model"])
    state = run / "project/.domainry/builder/receipts"
    state.mkdir(parents=True)
    (state / "finalization.json").write_text(json.dumps({"receipt_sha256": "stale"}))
    (run / "lifecycle.json").write_text(json.dumps({
        "run_kind": "baseline",
        "state": "delivery_incomplete",
        "measurement_complete": False,
        "environment_valid": True,
    }))
    MOD.main(run)
    capsys.readouterr()
    scorecard = json.loads((run / "scorecard.json").read_text())
    assert scorecard["A3_finalize_first_pass"] is None
    assert scorecard["A_source"]["A3"] == "not_measurable"


def test_finalize_without_success_receipt_is_not_a3_first_pass(tmp_path, capsys):
    run = write_run(tmp_path, [
        "model_plan", "apply_model", "apply_finalize", "verify",
    ])
    finalize = run / "cli/003-apply_finalize.json"
    document = json.loads(finalize.read_text())
    document["output"] = {}
    finalize.write_text(json.dumps(document))
    (run / "lifecycle.json").write_text(json.dumps({
        "run_kind": "baseline",
        "state": "delivery_incomplete",
        "measurement_complete": False,
        "environment_valid": True,
    }))
    MOD.main(run)
    capsys.readouterr()
    scorecard = json.loads((run / "scorecard.json").read_text())
    assert scorecard["A3_finalize_first_pass"] is False
    assert scorecard["pass_at_1_eligible"] is False


def test_c5_rejects_out_of_bounds_and_overlapping_agent_timestamps(tmp_path, capsys):
    run = write_run(tmp_path, ["model_plan", "apply_model"])
    stage_path = run / "project/.domainry/development/stages.json"
    stage_path.parent.mkdir(parents=True)
    (run / "lifecycle.json").write_text(json.dumps({
        "run_kind": "baseline",
        "state": "delivery_incomplete",
        "measurement_complete": False,
        "environment_valid": True,
        "started_epoch": 100.0,
        "agent_ended_epoch": 300.0,
    }))

    stage_path.write_text(json.dumps({
        "requirements": {"started": 29.0, "ended": 120.0},
        "model": {"started": 120.0, "ended": 180.0},
    }))
    MOD.main(run)
    capsys.readouterr()
    scorecard = json.loads((run / "scorecard.json").read_text())
    assert scorecard["C5_stage_seconds_status"] == "unavailable"
    assert scorecard["C5_project_stage_report"]["status"] == "invalid_out_of_bounds"
    assert all(value is None for value in scorecard["C5_stage_seconds"].values())

    stage_path.write_text(json.dumps({
        "requirements": {"started": 100.0, "ended": 180.0},
        "model": {"started": 170.0, "ended": 220.0},
    }))
    MOD.main(run)
    capsys.readouterr()
    scorecard = json.loads((run / "scorecard.json").read_text())
    assert scorecard["C5_stage_seconds_status"] == "unavailable"
    assert scorecard["C5_project_stage_report"]["status"] == "invalid_non_monotonic"
    assert all(value is None for value in scorecard["C5_stage_seconds"].values())


def test_c5_evaluator_timing_survives_invalid_project_report(tmp_path, capsys):
    run = write_run(tmp_path, [
        "model_capability", "model_plan", "apply_model", "apply_finalize", "verify",
    ])
    (run / "lifecycle.json").write_text(json.dumps({
        "run_kind": "baseline",
        "state": "completed",
        "measurement_complete": True,
        "environment_valid": True,
        "started_epoch": 100.0,
        "agent_ended_epoch": 200.0,
    }))
    stages = {
        "discovery": (100.0, 120.0),
        "plan": (120.0, 140.0),
        "apply": (140.0, 165.0),
        "finalize": (165.0, 175.0),
        "verify": (175.0, 200.0),
    }
    (run / "stage-timing.json").write_text(json.dumps({
        "contract_version": MOD.STAGE_TIMING_CONTRACT,
        "boundary_rule": "evaluator-cli-transition-v1",
        "stage_order": list(MOD.C5_OBSERVED_STAGES),
        "status": "valid",
        "stages": {
            stage: {
                "started_epoch": interval[0],
                "ended_epoch": interval[1],
                "seconds": interval[1] - interval[0],
                "status": "observed",
                "start_provenance": {"source": "synthetic-observation"},
                "end_provenance": {"source": "synthetic-observation"},
            }
            for stage, interval in stages.items()
        },
    }))
    stage_path = run / "project/.domainry/development/stages.json"
    stage_path.parent.mkdir(parents=True)
    stage_path.write_text(json.dumps({
        "requirements": {"started": 100, "ended": 120},
        "model": {"started": 120, "ended": 140},
        "apply": {"started": 140, "ended": 175},
        "verify": {"started": 175, "ended": 0},
    }))

    MOD.main(run)
    capsys.readouterr()
    scorecard = json.loads((run / "scorecard.json").read_text())
    assert scorecard["C5_stage_seconds_source"] == "evaluator-events"
    assert scorecard["C5_stage_seconds_status"] == "valid"
    assert scorecard["C5_stage_seconds"] == {
        "requirements": 20.0,
        "model": 20.0,
        "apply": 35.0,
        "verify": 25.0,
    }
    assert scorecard["C5_stage_timing"]["critical_path"] == {
        "observed_seconds": 100.0,
        "unknown_stages": [],
        "hotspot": {"stage": "apply", "seconds": 25.0},
    }
    assert scorecard["C5_project_stage_report"]["status"] == "invalid_out_of_bounds"


def test_c5_old_run_without_event_timing_keeps_driver_stage_fallback(tmp_path, capsys):
    run = write_run(tmp_path, ["model_plan", "apply_model"])
    (run / "stages.json").write_text(json.dumps({
        "requirements": 11,
        "model": 22,
        "apply": 33,
        "verify": None,
    }))

    MOD.main(run)
    capsys.readouterr()
    scorecard = json.loads((run / "scorecard.json").read_text())
    assert scorecard["C5_stage_seconds"] == {
        "requirements": 11,
        "model": 22,
        "apply": 33,
        "verify": None,
    }
    assert scorecard["C5_stage_seconds_source"] == "stages.json"
    assert scorecard["C5_stage_seconds_status"] == "valid"
    assert scorecard["C5_stage_timing"] is None
