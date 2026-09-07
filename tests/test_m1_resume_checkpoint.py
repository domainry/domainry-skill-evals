"""Freeze the authorized M1 resume boundary without changing its accepted archive."""

import hashlib
import json
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "harness"))
import run_driver


SOURCE_RUN = "m1-crm-scheduler-run-route-resume-convergence-41"
V5 = ROOT / "runs" / (
    SOURCE_RUN + "-checkpoint-managed-elapsed-time-verification-seam-gap-v5")
V6 = ROOT / "runs" / (
    SOURCE_RUN + "-checkpoint-req14-due-continuation-v6")
V7 = ROOT / "runs" / (
    SOURCE_RUN + "-checkpoint-req14-due-continuation-v7")
ARCHIVE = V5 / "checkpoint-project.tar.gz"
V5_MANIFEST_SHA = "c1492f0104781818649209dce2ffcf5506fd795e950b8fb31adc45f320d46bcb"
V6_MANIFEST_SHA = "491d4c69cfbd0a4a2b4edb74507ea10cebefa2fb7a3a9b424d1d5a39dbafc41f"
V7_MANIFEST_SHA = "f3d3e8c9d403a0d405a54937f30d15ee0baf4dbf85ba736eb0d76a8dc6eafd67"
ARCHIVE_SHA = "4aec796c2809fddc88d9d18172029bc4e991140277b4cbcc23c76522cc17ecd9"
OLD_PAUSE = "Do not run convergence42 or a from-zero M1 baseline."
ACTIVE_RESUME = (
    "Continue the current convergence run started by the evaluator according to "
    "this restored-project boundary. This Agent must not start any nested "
    "evaluation run or a from-zero M1 baseline.")


def manifest(directory):
    return json.loads((directory / "checkpoint.json").read_text())


def test_v7_checkpoint_identity_preserves_frozen_ancestors_and_archive():
    for directory, expected in (
        (V5, V5_MANIFEST_SHA), (V6, V6_MANIFEST_SHA), (V7, V7_MANIFEST_SHA),
    ):
        assert hashlib.sha256(
            (directory / "checkpoint.json").read_bytes()).hexdigest() == expected
    identity = run_driver.checkpoint_identity(
        V7 / "checkpoint.json", ARCHIVE, SOURCE_RUN)
    current = manifest(V7)
    assert identity["manifest_sha256"] == V7_MANIFEST_SHA
    assert identity["archive_sha256"] == ARCHIVE_SHA
    assert identity["source_run_id"] == SOURCE_RUN
    assert identity["baseline_eligibility"] is False
    assert identity["manifest_only_boundary_migration"] is True
    assert current["parent_checkpoint"] == {
        "checkpoint_id": V6.name,
        "manifest_sha256": V6_MANIFEST_SHA,
        "archive_sha256": ARCHIVE_SHA,
        "restored_file_count": 1387,
    }
    assert (V7 / current["archive"]["path"]).resolve() == ARCHIVE.resolve()
    assert current["archive"] == manifest(V6)["archive"]
    assert current["archive_policy"] == manifest(V6)["archive_policy"]
    assert current["restore_expectations"] == manifest(V6)["restore_expectations"]
    assert not (V7 / "checkpoint-project.tar.gz").exists()


def test_v7_changes_only_obsolete_orchestration_rule_not_req14_semantics():
    previous, current = manifest(V6), manifest(V7)
    for field in ("stage", "next_node", "prior_delivery_id"):
        assert current["resume_boundary"][field] == previous["resume_boundary"][field]
    assert current["blocking_condition"]["prohibited_repairs"] == [
        item.replace("this v6 manifest", "this v7 manifest")
        for item in previous["blocking_condition"]["prohibited_repairs"]
    ]
    assert current["resume_boundary"]["rule"] == (
        previous["resume_boundary"]["rule"]
        .replace("this v6 boundary", "this v7 boundary")
        .replace(OLD_PAUSE, ACTIVE_RESUME)
    )
    assert "Do not run convergence42" not in json.dumps(current)
    assert current["baseline_eligibility"] is False


def test_v7_prompt_injects_active_resume_and_complete_req14_contract(tmp_path):
    identity = run_driver.checkpoint_identity(
        V7 / "checkpoint.json", ARCHIVE, SOURCE_RUN)
    destination = tmp_path / "prompt.md"
    run_driver.append_prompt_policy(
        ROOT / "benchmarks/m1-crm/agent-prompt.md", destination, "convergence",
        checkpoint_restored=True, checkpoint=identity)
    prompt = destination.read_text()
    marker = "### Authoritative checkpoint resume boundary"
    injected_json = prompt.split(marker, 1)[1].split("```json\n", 1)[1].split("\n```", 1)[0]
    injected = json.loads(injected_json)
    assert injected == {
        "resume_boundary": identity["resume_boundary"],
        "prohibited_repairs": identity["prohibited_repairs"],
    }
    assert ACTIVE_RESUME in injected["resume_boundary"]["rule"]
    assert "Do not run convergence42" not in prompt
    for requirement in (
        "next_followup_at field change",
        "contract.condition{type=field_equals,field=status,value=contacted}",
        "no false-branch route to the timer",
        "composite uniqueness over exactly lead relation plus local reminder date",
        "file-only hermetic GOPROXY chain",
        "go list module identity must be external",
        "non-zero Runtime record-timer statements",
        "exact zero-offset next_followup_at source-field due preservation",
        "TestM1Req14DueActionIdempotentContinuation",
        "TestM1Req14RuntimeRecordTimerRestartRecovery",
        "never pass@1 evidence",
    ):
        assert requirement in prompt


def test_v8_resumes_actual_convergence42_archive_with_attributed_interruption(tmp_path):
    source_run = "m1-crm-workflow-delay-resume-convergence-42"
    directory = ROOT / "runs" / source_run
    parent = directory / "failure-checkpoint-1788754990099648000"
    path = directory / "checkpoint-req14-canonical-unique-v8.json"
    archive = parent / "checkpoint-project.tar.gz"
    document = json.loads(path.read_text())
    assert hashlib.sha256((parent / "checkpoint.json").read_bytes()).hexdigest() == (
        "68b59a1239e5cea123d10eaaeb3aa5b84fe5a5d8bf54f4535af8ce76559a4a57")
    identity = run_driver.checkpoint_identity(path, archive, source_run)
    assert identity["archive_sha256"] == (
        "b03027b370e98d1449f34ce5e843737c4c1ca2e413bc566f2da90573a5857dda")
    assert identity["manifest_only_boundary_migration"] is True
    assert (directory / document["archive"]["path"]).resolve() == archive.resolve()
    assert identity["failure_boundary"]["first_failure"] is None
    assert identity["failure_boundary"]["runtime_defect"] is False
    assert identity["failure_boundary"]["interruption_initiator"] == "evaluator_controller"
    destination = tmp_path / "prompt.md"
    run_driver.append_prompt_policy(
        ROOT / "benchmarks/m1-crm/agent-prompt.md", destination, "convergence",
        checkpoint_restored=True, checkpoint=identity)
    prompt = destination.read_text()
    assert identity["resume_boundary"]["next_node"] in prompt
    assert "exactly the lead relation and local reminder date" in prompt
    assert "source_field-only timer" in prompt
    assert "interruption_initiator" in prompt


def test_v9_resumes_apply_and_authorizes_only_observed_obsolete_resources(tmp_path):
    source_run = "m1-crm-canonical-unique-resume-convergence-43"
    directory = ROOT / "runs" / source_run
    parent = directory / "failure-checkpoint-1788755522983494000"
    path = directory / "checkpoint-reviewed-removals-v9.json"
    document = json.loads(path.read_text())
    identity = run_driver.checkpoint_identity(
        path, parent / "checkpoint-project.tar.gz", source_run)
    assert hashlib.sha256((parent / "checkpoint.json").read_bytes()).hexdigest() == (
        "345838979c49f009f9a5731b17116637b1739e228ba0b311035dcb283996e173")
    assert identity["manifest_only_boundary_migration"] is True
    assert identity["resume_boundary"]["stage"] == "apply"
    plan = json.loads((directory / "cli/002-model_plan.json").read_text())["output"]
    assert plan["state"] == "valid" and not plan["diagnostics"]
    assert document["reviewed_deletions"] == plan["delete_items"]
    assert identity["failure_boundary"]["model_identity"] == plan["identity"]
    assert identity["failure_boundary"]["code"] == "model.destructive_blocked"
    destination = tmp_path / "prompt.md"
    run_driver.append_prompt_policy(
        ROOT / "benchmarks/m1-crm/agent-prompt.md", destination, "convergence",
        checkpoint_restored=True, checkpoint=identity)
    prompt = destination.read_text()
    assert identity["resume_boundary"]["next_node"] in prompt
    assert "--allow-destructive" in prompt
    assert "do not broaden the three reviewed Ledger deletions" in prompt


def test_v10_preserves_checkpoint_and_uses_plan_envelope_not_provenance_grep(tmp_path):
    source_run = "m1-crm-reviewed-removal-resume-convergence-44"
    directory = ROOT / "runs" / source_run
    parent = directory / "failure-checkpoint-1788755779764260000"
    path = directory / "checkpoint-structured-plan-v10.json"
    identity = run_driver.checkpoint_identity(
        path, parent / "checkpoint-project.tar.gz", source_run)
    assert hashlib.sha256((parent / "checkpoint.json").read_bytes()).hexdigest() == (
        "28413aa575437c38011d318dcbe92aed408332b0bc4e11d9cc192ef7e2433bcd")
    assert identity["manifest_only_boundary_migration"] is True
    assert identity["resume_boundary"]["stage"] == "apply"
    assert identity["failure_boundary"]["runtime_defect"] is False
    destination = tmp_path / "prompt.md"
    run_driver.append_prompt_policy(
        ROOT / "benchmarks/m1-crm/agent-prompt.md", destination, "convergence",
        checkpoint_restored=True, checkpoint=identity)
    prompt = destination.read_text()
    assert identity["resume_boundary"]["next_node"] in prompt
    assert "do not grep the disposable provenance artifact" in prompt
    assert "--allow-destructive" in prompt
