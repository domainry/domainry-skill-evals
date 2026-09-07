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


def due_continuation_manifest():
    return {
        "objects": [
            {"key": "prospect", "fields": [
                {"key": "status_changed_at", "type": "datetime"},
                {"key": "next_followup_at", "type": "datetime"},
            ]},
            {"key": "receipt", "fields": [
                {"key": "prospect_ref", "type": "relation",
                 "config": {"object_key": "prospect"}},
                {"key": "owner", "type": "user"},
                {"key": "local_day", "type": "date"},
                {"key": "dedupe", "type": "text"},
            ], "validations": [{
                "key": "prospect_day", "type": "composite_unique",
                "fields": ["prospect_ref", "local_day"],
            }]},
        ],
        "state_machines": [{
            "key": "life", "object_key": "prospect", "field_key": "status",
            "states": ["new", "contacted", "qualified", "converted", "lost"],
            "terminal_states": ["converted", "lost"],
        }],
        "actions": [{"key": "prospect.continue_due", "object_key": "prospect",
                     "kind": "record_operation", "payload_fields": []}],
        "workflows": [{
            "key": "任意到期流程键", "enabled": True,
            "trigger_contract": {
                "type": "field_changed", "object_key": "prospect",
                "field_key": "next_followup_at",
            },
            "graph": {
                "version": 2,
                "nodes": [
                    {"id": "changed", "name": "Changed", "type": "trigger"},
                    {"id": "still_contacted", "type": "condition", "contract": {
                        "condition": {
                            "type": "field_equals", "field": "status",
                            "value": "contacted",
                        },
                    }, "name": "Still contacted"},
                    {"id": "due", "name": "Due", "type": "timer", "contract": {"timer": {
                        "timer_key": "lead-followup-due", "purpose": "resume due lead",
                        "source_field": "next_followup_at", "timezone": "Asia/Shanghai",
                    }}},
                    {"id": "continue", "name": "Continue", "type": "action", "contract": {"action": {
                        "action_key": "prospect.continue_due", "object_key": "prospect",
                    }}},
                ],
                "edges": [
                    {"id": "changed-condition", "source": "changed",
                     "target": "still_contacted"},
                    {"id": "condition-due", "source": "still_contacted",
                     "target": "due", "branch": "true"},
                    {"id": "due-continue", "source": "due", "target": "continue"},
                ],
            },
        }],
        "scheduler_definitions": [],
    }


def test_manifest_facts_recognizes_event_driven_due_continuation_chain():
    manifest = due_continuation_manifest()
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is True


def test_manifest_facts_rejects_relevant_scheduled_workflow():
    manifest = due_continuation_manifest()
    manifest["workflows"].append({
        "key": "legacy_scan", "enabled": True,
        "trigger_contract": {"type": "scheduled"},
        "graph": {"version": 2, "nodes": [{
            "id": "scan", "type": "action", "contract": {"action": {
                "action_key": "prospect.continue_due", "object_key": "prospect",
            }},
        }], "edges": []},
    })
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False

def test_manifest_facts_rejects_scheduler_definition_targeting_due_workflow():
    manifest = due_continuation_manifest()
    manifest["scheduler_definitions"] = [{
        "key": "direct_due_target", "status": "enabled", "target_type": "workflow",
        "target_key": "scheduled:任意到期流程键",
    }]
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False


def test_manifest_facts_allows_unrelated_scheduler():
    manifest = due_continuation_manifest()
    manifest["scheduler_definitions"] = [{
        "key": "unrelated", "target_type": "report_snapshot_refresh",
        "target_key": "unrelated-report",
    }]
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is True


def test_manifest_facts_rejects_evaluation_time_in_any_production_action():
    manifest = due_continuation_manifest()
    manifest["actions"].append({
        "key": "unrelated.export", "object_key": "receipt", "kind": "record_operation",
        "payload_fields": [
        {"key": "evaluation_time", "type": "datetime"},
        ],
    })
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False


def test_manifest_facts_rejects_evaluation_time_in_any_production_workflow():
    manifest = due_continuation_manifest()
    manifest["workflows"].append({
        "key": "unrelated_export", "enabled": True,
        "trigger_contract": {"type": "manual"},
        "input_fields": [{"key": "evaluation_time", "type": "datetime"}],
        "graph": {"version": 2, "nodes": [
            {"id": "start", "name": "Start", "type": "trigger"},
        ], "edges": []},
    })
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False


def test_manifest_facts_rejects_updated_at_substitution_and_missing_dedupe():
    manifest = due_continuation_manifest()
    lead = manifest["objects"][0]
    lead["fields"] = [
        {"key": "updated_at", "type": "datetime"},
        {"key": "next_followup_at", "type": "datetime"},
    ]
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False

    manifest = due_continuation_manifest()
    manifest["objects"][1]["validations"] = [{
        "key": "wrong_pair", "type": "composite_unique", "fields": ["owner", "dedupe"],
    }]
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False

    manifest = due_continuation_manifest()
    reminder = manifest["objects"][1]
    reminder.pop("validations")
    reminder["fields"][-1]["unique"] = True
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False

    manifest["objects"][1]["validations"] = [{
        "key": "wrong_tuple", "type": "composite_unique",
        "fields": ["prospect_ref", "local_day", "owner"],
    }]
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False


def test_reminder_dedupe_requires_canonical_runtime_composite_validation():
    reminder = due_continuation_manifest()["objects"][1]
    assert MOD.object_has_reminder_dedupe(reminder, "prospect")
    validation = reminder.pop("validations")[0]
    for legacy_field in ("unique_constraints", "constraints"):
        reminder[legacy_field] = [{"type": "unique", "fields": validation["fields"]}]
        assert not MOD.object_has_reminder_dedupe(reminder, "prospect")
        reminder.pop(legacy_field)
    reminder["config"] = {"unique_constraints": [validation]}
    assert not MOD.object_has_reminder_dedupe(reminder, "prospect")
    reminder["validations"] = [dict(validation, type="conditional_unique")]
    assert not MOD.object_has_reminder_dedupe(reminder, "prospect")
    reminder["validations"] = [dict(validation, fields=["prospect_ref", "local_day", "local_day"])]
    assert not MOD.object_has_reminder_dedupe(reminder, "prospect")
    reminder["validations"] = {"prospect_day": validation}
    assert not MOD.object_has_reminder_dedupe(reminder, "prospect")
    reminder["validations"] = [dict(validation, fields=[["prospect_ref"], "local_day"])]
    assert not MOD.object_has_reminder_dedupe(reminder, "prospect")


def test_manifest_facts_rejects_timer_side_due_recalculation():
    manifest = due_continuation_manifest()
    timer = manifest["workflows"][0]["graph"]["nodes"][2]["contract"]["timer"]
    timer["offset"] = "PT168H"
    timer["business_calendar_key"] = "sales-workdays"
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False


def test_manifest_facts_rejects_wrong_timer_source_and_disconnected_graph():
    manifest = due_continuation_manifest()
    timer = manifest["workflows"][0]["graph"]["nodes"][2]["contract"]["timer"]
    timer["source_field"] = "updated_at"
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False

    manifest = due_continuation_manifest()
    manifest["workflows"][0]["graph"]["edges"] = [
        {"id": "bypass", "source": "changed", "target": "continue"},
    ]
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False

    manifest = due_continuation_manifest()
    graph = manifest["workflows"][0]["graph"]
    graph["nodes"] = [node for node in graph["nodes"] if node["type"] != "condition"]
    graph["edges"] = [
        {"id": "changed-due", "source": "changed", "target": "due"},
        {"id": "due-continue", "source": "due", "target": "continue"},
    ]
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False


def test_manifest_facts_rejects_noncanonical_contacted_condition_and_false_timer_branch():
    manifest = due_continuation_manifest()
    condition = manifest["workflows"][0]["graph"]["nodes"][1]
    condition["contract"]["condition"] = {
        "type": "expression", "expression": "status != contacted",
    }
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False

    manifest = due_continuation_manifest()
    edges = manifest["workflows"][0]["graph"]["edges"]
    edges[1]["branch"] = "false"
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False

    manifest = due_continuation_manifest()
    manifest["workflows"][0]["graph"]["edges"].append({
        "id": "condition-due-false", "source": "still_contacted",
        "target": "due", "branch": "false",
    })
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False

    manifest = due_continuation_manifest()
    manifest["workflows"][0]["graph"]["edges"].append({
        "id": "trigger-due-bypass", "source": "changed", "target": "due",
    })
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False


def test_manifest_facts_rejects_empty_duplicate_node_ids_and_illegal_edge_endpoints():
    manifest = due_continuation_manifest()
    manifest["workflows"][0]["graph"]["nodes"][1]["id"] = ""
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False

    manifest = due_continuation_manifest()
    manifest["workflows"][0]["graph"]["nodes"][1]["id"] = "changed"
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False

    manifest = due_continuation_manifest()
    manifest["workflows"][0]["graph"]["edges"][0]["target"] = "missing"
    facts, _, _ = MOD.manifest_facts(manifest)
    assert facts["due_continuation"] is False


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


def runtime_observations(**values):
    return {
        "real_clock": True,
        "evaluation_time_supplied": False,
        "direct_database_write": False,
        "scheduler_invoked": False,
        **values,
    }


def complete_bf06_certificates():
    return {
        "contract_version": "domainry-bf06-evaluator-certificates-v1",
        "handler": {
            "suite_id": "m1_req14_handler", "exit_code": 0,
            "command": ["go", "test", "./actions/crm"],
            "test_outcomes": {name: "pass" for name in MOD.BF06_HANDLER_TESTS},
            "output_sha256": "a" * 64, "source_sha256": "b" * 64,
            "project_handler_coverage": {
                "total_statements": 100, "covered_statements": 30,
                "profile_sha256": "5" * 64,
            },
        },
        "runtime_record_timer": {
            "suite_id": "m1_req14_runtime_record_timer", "exit_code": 0,
            "command": ["go", "test", "./tests/recordtimer"],
            "test_outcomes": {name: "pass" for name in MOD.BF06_RUNTIME_TIMER_TESTS},
            "output_sha256": "c" * 64, "source_sha256": "d" * 64,
            "runtime_dependencies": [
                "github.com/domainry/domainry-runtime/runtime/application/recordtimer",
            ],
            "dependency_command_exit_code": 0,
            "dependency_output_sha256": "e" * 64,
            "runtime_module_query_command": [
                "go", "list", "-m", "-json", "github.com/domainry/domainry-runtime",
            ],
            "runtime_module_query_exit_code": 0,
            "runtime_module_query_output_sha256": "f" * 64,
            "runtime_module_identity": {
                "Path": "github.com/domainry/domainry-runtime",
                "Version": "v0.0.0-source-deadbeef", "Sum": "h1:module",
                "GoModSum": "h1:gomod", "Main": False, "Replace": None,
                "Dir": "/private/tmp/go/pkg/mod/domainry-runtime",
                "GoMod": "/private/tmp/go/pkg/mod/cache/domainry-runtime.mod",
                "within_project_tree": False,
            },
            "runtime_delivery_binding": {
                "path": "github.com/domainry/domainry-runtime",
                "version": "v0.0.0-source-deadbeef",
                "zip_sha256": "1" * 64, "go_mod_sha256": "2" * 64,
                "binding_sha256": "3" * 64, "matches_resolved_module": True,
            },
            "runtime_record_timer_coverage": {
                "total_statements": 100, "covered_statements": 30,
                "profile_sha256": "4" * 64,
            },
            "hermetic_go_environment": {
                "GOPROXY": "file:///project/.domainry/builder/contracts/go-module-proxy",
                "GOFLAGS": "-mod=readonly -tags=domainry_domain_sdk_deadbeef",
                "GOWORK": "off", "GONOPROXY": "none", "GOSUMDB": "off",
            },
            "evaluator_runtime_probe": {
                "command": [
                    "go", "test", "-json", "-count=1", "./bf06evaluatorprobe-fixture",
                    "-run", "^TestM1Req14EvaluatorRuntimeSourceFieldDue$",
                ],
                "exit_code": 0, "test_outcome": "pass",
                "output_sha256": "6" * 64,
                "source_sha256": MOD.hashlib.sha256(
                    MOD.BF06_RUNTIME_PROBE_SOURCE.encode("utf-8")).hexdigest(),
                "source_owned_by_evaluator": True,
            },
        },
    }


def bf06_steps(phase):
    if phase == "initial":
        rows = {
            "lead.contacted.due.persisted": runtime_observations(
                record_id="lead-1", status="contacted",
                status_changed_at_persisted=True, next_followup_at_persisted=True,
                status_changed_at="2026-08-30T00:00:00+08:00",
                next_followup_at="2026-09-07T01:00:00Z",
                local_next_followup_at="2026-09-07T09:00:00+08:00",
                calculation_owner="project_handler", business_calendar_key="sales-workdays",
            ),
            "lead.contacted.no_immediate_reminder": runtime_observations(
                record_id="lead-1", next_followup_at="2026-09-07T01:00:00Z",
                observed_at="2026-08-30T00:00:01+08:00",
                reminder_count_before=0, reminder_count_after=0,
            ),
            "handler.followup_due.focused_tests": {
                "suite_id": "m1_req14_handler", "evaluator_certificate_required": True,
                "required_cases": sorted(MOD.BF06_HANDLER_TESTS),
            },
            "runtime.record_timer.integration_tests": {
                "suite_id": "m1_req14_runtime_record_timer",
                "evaluator_certificate_required": True,
                "required_cases": sorted(MOD.BF06_RUNTIME_TIMER_TESTS),
            },
        }
        sources = MOD.BF06_INITIAL_OPERATIONS
    else:
        rows = {
            "lead.contacted.due.restart_durable": runtime_observations(
                record_id="lead-1", status="contacted",
                status_changed_at="2026-08-30T00:00:00+08:00",
                next_followup_at="2026-09-07T01:00:00Z",
                read_after_restart=True, reminder_count=0,
            ),
            "handler.followup_due.focused_tests": {
                "suite_id": "m1_req14_handler", "evaluator_certificate_required": True,
                "required_cases": sorted(MOD.BF06_HANDLER_TESTS),
            },
            "runtime.record_timer.integration_tests": {
                "suite_id": "m1_req14_runtime_record_timer",
                "evaluator_certificate_required": True,
                "required_cases": sorted(MOD.BF06_RUNTIME_TIMER_TESTS),
            },
        }
        sources = MOD.BF06_RESTART_OPERATIONS
    return [{
        "id": operation.replace(".", "-"), "operation": operation,
        "source": sources[operation], "status": "passed", "requirements": ["14"],
        "observations": observations,
    } for operation, observations in rows.items()]


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
            if flow == "BF06":
                steps.extend(bf06_steps(phase))
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
        project, verify, complete_flow_evidence(), complete_bf06_certificates())
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


def test_bf06_accepts_combined_black_box_handler_and_runtime_timer_evidence():
    evidence = complete_flow_evidence()
    validity, diagnostics = MOD.validate_flow_evidence(
        evidence, complete_bf06_certificates())
    assert validity["initial"]["BF06"] is True
    assert validity["restart"]["BF06"] is True
    assert diagnostics["restart"]["BF06"] == []


def test_bf06_rejects_evaluation_time_and_immediate_reminder():
    evidence = complete_flow_evidence()
    steps = evidence["phases"]["initial"]["BF06"]["steps"]
    before = next(step for step in steps
                  if step["operation"] == "lead.contacted.no_immediate_reminder")
    before["observations"]["evaluation_time_supplied"] = True
    before["observations"]["reminder_count_after"] = 1
    before["observations"]["timer_id"] = "invented-internal-id"
    validity, diagnostics = MOD.validate_flow_evidence(
        evidence, complete_bf06_certificates())
    assert validity["initial"]["BF06"] is False
    assert any("evaluation_time_was_supplied" in row
               for row in diagnostics["initial"]["BF06"])
    assert any("immediate_reminder_created" in row
               for row in diagnostics["initial"]["BF06"])
    assert any("internal_timer_id_self_reported" in row
               for row in diagnostics["initial"]["BF06"])


def test_bf06_rejects_restart_lead_substitution():
    evidence = complete_flow_evidence()
    restored = next(
        step for step in evidence["phases"]["restart"]["BF06"]["steps"]
        if step["operation"] == "lead.contacted.due.restart_durable")
    restored["observations"]["record_id"] = "replacement-lead"
    validity, diagnostics = MOD.validate_flow_evidence(
        evidence, complete_bf06_certificates())
    assert validity["restart"]["BF06"] is False
    assert "bf06_restart_lead_identity_mismatch" in diagnostics["restart"]["BF06"]


def test_bf06_rejects_direct_database_write():
    evidence = complete_flow_evidence()
    steps = evidence["phases"]["initial"]["BF06"]["steps"]
    persisted = next(step for step in steps
                     if step["operation"] == "lead.contacted.due.persisted")
    persisted["observations"]["direct_database_write"] = True
    validity, diagnostics = MOD.validate_flow_evidence(
        evidence, complete_bf06_certificates())
    assert validity["initial"]["BF06"] is False
    assert any("direct_database_write_used" in row
               for row in diagnostics["initial"]["BF06"])


def test_bf06_rejects_failed_or_project_only_timer_certificate():
    evidence = complete_flow_evidence()
    certificates = complete_bf06_certificates()
    certificates["runtime_record_timer"]["runtime_dependencies"] = [
        "example.com/domainry-m1-crm/backend/tests/recordtimer",
    ]
    certificates["handler"]["test_outcomes"]["TestM1Req14DueCalculation"] = "fail"
    validity, diagnostics = MOD.validate_flow_evidence(evidence, certificates)
    assert validity["initial"]["BF06"] is False
    assert "bf06_runtime_package_dependency_missing" in diagnostics["initial"]["BF06"]
    assert "bf06_certificate_test_not_passed:m1_req14_handler" in diagnostics["initial"]["BF06"]


def test_bf06_rejects_main_replaced_or_project_local_runtime_module_identity():
    for mutation in (
        {"Main": True},
        {"Replace": {"Path": "../fake-runtime"}},
        {"within_project_tree": True},
    ):
        certificates = complete_bf06_certificates()
        certificates["runtime_record_timer"]["runtime_module_identity"].update(mutation)
        diagnostics = MOD.validate_bf06_certificates(certificates)
        assert "bf06_runtime_external_module_identity_invalid" in diagnostics


def test_bf06_go_environment_reuses_delivery_proxy_readonly_mode_and_sdk_tag(tmp_path):
    project = tmp_path / "project"
    backend = project / "backend"
    generated = backend / "generated/composition"
    generated.mkdir(parents=True)
    (generated / "build_target.gen.go").write_text(
        "//go:build domainry_domain_sdk_deadbeef\n\npackage composition\n")
    env = MOD.bf06_go_environment(project, backend, tmp_path / "build-cache",
                                  tmp_path / "module-cache")
    proxies = env["GOPROXY"].split(",")
    assert proxies[0].endswith("/.domainry/builder/contracts/go-module-proxy")
    assert all(proxy.startswith("file://") for proxy in proxies)
    assert env["GOFLAGS"] == "-mod=readonly -tags=domainry_domain_sdk_deadbeef"
    assert env["GOWORK"] == "off"


def test_bf06_evaluator_rejects_empty_tests_and_local_runtime_main_module(tmp_path):
    project = tmp_path / "project"
    backend = project / "backend"
    handler = backend / "actions/crm"
    timer = backend / "tests/recordtimer"
    runtime_package = backend / "workflow"
    handler.mkdir(parents=True)
    timer.mkdir(parents=True)
    runtime_package.mkdir(parents=True)
    (backend / "go.mod").write_text("module github.com/domainry/domainry-runtime\n\ngo 1.22\n")
    (runtime_package / "workflow.go").write_text("package workflow\n")
    (handler / "req14_test.go").write_text(
        "package crm\nimport \"testing\"\n" + "\n".join(
            f"func {name}(t *testing.T) {{}}" for name in sorted(MOD.BF06_HANDLER_TESTS)))
    (timer / "record_timer_test.go").write_text(
        "package recordtimer\n"
        "import (\n  _ \"github.com/domainry/domainry-runtime/workflow\"\n  \"testing\"\n)\n"
        + "\n".join(
            f"func {name}(t *testing.T) {{}}"
            for name in sorted(MOD.BF06_RUNTIME_TIMER_TESTS)))
    run_dir = tmp_path / "run"
    run_dir.mkdir()

    certificates = MOD.run_bf06_certificates(project, run_dir)

    diagnostics = MOD.validate_bf06_certificates(certificates)
    assert "bf06_handler_code_not_executed" in diagnostics
    assert "bf06_runtime_external_module_identity_invalid" in diagnostics
    assert "bf06_runtime_delivery_binding_invalid" in diagnostics
    assert "bf06_runtime_record_timer_not_executed" in diagnostics
    assert "bf06_evaluator_runtime_probe_invalid" in diagnostics
    assert (run_dir / "bf06-evaluator-certificates.json").is_file()
    assert set(certificates["handler"]["test_outcomes"]) == MOD.BF06_HANDLER_TESTS
    assert "github.com/domainry/domainry-runtime/workflow" in (
        certificates["runtime_record_timer"]["runtime_dependencies"])


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
