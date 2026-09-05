#!/usr/bin/env python3
"""Run the M1 final-delivery baseline without legacy contract hard-coding.

The evaluator keeps the frozen M01-M19 denominator.  It reconciles that
denominator against two independent inputs: the compiler-owned Runtime
manifest and real project-owned black-box business-flow execution.  The run
fails closed when the SQLite cohort contains non-seed lead residue before the
test, when a required manifest fact is absent, or when any required flow does
not pass.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import sqlite3
import subprocess
import sys
import time


FLOW_IDS = tuple(f"BF{i:02d}" for i in range(1, 9))
FLOW_TEST_PATTERN = re.compile(r"^Test(?P<flow>BF0[1-8])(?:$|[/_A-Z])")
FLOW_SOURCE_PATTERN = re.compile(r"\bfunc\s+Test(?P<flow>BF0[1-8])(?:$|[_A-Z])\w*\s*\(")
FLOW_EVIDENCE_CONTRACT = "domainry-business-flow-evidence-v1"
FLOW_PHASES = ("initial", "restart")
OPERATION_SOURCES = {
    "runtime.records",
    "runtime.action",
    "runtime.workflow",
    "runtime.scheduler",
    "runtime.report",
    "runtime.data_exchange",
    "runtime.identity",
    "runtime.navigation",
    "project_handler",
}
BF08_REQUIRED_OPERATIONS = {
    "report.prepare": "runtime.report",
    "report.prepare.unauthorized_denied": "runtime.report",
    "data_exchange.job.owner_bound": "runtime.data_exchange",
    "data_exchange.job.completed": "runtime.data_exchange",
    "data_exchange.job.download": "runtime.data_exchange",
    "data_exchange.job.foreign_download_denied": "runtime.data_exchange",
    "artifact.csv.content_validated": "runtime.data_exchange",
}
BF08_FORBIDDEN_OPERATIONS = {"records.csv_export"}

FEATURES = {
    "M01": ("P0", ["schema"], ["BF01"]),
    "M02": ("P0", ["lead_state_machine"], ["BF01", "BF02"]),
    "M03": ("P0", [], ["BF01"]),
    "M04": ("P0", ["advance_action"], ["BF01"]),
    "M05": ("P0", [], ["BF01"]),
    "M06": ("P0", [], ["BF02", "BF03"]),
    "M07": ("P0", ["approval_workflow"], ["BF03", "BF04"]),
    "M08": ("P0", [], ["BF02", "BF03"]),
    "M09": ("P1", [], ["BF03", "BF04"]),
    "M10": ("P0", [], ["BF02"]),
    "M11": ("P0", [], ["BF01", "BF05"]),
    "M12": ("P0", [], ["BF05"]),
    "M13": ("P1", [], ["BF01", "BF03", "BF04"]),
    "M14": ("P1", ["stale_scheduler"], ["BF06"]),
    "M15": ("P0", ["funnel_report"], ["BF07"]),
    "M16": ("P0", ["export_control"], ["BF08"]),
    "M17": ("P0", ["detail_report"], ["BF05"]),
    "M18": ("P1", [], ["BF05"]),
    "M19": ("P0", [], ["BF01", "BF05"]),
}

# Only features whose accepted design can be implemented through Runtime-owned
# metadata/platform capability belong in the B3 denominator. Conditional,
# transactional cross-object conversion handlers are project code by design.
REUSE_ELIGIBLE = {feature_id: feature_id not in {"M06", "M07"} for feature_id in FEATURES}
FACT_SOURCES = {
    "schema": "manifest.objects",
    "lead_state_machine": "manifest.state_machines",
    "advance_action": "manifest.state_machines",
    "approval_workflow": "manifest.workflows",
    "stale_scheduler": "manifest.scheduler_definitions",
    "funnel_report": "manifest.reports",
    "export_control": "manifest.report_export_controls",
    "detail_report": "manifest.report_export_controls",
}


def keyed(items):
    return {item.get("key"): item for item in items or [] if isinstance(item, dict)}


def field_map(obj):
    return keyed((obj or {}).get("fields"))


def permission_key(permission):
    """Return the canonical permission key from current or legacy manifests."""
    if isinstance(permission, str):
        return permission.split(";", 1)[0].strip()
    if isinstance(permission, dict):
        value = permission.get("permission_key") or permission.get("key")
        return value.strip() if isinstance(value, str) else ""
    return ""


def relation_target(field):
    return (field.get("target_object_key")
            or (field.get("config") or {}).get("object_key")
            or (field.get("config") or {}).get("target")
            or (field.get("validation") or {}).get("target"))


def option_labels(field):
    return {
        option.get("label")
        for option in field.get("options") or []
        if isinstance(option, dict) and isinstance(option.get("label"), str)
    }


def scale_is_two(field):
    config = field.get("config") or {}
    return (field.get("type") == "currency"
            and int(config.get("scale", field.get("scale", -1))) == 2)


def has_source_business_semantics(field):
    options = field.get("options") or []
    labels = option_labels(field)
    values = {item.get("value", item) if isinstance(item, dict) else item for item in options}
    return (
        labels == {"官网", "展会", "转介绍", "外呼"}
        or (not labels and values == {"website", "exhibition", "referral", "outbound"})
    )


def workflow_actions(workflow):
    nodes = ((workflow.get("graph") or {}).get("nodes") or [])
    return [((node.get("contract") or {}).get("action") or {})
            for node in nodes if node.get("type") == "action"]


def is_approval_workflow(workflow, object_key):
    graph = workflow.get("graph") or {}
    nodes = graph.get("nodes") or []
    edges = graph.get("edges") or []
    branches = {edge.get("branch") for edge in edges}
    trigger = workflow.get("trigger_contract") or {}
    return (
        workflow.get("enabled") is True
        and trigger.get("object_key") == object_key
        and any(node.get("type") == "approval" for node in nodes)
        and {"approved", "rejected"} <= branches
        and any(action.get("object_key") == object_key for action in workflow_actions(workflow))
    )


def is_weekday_morning_cron(expression):
    if not isinstance(expression, str):
        return False
    parts = expression.split()
    if len(parts) != 5:
        return False
    minute, hour, _, _, weekday = parts
    try:
        hour_number = int(hour)
    except ValueError:
        return False
    return (minute == "0" and 5 <= hour_number < 12
            and weekday.upper() in {"1-5", "1,2,3,4,5", "MON-FRI"})


def control_is_structurally_valid(control, objects, reports, lead_key):
    report = reports.get(control.get("report_key"))
    audit = objects.get(control.get("audit_object"))
    download = objects.get(control.get("download_object"))
    mapping = control.get("record_mapping") or {}
    audit_fields = set(field_map(audit))
    download_fields = set(field_map(download))
    mapped_audit = [value for key, value in mapping.items()
                    if key.startswith("audit_") and key.endswith("_field")]
    mapped_download = [value for key, value in mapping.items()
                       if key.startswith("download_") and key.endswith("_field")]
    return (
        isinstance(report, dict)
        and lead_key in ((report.get("object_sql_v1") or {}).get("source_objects") or [])
        and isinstance(audit, dict)
        and isinstance(download, dict)
        and mapped_audit and all(value in audit_fields for value in mapped_audit)
        and mapped_download and all(value in download_fields for value in mapped_download)
        and isinstance(control.get("max_rows"), int)
        and 0 < control["max_rows"] <= 10000
    )


def manifest_facts(manifest):
    objects = keyed(manifest.get("objects"))
    workflows = keyed(manifest.get("workflows"))
    schedules = keyed(manifest.get("scheduler_definitions"))
    reports = keyed(manifest.get("reports"))
    state_machines = keyed(manifest.get("state_machines"))
    lifecycle_states = {"new", "contacted", "qualified", "converted", "lost"}
    lifecycle_candidates = [
        value for value in state_machines.values()
        if set(value.get("states") or []) == lifecycle_states
    ]
    lead_sm = lifecycle_candidates[0] if len(lifecycle_candidates) == 1 else {}
    lead_key = lead_sm.get("object_key")
    lead_fields = field_map(objects.get(lead_key))
    source_candidates = [field for field in lead_fields.values()
                         if field.get("type") == "select"
                         and has_source_business_semantics(field)]
    source = source_candidates[0] if len(source_candidates) == 1 else {}
    source_options = source.get("options", [])
    source_values = {o.get("value", o) if isinstance(o, dict) else o
                     for o in source_options}
    source_labels = {o.get("label") for o in source_options
                     if isinstance(o, dict) and isinstance(o.get("label"), str)}
    # requirements.md specifies the four business labels, not their internal
    # storage keys. Prefer the compiled labels and retain the historical key
    # set only for manifests that do not carry localized option metadata.
    source_semantics = (
        source_labels == {"官网", "展会", "转介绍", "外呼"}
        or (not source_labels
            and source_values == {"website", "exhibition", "referral", "outbound"})
    )
    amounts = [value for value in lead_fields.values() if scale_is_two(value)]
    required_texts = [value for value in lead_fields.values()
                      if value.get("type") == "text" and value.get("required") is True]
    states = set(lead_sm.get("states") or [])
    terminals = set(lead_sm.get("terminal_states") or [])
    transitions = {(row.get("from"), row.get("to")) for row in lead_sm.get("transitions") or []}
    seeds = manifest.get("seed_records") or []
    lead_seeds = [s for s in seeds if s.get("object_key") == lead_key]

    approval_workflow = any(is_approval_workflow(workflow, lead_key)
                            for workflow in workflows.values())
    scheduled_workflow_keys = {
        key for key, workflow in workflows.items()
        if (workflow.get("trigger_contract") or {}).get("type") == "scheduled"
        and any(action.get("object_key") == lead_key for action in workflow_actions(workflow))
    }
    stale_scheduler = any(
        schedule.get("status") == "enabled"
        and schedule.get("target_type") == "workflow"
        and str(schedule.get("target_key", "")).removeprefix("scheduled:") in scheduled_workflow_keys
        and is_weekday_morning_cron(schedule.get("schedule_expression"))
        for schedule in schedules.values()
    )
    funnel_reports = [
        report for report in reports.values()
        if lead_key in ((report.get("object_sql_v1") or {}).get("source_objects") or [])
        and any(field.get("kind") == "measure" and field.get("type") == "integer"
                for field in (report.get("object_sql_v1") or {}).get("result_schema") or [])
        and any(field.get("kind") == "measure" and scale_is_two(field)
                for field in (report.get("object_sql_v1") or {}).get("result_schema") or [])
        and any(field.get("kind") == "dimension"
                for field in (report.get("object_sql_v1") or {}).get("result_schema") or [])
    ]
    valid_controls = [control for control in manifest.get("report_export_controls") or []
                      if control_is_structurally_valid(control, objects, reports, lead_key)]

    return {
        "schema": (len(required_texts) >= 1
                   and len(amounts) == 1
                   and source.get("type") == "select"
                   and len(source_values) == 4
                   and source_semantics),
        "lead_state_machine": (states == lifecycle_states
                               and terminals == {"converted", "lost"}),
        "advance_action": {("new", "contacted"), ("contacted", "qualified")} <= transitions,
        "approval_workflow": approval_workflow,
        "stale_scheduler": stale_scheduler,
        "funnel_report": bool(funnel_reports),
        "export_control": bool(valid_controls),
        "detail_report": bool(valid_controls),
    }, lead_key, len(lead_seeds)


def assert_fresh_sqlite(db_path, lead_table, expected_lead_seeds):
    if not lead_table or not lead_table.replace("_", "").isalnum():
        raise RuntimeError("fresh-cohort check failed: manifest lead object is absent or unsafe")
    with sqlite3.connect(db_path) as conn:
        tables = {r[0] for r in conn.execute("SELECT name FROM sqlite_master WHERE type='table'")}
        if lead_table not in tables:
            raise RuntimeError(f"fresh-cohort check failed: {lead_table} table is absent")
        actual = conn.execute(f'SELECT COUNT(*) FROM "{lead_table}"').fetchone()[0]
    if actual != expected_lead_seeds:
        raise RuntimeError(
            f"fresh-cohort check failed: lead rows={actual}, frozen seeds={expected_lead_seeds}; "
            "create a new evaluator cohort instead of reusing acceptance residue")


def parse_flow_outcomes(output):
    """Read public BF IDs from Go test events without fixing test prose names.

    A delivery may split one BF ID across several top-level tests. Every
    terminal event for that ID must pass, and all eight IDs must be present.
    """
    terminal = {key: [] for key in FLOW_IDS}
    for line in output.splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        name = event.get("Test")
        match = FLOW_TEST_PATTERN.match(name) if isinstance(name, str) else None
        if match and event.get("Action") in {"pass", "fail"}:
            terminal[match.group("flow")].append(event["Action"])
    return {
        key: bool(actions) and all(action == "pass" for action in actions)
        for key, actions in terminal.items()
    }


def parse_flow_evidence(output):
    """Extract structured BF evidence markers from ``go test -json`` output.

    Tests emit one line per phase/flow as
    ``DOMAINRY_BF_EVIDENCE={...}``. Resource keys and HTTP paths remain opaque;
    the evaluator consumes stable operation/source families and public
    requirement IDs only.
    """
    phases = {phase: {} for phase in FLOW_PHASES}
    for line in output.splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        raw = event.get("Output") if isinstance(event, dict) else None
        if not isinstance(raw, str) or "DOMAINRY_BF_EVIDENCE=" not in raw:
            continue
        encoded = raw.split("DOMAINRY_BF_EVIDENCE=", 1)[1].strip()
        try:
            row = json.loads(encoded)
        except json.JSONDecodeError:
            continue
        phase, flow = row.get("phase"), row.get("flow_id")
        if phase in phases and flow in FLOW_IDS:
            phases[phase][flow] = row
    return {"contract_version": FLOW_EVIDENCE_CONTRACT, "phases": phases}


def validate_bf08_steps(steps):
    diagnostics = []
    by_operation = {
        step.get("operation"): step for step in steps if isinstance(step, dict)
    }
    if BF08_FORBIDDEN_OPERATIONS & set(by_operation):
        diagnostics.append("direct_records_csv_is_not_governed_export")
    for operation, source in BF08_REQUIRED_OPERATIONS.items():
        if by_operation.get(operation, {}).get("source") != source:
            diagnostics.append(f"required_operation_missing:{operation}")
    if diagnostics:
        return diagnostics

    def observations(operation):
        value = by_operation[operation].get("observations")
        return value if isinstance(value, dict) else {}

    job_operations = (
        "report.prepare", "data_exchange.job.owner_bound",
        "data_exchange.job.completed", "data_exchange.job.download",
    )
    job_ids = [observations(operation).get("job_id") for operation in job_operations]
    if not all(isinstance(job_id, str) and job_id for job_id in job_ids):
        diagnostics.append("bf08_job_identity_missing")
    elif len(set(job_ids)) != 1:
        diagnostics.append("bf08_job_identity_mismatch")
    if observations("report.prepare").get("accepted") is not True:
        diagnostics.append("bf08_report_prepare_not_accepted")
    prepare_denied = observations("report.prepare.unauthorized_denied")
    if not (prepare_denied.get("access_denied") is True
            and prepare_denied.get("different_actor") is True):
        diagnostics.append("bf08_unauthorized_prepare_not_denied")
    if observations("data_exchange.job.owner_bound").get("requester_owned") is not True:
        diagnostics.append("bf08_job_not_requester_owned")
    if observations("data_exchange.job.completed").get("job_status") != "completed":
        diagnostics.append("bf08_job_not_completed")
    download = observations("data_exchange.job.download")
    if not (
        download.get("actual_job_download") is True
        and isinstance(download.get("byte_count"), int)
        and download["byte_count"] > 0
        and "text/csv" in str(download.get("content_type", "")).lower()
    ):
        diagnostics.append("bf08_job_download_not_proven")
    denied = observations("data_exchange.job.foreign_download_denied")
    if not (denied.get("access_denied") is True and denied.get("different_actor") is True):
        diagnostics.append("bf08_foreign_denial_not_proven")
    content = observations("artifact.csv.content_validated")
    if not (
        content.get("csv_parsed") is True
        and content.get("row_count_matches_report") is True
        and content.get("content_hash_verified") is True
    ):
        diagnostics.append("bf08_csv_content_not_proven")
    return diagnostics


def validate_flow_evidence(document):
    """Validate evidence and return per-phase/flow facts plus diagnostics."""
    valid = {phase: {flow: False for flow in FLOW_IDS} for phase in FLOW_PHASES}
    diagnostics = {phase: {flow: [] for flow in FLOW_IDS} for phase in FLOW_PHASES}
    if not isinstance(document, dict) or document.get("contract_version") != FLOW_EVIDENCE_CONTRACT:
        for phase in FLOW_PHASES:
            for flow in FLOW_IDS:
                diagnostics[phase][flow].append("evidence_contract_missing_or_invalid")
        return valid, diagnostics
    phases = document.get("phases")
    if not isinstance(phases, dict):
        return valid, diagnostics
    for phase in FLOW_PHASES:
        rows = phases.get(phase)
        if not isinstance(rows, dict):
            continue
        for flow in FLOW_IDS:
            row = rows.get(flow)
            if not isinstance(row, dict):
                diagnostics[phase][flow].append("flow_evidence_missing")
                continue
            steps = row.get("steps")
            if row.get("status") != "passed":
                diagnostics[phase][flow].append("flow_status_not_passed")
            if not isinstance(steps, list) or not steps:
                diagnostics[phase][flow].append("steps_missing")
                continue
            for step in steps:
                if not isinstance(step, dict):
                    diagnostics[phase][flow].append("step_invalid")
                    continue
                requirements = step.get("requirements")
                if not isinstance(requirements, list) or not requirements or not all(
                    isinstance(value, str) and value for value in requirements
                ):
                    diagnostics[phase][flow].append("step_requirements_missing")
                if not isinstance(step.get("id"), str) or not step["id"]:
                    diagnostics[phase][flow].append("step_id_missing")
                if not isinstance(step.get("operation"), str) or not step["operation"]:
                    diagnostics[phase][flow].append("step_operation_missing")
                if step.get("source") not in OPERATION_SOURCES:
                    diagnostics[phase][flow].append("step_source_invalid")
                if step.get("status") != "passed":
                    diagnostics[phase][flow].append("step_not_passed")
                if not isinstance(step.get("observations"), dict):
                    diagnostics[phase][flow].append("step_observations_missing")
            if flow == "BF08":
                diagnostics[phase][flow].extend(validate_bf08_steps(steps))
            valid[phase][flow] = row.get("status") == "passed" and not diagnostics[phase][flow]
    return valid, diagnostics


def flow_evidence_shape_valid(document):
    if not isinstance(document, dict) or document.get("contract_version") != FLOW_EVIDENCE_CONTRACT:
        return False
    phases = document.get("phases")
    if not isinstance(phases, dict):
        return False
    for phase in FLOW_PHASES:
        rows = phases.get(phase)
        if not isinstance(rows, dict):
            return False
        for flow in FLOW_IDS:
            row = rows.get(flow)
            if not isinstance(row, dict) or row.get("status") not in {"passed", "failed"}:
                return False
            steps = row.get("steps")
            if not isinstance(steps, list) or not steps:
                return False
            for step in steps:
                if not isinstance(step, dict) or step.get("status") not in {"passed", "failed"}:
                    return False
                if not all(isinstance(step.get(key), str) and step[key]
                           for key in ("id", "operation")):
                    return False
                if step.get("source") not in OPERATION_SOURCES:
                    return False
                requirements = step.get("requirements")
                if not isinstance(requirements, list) or not requirements or not all(
                    isinstance(requirement, str) and requirement for requirement in requirements
                ):
                    return False
                if not isinstance(step.get("observations"), dict):
                    return False
    return True


def evidence_steps(document, phase, flow, requirement=None):
    row = (((document or {}).get("phases") or {}).get(phase) or {}).get(flow) or {}
    steps = row.get("steps") or []
    if requirement is None:
        return steps
    return [step for step in steps if requirement in (step.get("requirements") or [])]


def requirement_evidence_ok(document, flow_validity, flow, requirement):
    return all(
        flow_validity[phase][flow]
        and bool(evidence_steps(document, phase, flow, requirement))
        for phase in FLOW_PHASES
    )


def bf08_is_silent_downgrade(flow_diagnostics):
    diagnostics = [
        diagnostic
        for phase in FLOW_PHASES
        for diagnostic in flow_diagnostics[phase]["BF08"]
    ]
    downgrade_diagnostics = {
        "evidence_contract_missing_or_invalid",
        "flow_evidence_missing",
        "steps_missing",
        "step_operation_missing",
        "step_source_invalid",
        "step_observations_missing",
        "direct_records_csv_is_not_governed_export",
        "bf08_job_identity_missing",
        "bf08_job_identity_mismatch",
        "bf08_report_prepare_not_accepted",
        "bf08_unauthorized_prepare_not_denied",
        "bf08_job_not_requester_owned",
        "bf08_job_not_completed",
        "bf08_job_download_not_proven",
        "bf08_foreign_denial_not_proven",
        "bf08_csv_content_not_proven",
    }
    return any(
        diagnostic in downgrade_diagnostics
        or diagnostic.startswith("required_operation_missing:")
        for diagnostic in diagnostics
    )


def run_flows(project, base_url, bootstrap_password, acceptance_password, log_path):
    backend = project / "backend"
    env = os.environ.copy()
    env.update({
        "DOMAINRY_RUNTIME_URL": base_url,
        "CRM_RUNTIME_URL": base_url,
        "DOMAINRY_ACCEPTANCE_BOOTSTRAP_PASSWORD": bootstrap_password,
        "DOMAINRY_ACCEPTANCE_PASSWORD": acceptance_password,
    })
    proc = subprocess.run(
        ["go", "test", "-json", "-count=1", "./tests/businessflow"],
        cwd=backend, env=env, text=True, stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT, check=False)
    log_path.write_text(proc.stdout)
    return parse_flow_outcomes(proc.stdout), proc.returncode, parse_flow_evidence(proc.stdout)


def declared_flow_ids(project):
    root = project / "backend/tests/businessflow"
    found = set()
    if not root.is_dir() or root.is_symlink():
        return found
    for path in root.rglob("*_test.go"):
        if path.is_symlink() or not path.is_file():
            continue
        for match in FLOW_SOURCE_PATTERN.finditer(path.read_text(encoding="utf-8")):
            found.add(match.group("flow"))
    return found


def traced_flow_ids(project):
    traceability = project / "docs/backend-requirements-prd.md"
    if not traceability.is_file() or traceability.is_symlink():
        return set()
    return set(re.findall(r"\bBF0[1-8]\b", traceability.read_text(encoding="utf-8")))


def verified_flow_outcomes(project, raw_result, structured_evidence):
    """Reconcile BF IDs with the current CLI verify lifecycle proof.

    Current Builder ``verify`` runs one compiled business-flow binary against
    the initial Runtime and the same database cohort after restart, then stops
    the Runtime. The evaluator therefore consumes that proof instead of
    requiring the Agent to leave an extra Runtime running.
    """
    result = raw_result.get("output") if isinstance(raw_result, dict) else None
    if not isinstance(result, dict):
        result = raw_result
    runtime = result.get("runtime") if isinstance(result, dict) else None
    runtime = runtime if isinstance(runtime, dict) else {}
    initial = runtime.get("initial_start") or {}
    restart = runtime.get("restart") or {}
    initial_stop = runtime.get("initial_stop") or {}
    final_stop = runtime.get("final_stop") or {}
    initial_flow = runtime.get("initial_business_flow") or {}
    restart_flow = runtime.get("restart_business_flow") or {}
    identity_keys = (
        "database_identity_sha256", "package_receipt_sha256",
        "verification_receipt_sha256", "project_source_tree_sha256",
        "runtime_manifest_sha256",
    )
    identities_match = all(
        initial.get(key)
        and initial.get(key) == initial_stop.get(key) == restart.get(key) == final_stop.get(key)
        for key in identity_keys
    )
    proof_ok = (
        isinstance(result, dict)
        and result.get("state") == "verified_and_stopped"
        and initial.get("state") == "running"
        and initial.get("healthy") is True
        and restart.get("state") == "running"
        and restart.get("healthy") is True
        and initial.get("cohort_state") == "current"
        and initial_stop.get("cohort_state") == "current"
        and restart.get("cohort_state") == "current"
        and final_stop.get("cohort_state") == "current"
        and initial_stop.get("state") == "stopped"
        and initial_stop.get("stopped_at")
        and final_stop.get("state") == "stopped"
        and final_stop.get("stopped_at")
        and initial_flow.get("status") == "passed"
        and restart_flow.get("status") == "passed"
        and initial_flow.get("binary_sha256")
        and initial_flow.get("binary_sha256") == restart_flow.get("binary_sha256")
        and initial_flow.get("delivery_id")
        and initial_flow.get("delivery_id") == restart_flow.get("delivery_id")
        and identities_match
    )
    declared = declared_flow_ids(project)
    traced = traced_flow_ids(project)
    flow_validity, flow_diagnostics = validate_flow_evidence(structured_evidence)
    outcomes = {
        flow: (
            proof_ok
            and flow in declared
            and flow in traced
            and all(flow_validity[phase][flow] for phase in FLOW_PHASES)
        )
        for flow in FLOW_IDS
    }
    evidence = {
        "verify_state": result.get("state") if isinstance(result, dict) else None,
        "proof_ok": proof_ok,
        "declared_flow_ids": sorted(declared),
        "traced_flow_ids": sorted(traced),
        "initial_business_flow_status": initial_flow.get("status"),
        "restart_business_flow_status": restart_flow.get("status"),
        "same_cohort_identity": identities_match,
        "final_runtime_state": final_stop.get("state"),
        "structured_evidence_contract": (
            structured_evidence.get("contract_version")
            if isinstance(structured_evidence, dict) else None
        ),
        "structured_phase_flow_validity": flow_validity,
        "structured_phase_flow_diagnostics": flow_diagnostics,
    }
    return outcomes, (0 if proof_ok and all(outcomes.values()) else 1), evidence, flow_validity


def mechanism_for_feature(feature_id, required_facts, required_flows, structured_evidence):
    requirement = str(int(feature_id[1:]))
    sources = {FACT_SOURCES[fact] for fact in required_facts if fact in FACT_SOURCES}
    for phase in FLOW_PHASES:
        for flow in required_flows:
            sources.update(
                step.get("source")
                for step in evidence_steps(structured_evidence, phase, flow, requirement)
                if step.get("source")
            )
    has_project_code = "project_handler" in sources
    has_runtime_capability = any(
        source.startswith("runtime.") or source.startswith("manifest.")
        for source in sources
    )
    mechanism = "custom" if has_project_code else "reuse"
    classification = "hybrid" if has_project_code and has_runtime_capability else mechanism
    return mechanism, {
        "classification": classification,
        "evidence_sources": sorted(sources),
        "reason": (
            "project-owned handler and Runtime-owned capability both participate"
            if classification == "hybrid"
            else "project-owned handler is the only evidenced implementation source"
            if mechanism == "custom"
            else "only Runtime-owned manifest and operation sources participate"
        ),
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--project", required=True, type=Path)
    parser.add_argument("--run-dir", required=True, type=Path)
    parser.add_argument("--verify-result", type=Path,
                        help="current domainry-cli verify JSON (preferred)")
    parser.add_argument(
        "--flow-evidence", type=Path,
        help=("domainry-business-flow-evidence-v1 document for initial and restart phases; "
              "required for a passing v3 result"),
    )
    parser.add_argument("--base-url", help="legacy live-Runtime mode")
    parser.add_argument("--database", type=Path, help="legacy live-Runtime mode")
    parser.add_argument("--bootstrap-password", help="legacy live-Runtime mode")
    parser.add_argument("--acceptance-password", help="legacy live-Runtime mode")
    args = parser.parse_args()

    manifest_path = args.project / ".domainry/builder/project-delivery/runtime-manifest.json"
    manifest = json.loads(manifest_path.read_text())
    facts, lead_table, seed_count = manifest_facts(manifest)
    args.run_dir.mkdir(parents=True, exist_ok=True)
    log_path = args.run_dir / "m1-businessflow-events.jsonl"
    structured_evidence = (
        json.loads(args.flow_evidence.read_text(encoding="utf-8"))
        if args.flow_evidence else None
    )
    if args.verify_result:
        verify_result = json.loads(args.verify_result.read_text(encoding="utf-8"))
        flows, exit_code, flow_evidence, flow_validity = verified_flow_outcomes(
            args.project, verify_result, structured_evidence)
    else:
        live = (args.base_url, args.database, args.bootstrap_password, args.acceptance_password)
        if not all(live):
            parser.error("use --verify-result or provide all legacy live-Runtime arguments")
        assert_fresh_sqlite(args.database, lead_table, seed_count)
        flows, exit_code, captured_evidence = run_flows(
            args.project, args.base_url, args.bootstrap_password,
            args.acceptance_password, log_path)
        structured_evidence = structured_evidence or captured_evidence
        flow_validity, diagnostics = validate_flow_evidence(structured_evidence)
        flows = {
            flow: flows[flow] and all(flow_validity[phase][flow] for phase in FLOW_PHASES)
            for flow in FLOW_IDS
        }
        flow_evidence = {
            "mode": "legacy_live_runtime",
            "log": str(log_path),
            "structured_phase_flow_validity": flow_validity,
            "structured_phase_flow_diagnostics": diagnostics,
        }

    results = []
    for feature_id, (priority, required_facts, required_flows) in FEATURES.items():
        fact_state = {key: bool(facts.get(key)) for key in required_facts}
        requirement = str(int(feature_id[1:]))
        flow_state = {
            key: bool(flows.get(key))
            and requirement_evidence_ok(structured_evidence, flow_validity, key, requirement)
            for key in required_flows
        }
        ok = all(fact_state.values()) and all(flow_state.values())
        mechanism, mechanism_detail = mechanism_for_feature(
            feature_id, required_facts, required_flows, structured_evidence)
        silent_downgrade = False
        if feature_id == "M16":
            silent_downgrade = bf08_is_silent_downgrade(
                flow_evidence["structured_phase_flow_diagnostics"])
        results.append({
            "id": feature_id, "priority": priority,
            "status": "pass" if ok else "fail",
            "mechanism": mechanism,
            "reuse_eligible": REUSE_ELIGIBLE[feature_id],
            "mechanism_detail": mechanism_detail,
            "silent_downgrade": silent_downgrade,
            "evidence": {
                "manifest_facts": fact_state,
                "manifest_fact_sources": {
                    key: FACT_SOURCES.get(key) for key in required_facts
                },
                "business_flows": flow_state,
                "requirement_id": requirement,
                "structured_steps": {
                    phase: {
                        flow: evidence_steps(structured_evidence, phase, flow, requirement)
                        for flow in required_flows
                    }
                    for phase in FLOW_PHASES
                },
            },
        })
    passed = all(row["status"] == "pass" for row in results) and exit_code == 0
    output = {
        "contract_version": "domainry-m1-evaluator-result-v3",
        "pass": passed,
        "runtime_manifest": str(manifest_path),
        "fresh_cohort_seed_rows": seed_count,
        "business_flow_exit_code": exit_code,
        "business_flows": flows,
        "business_flow_evidence": flow_evidence,
        "structured_business_flow_evidence": (
            structured_evidence
            if flow_evidence_shape_valid(structured_evidence)
            else None
        ),
        "rejected_structured_business_flow_evidence": (
            structured_evidence
            if structured_evidence is not None
            and not flow_evidence_shape_valid(structured_evidence)
            else None
        ),
        "results": results,
        "generated_epoch": int(time.time()),
    }
    out_path = args.run_dir / "checklist-results.json"
    out_path.write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps(output, ensure_ascii=False, indent=2))
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
