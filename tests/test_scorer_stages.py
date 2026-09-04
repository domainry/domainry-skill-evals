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
    for index, family in enumerate(families, 1):
        (cli / f"{index:03d}-{family}.json").write_text(json.dumps({
            "family": family,
            "exit_code": 0,
            "output": {"state": "passed"},
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
    assert scorecard["scorer_schema"] == "domainry-builder-eval-v2"
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
