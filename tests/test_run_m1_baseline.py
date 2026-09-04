import importlib.util
import json
from pathlib import Path
import sqlite3


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("run_m1_baseline", ROOT / "harness/run_m1_baseline.py")
MOD = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MOD)


def test_fresh_cohort_requires_exact_seed_count(tmp_path):
    db = tmp_path / "runtime.db"
    with sqlite3.connect(db) as conn:
        conn.execute("CREATE TABLE lead (id TEXT PRIMARY KEY)")
        conn.executemany("INSERT INTO lead(id) VALUES (?)", [("a",), ("b",)])
    MOD.assert_fresh_sqlite(db, "lead", 2)
    try:
        MOD.assert_fresh_sqlite(db, "lead", 1)
    except RuntimeError as exc:
        assert "acceptance residue" in str(exc)
    else:
        raise AssertionError("dirty cohort was accepted")


def test_feature_mapping_covers_frozen_denominator():
    assert set(MOD.FEATURES) == {f"M{i:02d}" for i in range(1, 20)}
    assert set(MOD.FLOW_IDS) == {f"BF{i:02d}" for i in range(1, 9)}


def test_permission_key_accepts_current_structured_and_legacy_permissions():
    assert MOD.permission_key({
        "permission_key": "customer.update",
        "data_scope": "all",
    }) == "customer.update"
    assert MOD.permission_key("customer.delete;all") == "customer.delete"
    assert MOD.permission_key({"data_scope": "all"}) == ""


def test_manifest_facts_reads_structured_role_permissions():
    manifest = {
        "objects": [{"key": "customer", "fields": []}],
        "roles": [{
            "key": "director",
            "permissions": [{
                "permission_key": "customer.update",
                "data_scope": "all",
            }],
        }],
    }
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["customer_read_only"] is False


def test_manifest_facts_recognizes_overdue_followup_scheduler_chain():
    manifest = {
        "actions": [{"key": "lead.scan_overdue"}],
        "workflows": [{"key": "weekday_overdue_followup"}],
        "scheduler_definitions": [{"key": "weekday_overdue_followup"}],
    }
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["stale_scheduler"] is True


def test_fresh_cohort_uses_manifest_derived_lead_table(tmp_path):
    db = tmp_path / "runtime.db"
    with sqlite3.connect(db) as conn:
        conn.execute("CREATE TABLE sales_lead (id TEXT PRIMARY KEY)")
        conn.execute("INSERT INTO sales_lead(id) VALUES ('seed')")
    MOD.assert_fresh_sqlite(db, "sales_lead", 1)


def event(action, test):
    return json.dumps({"Action": action, "Test": test})


def test_flow_discovery_uses_public_id_not_historical_full_name():
    output = "\n".join([
        event("pass", "TestBF01AnyCurrentImplementationName"),
        event("pass", "TestBF02_DirectConversion"),
        event("pass", "TestBF03/approval"),
    ])
    result = MOD.parse_flow_outcomes(output)
    assert result["BF01"] is True
    assert result["BF02"] is True
    assert result["BF03"] is True
    assert result["BF04"] is False


def test_flow_discovery_does_not_alias_one_test_to_hidden_cases():
    result = MOD.parse_flow_outcomes(
        event("pass", "TestBF05DirectorFunnelAuthorization"))
    assert result["BF05"] is True
    assert result["BF07"] is False
    assert result["BF08"] is False


def test_any_failed_test_for_public_flow_fails_that_flow():
    result = MOD.parse_flow_outcomes("\n".join([
        event("pass", "TestBF06ReminderHappyPath"),
        event("fail", "TestBF06ReminderDedupe"),
    ]))
    assert result["BF06"] is False


def test_current_verify_proof_requires_all_public_flow_ids(tmp_path):
    project = tmp_path / "project"
    flow_dir = project / "backend/tests/businessflow"
    flow_dir.mkdir(parents=True)
    flow_dir.joinpath("m1_test.go").write_text(
        "package businessflow\n" + "\n".join(
            f"func TestBF{i:02d}CurrentName(t *testing.T) {{}}" for i in range(1, 9)))
    (project / "docs").mkdir()
    (project / "docs/backend-requirements-prd.md").write_text(
        "\n".join(f"BF{i:02d}" for i in range(1, 9)))
    identity = {key: key + "-value" for key in (
        "database_identity_sha256", "package_receipt_sha256",
        "verification_receipt_sha256", "project_source_tree_sha256",
        "runtime_manifest_sha256",
    )}
    started = {**identity, "state": "running", "healthy": True, "cohort_state": "current"}
    stopped = {**identity, "state": "stopped", "cohort_state": "current", "stopped_at": "now"}
    flow = {"status": "passed", "binary_sha256": "binary", "delivery_id": "delivery"}
    verify = {"state": "verified_and_stopped", "runtime": {
        "initial_start": started,
        "initial_business_flow": flow,
        "initial_stop": stopped,
        "restart": started,
        "restart_business_flow": flow,
        "final_stop": stopped,
    }}
    outcomes, code, evidence = MOD.verified_flow_outcomes(project, verify)
    assert code == 0
    assert all(outcomes.values())
    assert evidence["same_cohort_identity"] is True


def test_current_verify_proof_fails_when_one_public_flow_is_absent(tmp_path):
    project = tmp_path / "project"
    flow_dir = project / "backend/tests/businessflow"
    flow_dir.mkdir(parents=True)
    flow_dir.joinpath("m1_test.go").write_text(
        "package businessflow\nfunc TestBF01Only(t *testing.T) {}\n")
    outcomes, code, _ = MOD.verified_flow_outcomes(
        project, {"state": "verified_and_stopped", "runtime": {}})
    assert code == 1
    assert outcomes["BF08"] is False


def test_current_verify_proof_requires_prd_traceability(tmp_path):
    project = tmp_path / "project"
    flow_dir = project / "backend/tests/businessflow"
    flow_dir.mkdir(parents=True)
    flow_dir.joinpath("m1_test.go").write_text(
        "package businessflow\nfunc TestBF01Only(t *testing.T) {}\n")
    assert MOD.traced_flow_ids(project) == set()
