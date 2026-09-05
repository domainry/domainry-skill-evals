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
    # Read-only customer semantics cannot be identified reliably from an
    # arbitrary resource key; M10 is owned by BF02 behavior evidence.
    assert "customer_read_only" not in facts


def test_manifest_facts_recognizes_overdue_followup_scheduler_chain():
    manifest = {
        "state_machines": [{
            "key": "life", "object_key": "prospect", "field_key": "phase",
            "states": ["new", "contacted", "qualified", "converted", "lost"],
            "terminal_states": ["converted", "lost"],
        }],
        "workflows": [{
            "key": "任意流程键",
            "trigger_contract": {"type": "scheduled"},
            "graph": {"nodes": [{
                "type": "action", "contract": {"action": {"object_key": "prospect"}},
            }]},
        }],
        "scheduler_definitions": [{
            "key": "任意调度键", "status": "enabled", "target_type": "workflow",
            "target_key": "scheduled:任意流程键", "schedule_expression": "0 9 * * 1-5",
        }],
    }
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["stale_scheduler"] is True


def test_manifest_facts_use_reference_structure_not_english_resource_keys():
    manifest = {
        "objects": [
            {"key": "甲", "fields": [
                {"key": "名称", "type": "text", "required": True},
                {"key": "金额", "type": "currency", "config": {"scale": 2}},
                {"key": "来源", "type": "select", "options": [
                    {"value": "a", "label": "官网"}, {"value": "b", "label": "展会"},
                    {"value": "c", "label": "转介绍"}, {"value": "d", "label": "外呼"},
                ]},
                {"key": "阶段", "type": "select"},
            ]},
            {"key": "乙", "fields": [
                {"key": "请求者", "type": "user"}, {"key": "状态", "type": "select"},
            ]},
            {"key": "丙", "fields": [
                {"key": "审计引用", "type": "relation", "config": {"object_key": "乙"}},
                {"key": "文件名", "type": "text"},
            ]},
        ],
        "state_machines": [{
            "key": "生命周期", "object_key": "甲", "field_key": "阶段",
            "states": ["new", "contacted", "qualified", "converted", "lost"],
            "terminal_states": ["converted", "lost"],
            "transitions": [
                {"from": "new", "to": "contacted"},
                {"from": "contacted", "to": "qualified"},
            ],
        }],
        "workflows": [{
            "key": "审批甲", "enabled": True,
            "trigger_contract": {"object_key": "甲"},
            "graph": {
                "nodes": [
                    {"type": "approval"},
                    {"type": "action", "contract": {"action": {"object_key": "甲"}}},
                ],
                "edges": [{"branch": "approved"}, {"branch": "rejected"}],
            },
        }],
        "reports": [
            {"key": "统计甲", "object_sql_v1": {"source_objects": ["甲"], "result_schema": [
                {"key": "数量", "kind": "measure", "type": "integer"},
                {"key": "合计", "kind": "measure", "type": "currency", "scale": 2},
                {"key": "分组", "kind": "dimension", "type": "text"},
            ]}},
            {"key": "明细甲", "object_sql_v1": {"source_objects": ["甲"], "result_schema": []}},
        ],
        "report_export_controls": [{
            "key": "导出甲", "report_key": "明细甲", "source_objects": ["甲"],
            "audit_object": "乙", "download_object": "丙", "max_rows": 100,
            "record_mapping": {
                "audit_requester_field": "请求者", "audit_status_field": "状态",
                "download_audit_field": "审计引用", "download_filename_field": "文件名",
            },
        }],
    }
    facts, lead_key, _ = MOD.manifest_facts(manifest)
    assert lead_key == "甲"
    assert facts["approval_workflow"] is True
    assert facts["funnel_report"] is True
    assert facts["export_control"] is True
    assert facts["detail_report"] is True


def test_manifest_facts_uses_source_business_labels_not_internal_keys():
    manifest = {
        "objects": [{
            "key": "lead",
            "fields": [
                {"key": "company_name", "type": "text", "required": True},
                {"key": "expected_amount", "type": "currency", "config": {"scale": 2}},
                {
                    "key": "source",
                    "type": "select",
                    "options": [
                        {"value": "website", "label": "官网"},
                        {"value": "trade_show", "label": "展会"},
                        {"value": "referral", "label": "转介绍"},
                        {"value": "outbound", "label": "外呼"},
                    ],
                },
                {"key": "status"},
            ],
        }],
        "state_machines": [{
            "key": "anything", "object_key": "lead", "field_key": "status",
            "states": ["new", "contacted", "qualified", "converted", "lost"],
            "terminal_states": ["converted", "lost"],
        }],
    }
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["schema"] is True


def test_fresh_cohort_uses_manifest_derived_lead_table(tmp_path):
    db = tmp_path / "runtime.db"
    with sqlite3.connect(db) as conn:
        conn.execute("CREATE TABLE sales_lead (id TEXT PRIMARY KEY)")
        conn.execute("INSERT INTO sales_lead(id) VALUES ('seed')")
    MOD.assert_fresh_sqlite(db, "sales_lead", 1)


def event(action, test):
    return json.dumps({"Action": action, "Test": test})


def complete_flow_evidence(source="runtime.action"):
    requirements = [str(i) for i in range(1, 20)]
    phases = {}
    for phase in MOD.FLOW_PHASES:
        phases[phase] = {}
        for flow in MOD.FLOW_IDS:
            steps = [{
                "id": "journey", "operation": "business.journey", "source": source,
                "status": "passed", "requirements": requirements, "observations": {},
            }]
            if flow == "BF08":
                observations = {
                    "report.prepare": {"accepted": True, "job_id": "opaque-job"},
                    "report.prepare.unauthorized_denied": {
                        "access_denied": True, "different_actor": True,
                    },
                    "data_exchange.job.owner_bound": {
                        "requester_owned": True, "job_id": "opaque-job",
                    },
                    "data_exchange.job.completed": {
                        "job_status": "completed", "job_id": "opaque-job",
                    },
                    "data_exchange.job.download": {
                        "actual_job_download": True, "job_id": "opaque-job",
                        "byte_count": 42, "content_type": "text/csv; charset=utf-8",
                    },
                    "data_exchange.job.foreign_download_denied": {
                        "access_denied": True, "different_actor": True,
                    },
                    "artifact.csv.content_validated": {
                        "csv_parsed": True, "row_count_matches_report": True,
                        "content_hash_verified": True,
                    },
                }
                steps.extend({
                    "id": operation.replace(".", "-"), "operation": operation,
                    "source": operation_source, "status": "passed", "requirements": ["16"],
                    "observations": observations[operation],
                } for operation, operation_source in MOD.BF08_REQUIRED_OPERATIONS.items())
            phases[phase][flow] = {"phase": phase, "flow_id": flow,
                                   "status": "passed", "steps": steps}
    return {"contract_version": MOD.FLOW_EVIDENCE_CONTRACT, "phases": phases}


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
    outcomes, code, evidence, validity = MOD.verified_flow_outcomes(
        project, verify, complete_flow_evidence())
    assert code == 0
    assert all(outcomes.values())
    assert evidence["same_cohort_identity"] is True
    assert all(validity["initial"].values())


def test_current_verify_proof_fails_when_one_public_flow_is_absent(tmp_path):
    project = tmp_path / "project"
    flow_dir = project / "backend/tests/businessflow"
    flow_dir.mkdir(parents=True)
    flow_dir.joinpath("m1_test.go").write_text(
        "package businessflow\nfunc TestBF01Only(t *testing.T) {}\n")
    outcomes, code, _, _ = MOD.verified_flow_outcomes(
        project, {"state": "verified_and_stopped", "runtime": {}},
        complete_flow_evidence())
    assert code == 1
    assert outcomes["BF08"] is False


def test_current_verify_proof_requires_prd_traceability(tmp_path):
    project = tmp_path / "project"
    flow_dir = project / "backend/tests/businessflow"
    flow_dir.mkdir(parents=True)
    flow_dir.joinpath("m1_test.go").write_text(
        "package businessflow\nfunc TestBF01Only(t *testing.T) {}\n")
    assert MOD.traced_flow_ids(project) == set()


def test_bf08_rejects_direct_records_csv_fallback():
    evidence = complete_flow_evidence()
    evidence["phases"]["initial"]["BF08"]["steps"].append({
        "id": "fallback", "operation": "records.csv_export", "source": "runtime.records",
        "status": "passed", "requirements": ["16"], "observations": {},
    })
    validity, diagnostics = MOD.validate_flow_evidence(evidence)
    assert validity["initial"]["BF08"] is False
    assert "direct_records_csv_is_not_governed_export" in diagnostics["initial"]["BF08"]
    assert MOD.bf08_is_silent_downgrade(diagnostics) is True


def test_bf08_requires_real_data_exchange_download_and_content_validation():
    evidence = complete_flow_evidence()
    evidence["phases"]["restart"]["BF08"]["steps"] = [
        step for step in evidence["phases"]["restart"]["BF08"]["steps"]
        if step["operation"] != "data_exchange.job.download"
    ]
    validity, diagnostics = MOD.validate_flow_evidence(evidence)
    assert validity["restart"]["BF08"] is False
    assert "required_operation_missing:data_exchange.job.download" in diagnostics["restart"]["BF08"]


def test_mechanism_uses_structured_operation_sources():
    evidence = complete_flow_evidence(source="runtime.action")
    mechanism, detail = MOD.mechanism_for_feature("M05", [], ["BF01"], evidence)
    assert mechanism == "reuse"
    assert detail["evidence_sources"] == ["runtime.action"]
    for phase in MOD.FLOW_PHASES:
        evidence["phases"][phase]["BF02"]["steps"][0]["source"] = "project_handler"
    mechanism, detail = MOD.mechanism_for_feature("M06", [], ["BF02", "BF03"], evidence)
    assert mechanism == "custom"
    assert detail["classification"] == "hybrid"
    assert "project_handler" in detail["evidence_sources"]
