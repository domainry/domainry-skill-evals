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
from datetime import datetime, timedelta
import hashlib
import json
import os
from pathlib import Path
import re
import sqlite3
import subprocess
import sys
import tempfile
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
    "runtime.record_timer",
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
BF06_HANDLER_TESTS = {
    "TestM1Req14DueCalculation",
    "TestM1Req14EnterContactedPersistsDue",
    "TestM1Req14ExitContactedClearsDue",
    "TestM1Req14DueActionIdempotentContinuation",
    "TestM1Req14ExitedStateNoop",
}
BF06_RUNTIME_TIMER_TESTS = {
    "TestM1Req14RuntimeRecordTimerExactDue",
    "TestM1Req14RuntimeRecordTimerRestartRecovery",
}
BF06_RUNTIME_MODULE = "github.com/domainry/domainry-runtime"
BF06_RUNTIME_COVER_PACKAGES = (
    "github.com/domainry/domainry-runtime/runtime/application/recordtimer",
    "github.com/domainry/domainry-runtime/runtime/domain/recordtimer/...",
)
BF06_RUNTIME_PROBE_TEST = "TestM1Req14EvaluatorRuntimeSourceFieldDue"
BF06_RUNTIME_PROBE_SOURCE = r'''package runtimeprobe

import (
	"context"
	"testing"
	"time"

	recordtimer "github.com/domainry/domainry-runtime/runtime/application/recordtimer"
	recordmodel "github.com/domainry/domainry-runtime/runtime/domain/record/model"
	recordtimermodel "github.com/domainry/domainry-runtime/runtime/domain/recordtimer/model"
	recordtimerpolicy "github.com/domainry/domainry-runtime/runtime/domain/recordtimer/policy"
)

func TestM1Req14EvaluatorRuntimeSourceFieldDue(t *testing.T) {
	due, err := time.Parse(time.RFC3339Nano, "2026-09-14T09:00:00+08:00")
	if err != nil {
		t.Fatal(err)
	}
	request := recordtimermodel.Schedule{
		TimerKey: "m1-req14", ObjectKey: "lead", RecordID: "lead-1",
		Purpose: "followup", ScheduleMode: "relative_field",
		SourceField: "next_followup_at", OffsetSeconds: 0,
		Timezone: "Asia/Shanghai", TargetType: "action",
		TargetKey: "lead.continue_due",
	}
	resolved, err := recordtimerpolicy.ResolveSchedule(
		context.Background(), request,
		recordmodel.Record{Data: map[string]any{
			"next_followup_at": due.Format(time.RFC3339Nano),
		}}, recordtimerpolicy.StandardBusinessCalendar{})
	if err != nil {
		t.Fatal(err)
	}
	if !resolved.DueAt.Equal(due) || resolved.OffsetSeconds != 0 ||
		resolved.SourceField != "next_followup_at" {
		t.Fatalf("Runtime did not preserve the exact source-field due: %#v", resolved)
	}
	if config := recordtimer.DefaultWorkerConfig(); !config.Enabled || config.PollInterval <= 0 {
		t.Fatalf("Runtime record-timer worker is not enabled: %#v", config)
	}
}
'''
BF06_INITIAL_OPERATIONS = {
    "lead.contacted.due.persisted": "runtime.action",
    "lead.contacted.no_immediate_reminder": "runtime.records",
    "handler.followup_due.focused_tests": "project_handler",
    "runtime.record_timer.integration_tests": "runtime.record_timer",
}
BF06_RESTART_OPERATIONS = {
    "lead.contacted.due.restart_durable": "runtime.records",
    "handler.followup_due.focused_tests": "project_handler",
    "runtime.record_timer.integration_tests": "runtime.record_timer",
}

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
    "M14": ("P1", ["due_continuation"], ["BF06"]),
    "M15": ("P0", ["funnel_report"], ["BF07"]),
    "M16": ("P0", ["export_control"], ["BF08"]),
    "M17": ("P0", ["detail_report"], ["BF05"]),
    "M18": ("P1", [], ["BF05"]),
    "M19": ("P0", [], ["BF01", "BF05"]),
}

# Only features whose accepted design can be implemented through Runtime-owned
# metadata/platform capability belong in the B3 denominator. Conditional,
# transactional cross-object conversion handlers are project code by design.
REUSE_ELIGIBLE = {
    feature_id: feature_id not in {"M06", "M07", "M14"}
    for feature_id in FEATURES
}
FACT_SOURCES = {
    "schema": "manifest.objects",
    "lead_state_machine": "manifest.state_machines",
    "advance_action": "manifest.state_machines",
    "approval_workflow": "manifest.workflows",
    "due_continuation": "manifest.workflow_record_timer",
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


def walk_json(value):
    """Yield every nested ``(key, value)`` pair from JSON-like metadata."""
    if isinstance(value, dict):
        for key, child in value.items():
            yield str(key), child
            yield from walk_json(child)
    elif isinstance(value, list):
        for child in value:
            yield from walk_json(child)


def values_for_key_fragment(value, fragment):
    fragment = fragment.lower()
    return [child for key, child in walk_json(value) if fragment in key.lower()]


def scalar_values(values):
    flattened = []
    pending = list(values)
    while pending:
        value = pending.pop()
        if isinstance(value, list):
            pending.extend(value)
        elif isinstance(value, dict):
            pending.extend(value.values())
        else:
            flattened.append(value)
    return flattened


def workflow_trigger_contract(workflow):
    return workflow.get("trigger_contract") or workflow.get("trigger") or {}


def is_record_change_trigger(trigger, object_key, source_field):
    trigger_type = str(trigger.get("type", "")).lower()
    event_values = [str(value).lower() for value in values_for_key_fragment(trigger, "event")]
    event_driven = (
        trigger_type in {
            "field_changed", "record_changed", "record_updated", "state_changed",
            "state_transition", "object_event", "record_event",
        }
        or (any(token in trigger_type for token in ("field", "record", "state", "object"))
            and any(token in trigger_type for token in ("change", "update", "transition", "event")))
        or any(token in value for value in event_values
               for token in ("change", "update", "transition"))
    )
    object_values = scalar_values(values_for_key_fragment(trigger, "object_key"))
    field_values = scalar_values(
        values_for_key_fragment(trigger, "field_key")
        + values_for_key_fragment(trigger, "source_field")
        + values_for_key_fragment(trigger, "changed_field")
    )
    return (
        event_driven
        and trigger_type not in {"scheduled", "manual"}
        and object_key in object_values
        and source_field in field_values
    )


def graph_has_path(edges, start_ids, target_ids):
    adjacency = {}
    for edge in edges:
        if not isinstance(edge, dict):
            continue
        adjacency.setdefault(edge.get("source"), set()).add(edge.get("target"))
    pending = list(start_ids)
    visited = set()
    while pending:
        node_id = pending.pop()
        if node_id in visited:
            continue
        if node_id in target_ids:
            return True
        visited.add(node_id)
        pending.extend(adjacency.get(node_id, ()))
    return False


def validated_workflow_graph(graph):
    """Return normalized Graph V2 parts or None for malformed topology."""
    if not isinstance(graph, dict) or graph.get("version") != 2:
        return None
    nodes = graph.get("nodes")
    edges = graph.get("edges")
    if not isinstance(nodes, list) or not nodes or not isinstance(edges, list):
        return None
    node_ids = []
    for node in nodes:
        node_id = node.get("id") if isinstance(node, dict) else None
        if not isinstance(node_id, str) or not node_id.strip():
            return None
        node_ids.append(node_id.strip())
    if len(node_ids) != len(set(node_ids)):
        return None
    known_nodes = set(node_ids)
    edge_ids = []
    normalized_edges = []
    for edge in edges:
        if not isinstance(edge, dict):
            return None
        edge_id = edge.get("id")
        source = edge.get("source")
        target = edge.get("target")
        if not all(isinstance(value, str) and value.strip()
                   for value in (edge_id, source, target)):
            return None
        edge_id, source, target = edge_id.strip(), source.strip(), target.strip()
        if source not in known_nodes or target not in known_nodes or source == target:
            return None
        edge_ids.append(edge_id)
        normalized = dict(edge)
        normalized.update({"id": edge_id, "source": source, "target": target})
        normalized_edges.append(normalized)
    if len(edge_ids) != len(set(edge_ids)):
        return None
    node_by_id = {node_id: node for node_id, node in zip(node_ids, nodes)}
    for node_id, node in node_by_id.items():
        if node.get("type") != "condition":
            continue
        outgoing = [edge for edge in normalized_edges if edge["source"] == node_id]
        branches = [str(edge.get("branch") or edge.get("label") or "").strip().lower()
                    for edge in outgoing]
        if any(branch not in {"true", "false"} for branch in branches):
            return None
        if len(branches) != len(set(branches)):
            return None
    return node_by_id, normalized_edges


def timer_node_is_due_continuation(node):
    contract = (node.get("contract") or {}).get("timer") or {}
    forbidden_recalculation = any(
        "offset" in key.lower() or "calendar" in key.lower()
        for key, _ in walk_json(contract)
    )
    return (
        node.get("type") == "timer"
        and isinstance(contract.get("timer_key"), str) and bool(contract["timer_key"])
        and isinstance(contract.get("purpose"), str) and bool(contract["purpose"])
        and contract.get("source_field") == "next_followup_at"
        and contract.get("timezone") == "Asia/Shanghai"
        and not forbidden_recalculation
    )


def node_is_contacted_condition(node, status_field):
    if node.get("type") != "condition":
        return False
    condition = (node.get("contract") or {}).get("condition") or {}
    field = condition.get("field")
    if not isinstance(field, str):
        return False
    normalized_field = field.strip().removeprefix("$")
    for prefix in ("record.", "after."):
        normalized_field = normalized_field.removeprefix(prefix)
    return (
        condition.get("type") == "field_equals"
        and normalized_field == status_field
        and condition.get("value") == "contacted"
    )


def action_key_from_node(node):
    action = (node.get("contract") or {}).get("action") or {}
    return action.get("action_key") or action.get("key")


def workflow_action_keys(workflow):
    return {
        action_key_from_node(node)
        for node in ((workflow.get("graph") or {}).get("nodes") or [])
        if isinstance(node, dict) and node.get("type") == "action"
        and action_key_from_node(node)
    }


def workflow_targets_object(workflow, object_key, actions):
    return any(
        action.get("object_key") == object_key
        or actions.get(action.get("action_key") or action.get("key"), {}).get("object_key")
        == object_key
        for action in workflow_actions(workflow)
    )


def object_has_reminder_dedupe(obj, lead_key):
    fields = list(field_map(obj).values())
    lead_fields = {
        field.get("key") for field in fields
        if field.get("type") == "relation" and relation_target(field) == lead_key
    }
    has_recipient = any(field.get("type") == "user" for field in fields)
    local_date_fields = {
        field.get("key") for field in fields if field.get("type") == "date"
    }
    constraints = (
        obj.get("unique_constraints") or obj.get("constraints")
        or (obj.get("config") or {}).get("unique_constraints") or []
    )
    if isinstance(constraints, dict):
        constraints = list(constraints.values())
    has_business_unique = any(
        isinstance(row, dict)
        and (str(row.get("type", "")).lower() == "unique" or row.get("unique") is True)
        and set(row.get("fields") or row.get("field_keys") or row.get("columns") or [])
        == {lead_field, date_field}
        for row in constraints
        for lead_field in lead_fields
        for date_field in local_date_fields
    )
    return bool(lead_fields and has_recipient and local_date_fields and has_business_unique)


def is_due_continuation_workflow(workflow, lead_key, actions):
    if workflow.get("enabled") is not True:
        return False
    trigger = workflow_trigger_contract(workflow)
    if not is_record_change_trigger(trigger, lead_key, "next_followup_at"):
        return False
    validated = validated_workflow_graph(workflow.get("graph"))
    if validated is None:
        return False
    node_by_id, edges = validated
    nodes = list(node_by_id.values())
    trigger_ids = {node.get("id") for node in nodes if node.get("type") == "trigger"}
    condition_ids = {
        node.get("id") for node in nodes if node_is_contacted_condition(node, "status")
    }
    timer_ids = {node.get("id") for node in nodes if timer_node_is_due_continuation(node)}
    action_nodes = [node for node in nodes if node.get("type") == "action"]
    action_ids = {
        node.get("id") for node in action_nodes
        if action_key_from_node(node) in actions
        and actions[action_key_from_node(node)].get("object_key") == lead_key
        and actions[action_key_from_node(node)].get("kind") == "record_operation"
    }
    if not (trigger_ids and condition_ids and timer_ids and action_ids):
        return False
    for condition_id in condition_ids:
        true_starts = {
            edge["target"] for edge in edges
            if edge["source"] == condition_id
            and str(edge.get("branch") or edge.get("label") or "").strip().lower()
            == "true"
        }
        false_starts = {
            edge["target"] for edge in edges
            if edge["source"] == condition_id
            and str(edge.get("branch") or edge.get("label") or "").strip().lower()
            == "false"
        }
        for timer_id in timer_ids:
            edges_without_condition = [
                edge for edge in edges
                if edge["source"] != condition_id and edge["target"] != condition_id
            ]
            if (
                graph_has_path(edges, trigger_ids, {condition_id})
                and graph_has_path(edges, true_starts, {timer_id})
                and not graph_has_path(edges, false_starts, {timer_id})
                and not graph_has_path(
                    edges_without_condition, trigger_ids, {timer_id})
                and graph_has_path(edges, {timer_id}, action_ids)
            ):
                return True
    return False


def contains_evaluation_time(value):
    return any(
        key.lower() == "evaluation_time"
        or (isinstance(child, str) and child.lower() == "evaluation_time")
        for key, child in walk_json(value)
    )


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
    actions = keyed(manifest.get("actions"))
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
    status_field = lead_sm.get("field_key")
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
    due_workflow_keys = {
        key for key, workflow in workflows.items()
        if is_due_continuation_workflow(workflow, lead_key, actions)
    }
    due_workflows = [workflows[key] for key in due_workflow_keys]
    due_action_keys = set().union(
        *(workflow_action_keys(workflow) for workflow in due_workflows)
    ) if due_workflows else set()
    reminder_objects = [
        obj for key, obj in objects.items()
        if key != lead_key and object_has_reminder_dedupe(obj, lead_key)
    ]
    scheduled_workflow_keys = {
        key for key, workflow in workflows.items()
        if str(workflow_trigger_contract(workflow).get("type", "")).lower() == "scheduled"
        and workflow_targets_object(workflow, lead_key, actions)
    }
    legacy_followup_schedules = [
        schedule for schedule in schedules.values()
        if (
            schedule.get("target_type") == "workflow"
            and str(schedule.get("target_key", "")).removeprefix("scheduled:")
            in (scheduled_workflow_keys | due_workflow_keys)
        ) or (
            schedule.get("target_type") == "action"
            and schedule.get("target_key") in due_action_keys
        )
    ]
    lead_time_fields = {
        key: field for key, field in lead_fields.items()
        if key in {"status_changed_at", "next_followup_at"}
    }
    due_continuation = (
        status_field == "status"
        and set(lead_time_fields) == {"status_changed_at", "next_followup_at"}
        and all(field.get("type") == "datetime" for field in lead_time_fields.values())
        and bool(due_workflows)
        and bool(reminder_objects)
        and not scheduled_workflow_keys
        and not legacy_followup_schedules
        and not contains_evaluation_time({
            "workflows": list(workflows.values()),
            "actions": list(actions.values()),
        })
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
        "due_continuation": due_continuation,
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


def parse_timestamp(value):
    if not isinstance(value, str) or not value:
        return None
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return None
    return parsed if parsed.tzinfo is not None else None


def timestamp_is_workday_morning(value):
    parsed = parse_timestamp(value)
    return bool(parsed and parsed.weekday() < 5 and 5 <= parsed.hour < 12)


def indexed_operations(steps):
    return {
        step.get("operation"): step
        for step in steps
        if isinstance(step, dict) and isinstance(step.get("operation"), str)
    }


def bf06_case_diagnostics(operation, observations):
    diagnostics = []

    def require(condition, code):
        if not condition:
            diagnostics.append(f"bf06_{operation}:{code}")

    if operation == "lead.contacted.due.persisted":
        changed = parse_timestamp(observations.get("status_changed_at"))
        due = parse_timestamp(observations.get("next_followup_at"))
        require(bool(observations.get("record_id")), "record_id_missing")
        require(observations.get("status") == "contacted", "contacted_state_missing")
        require(observations.get("status_changed_at_persisted") is True,
                "status_changed_at_not_persisted")
        require(observations.get("next_followup_at_persisted") is True,
                "next_followup_at_not_persisted")
        require(bool(changed and due and due - changed > timedelta(days=7)),
                "due_not_strictly_after_seven_days")
        require(timestamp_is_workday_morning(observations.get("local_next_followup_at")),
                "due_not_local_workday_morning")
        require(observations.get("calculation_owner") == "project_handler",
                "due_calculation_owner_invalid")
        require(bool(observations.get("business_calendar_key")),
                "business_calendar_missing")
    elif operation == "lead.contacted.no_immediate_reminder":
        due = parse_timestamp(observations.get("next_followup_at"))
        observed = parse_timestamp(observations.get("observed_at"))
        require(bool(observations.get("record_id")), "record_id_missing")
        require(bool(observed and due and observed < due), "not_observed_before_due")
        require(observations.get("reminder_count_before") ==
                observations.get("reminder_count_after") == 0,
                "immediate_reminder_created")
    elif operation == "lead.contacted.due.restart_durable":
        require(bool(observations.get("record_id")), "record_id_missing")
        require(observations.get("status") == "contacted", "contacted_state_missing")
        require(bool(parse_timestamp(observations.get("status_changed_at"))),
                "status_changed_at_missing")
        require(bool(parse_timestamp(observations.get("next_followup_at"))),
                "next_followup_at_missing")
        require(observations.get("read_after_restart") is True,
                "due_not_read_after_restart")
        require(observations.get("reminder_count") == 0,
                "pre_due_restart_created_reminder")
    elif operation == "handler.followup_due.focused_tests":
        require(observations.get("suite_id") == "m1_req14_handler",
                "handler_suite_identity_invalid")
        require(observations.get("evaluator_certificate_required") is True,
                "handler_certificate_not_required")
        require(set(observations.get("required_cases") or []) == BF06_HANDLER_TESTS,
                "handler_case_set_invalid")
    elif operation == "runtime.record_timer.integration_tests":
        require(observations.get("suite_id") == "m1_req14_runtime_record_timer",
                "timer_suite_identity_invalid")
        require(observations.get("evaluator_certificate_required") is True,
                "timer_certificate_not_required")
        require(set(observations.get("required_cases") or []) == BF06_RUNTIME_TIMER_TESTS,
                "timer_case_set_invalid")

    if operation.startswith("lead.contacted."):
        require(observations.get("real_clock") is True, "real_clock_not_proven")
        require(observations.get("evaluation_time_supplied") is False,
                "evaluation_time_was_supplied")
        require(observations.get("direct_database_write") is False,
                "direct_database_write_used")
        require(observations.get("scheduler_invoked") is False,
                "tenant_scheduler_was_invoked")
    return diagnostics


def certificate_suite_diagnostics(certificate, suite_id, required_tests,
                                  require_runtime_dependencies=False):
    diagnostics = []
    if not isinstance(certificate, dict):
        return [f"bf06_certificate_missing:{suite_id}"]
    if certificate.get("suite_id") != suite_id:
        diagnostics.append(f"bf06_certificate_suite_invalid:{suite_id}")
    if certificate.get("exit_code") != 0:
        diagnostics.append(f"bf06_certificate_test_failed:{suite_id}")
    outcomes = certificate.get("test_outcomes")
    if not isinstance(outcomes, dict) or set(outcomes) != required_tests:
        diagnostics.append(f"bf06_certificate_test_set_invalid:{suite_id}")
    elif any(outcome != "pass" for outcome in outcomes.values()):
        diagnostics.append(f"bf06_certificate_test_not_passed:{suite_id}")
    for field in ("output_sha256", "source_sha256"):
        value = certificate.get(field)
        if not isinstance(value, str) or not re.fullmatch(r"[0-9a-f]{64}", value):
            diagnostics.append(f"bf06_certificate_{field}_invalid:{suite_id}")
    if require_runtime_dependencies:
        if certificate.get("dependency_command_exit_code") != 0:
            diagnostics.append("bf06_runtime_dependency_command_failed")
        dependency_hash = certificate.get("dependency_output_sha256")
        if not isinstance(dependency_hash, str) or not re.fullmatch(
                r"[0-9a-f]{64}", dependency_hash):
            diagnostics.append("bf06_runtime_dependency_output_sha256_invalid")
        dependencies = certificate.get("runtime_dependencies")
        if not isinstance(dependencies, list) or not any(
            isinstance(path, str)
            and path.startswith(BF06_RUNTIME_MODULE + "/runtime/")
            and ("/recordtimer" in path or "/workflow" in path)
            for path in dependencies):
            diagnostics.append("bf06_runtime_package_dependency_missing")
        expected_module_command = ["go", "list", "-m", "-json", BF06_RUNTIME_MODULE]
        if certificate.get("runtime_module_query_command") != expected_module_command:
            diagnostics.append("bf06_runtime_module_query_command_invalid")
        if certificate.get("runtime_module_query_exit_code") != 0:
            diagnostics.append("bf06_runtime_module_query_failed")
        module_query_hash = certificate.get("runtime_module_query_output_sha256")
        if not isinstance(module_query_hash, str) or not re.fullmatch(
                r"[0-9a-f]{64}", module_query_hash):
            diagnostics.append("bf06_runtime_module_query_output_sha256_invalid")
        identity = certificate.get("runtime_module_identity")
        identity = identity if isinstance(identity, dict) else {}
        external_module = (
            identity.get("Path") == BF06_RUNTIME_MODULE
            and isinstance(identity.get("Version"), str) and bool(identity["Version"])
            and isinstance(identity.get("Sum"), str)
            and identity["Sum"].startswith("h1:")
            and isinstance(identity.get("GoModSum"), str)
            and identity["GoModSum"].startswith("h1:")
            and identity.get("Main") is False
            and identity.get("Replace") is None
            and isinstance(identity.get("Dir"), str) and bool(identity["Dir"])
            and isinstance(identity.get("GoMod"), str) and bool(identity["GoMod"])
            and Path(identity["Dir"]).is_absolute()
            and Path(identity["GoMod"]).is_absolute()
            and identity.get("within_project_tree") is False
        )
        if not external_module:
            diagnostics.append("bf06_runtime_external_module_identity_invalid")
        binding = certificate.get("runtime_delivery_binding")
        binding = binding if isinstance(binding, dict) else {}
        binding_hashes_valid = all(
            isinstance(binding.get(field), str)
            and bool(re.fullmatch(r"[0-9a-f]{64}", binding[field]))
            for field in ("zip_sha256", "go_mod_sha256", "binding_sha256")
        )
        if not (
            binding.get("matches_resolved_module") is True
            and binding.get("path") == BF06_RUNTIME_MODULE
            and binding.get("version") == identity.get("Version")
            and binding_hashes_valid
        ):
            diagnostics.append("bf06_runtime_delivery_binding_invalid")
        coverage = certificate.get("runtime_record_timer_coverage")
        coverage = coverage if isinstance(coverage, dict) else {}
        if not isinstance(coverage.get("total_statements"), int) or coverage.get(
                "total_statements", 0) <= 0:
            diagnostics.append("bf06_runtime_record_timer_coverage_missing")
        if not isinstance(coverage.get("covered_statements"), int) or coverage.get(
                "covered_statements", 0) <= 0 or coverage.get(
                "covered_statements", 0) > coverage.get("total_statements", 0):
            diagnostics.append("bf06_runtime_record_timer_not_executed")
        coverage_hash = coverage.get("profile_sha256")
        if not isinstance(coverage_hash, str) or not re.fullmatch(
                r"[0-9a-f]{64}", coverage_hash):
            diagnostics.append("bf06_runtime_coverage_profile_sha256_invalid")
        go_env = certificate.get("hermetic_go_environment")
        go_env = go_env if isinstance(go_env, dict) else {}
        goflags = go_env.get("GOFLAGS")
        proxies = go_env.get("GOPROXY", "").split(",") if isinstance(
            go_env.get("GOPROXY"), str) else []
        if not (
            proxies
            and proxies[0].startswith("file://")
            and proxies[0].endswith("/.domainry/builder/contracts/go-module-proxy")
            and all(proxy.startswith("file://") for proxy in proxies)
            and isinstance(goflags, str) and "-mod=readonly" in goflags.split()
            and go_env.get("GOWORK") == "off"
            and go_env.get("GONOPROXY") == "none"
            and go_env.get("GOSUMDB") == "off"
        ):
            diagnostics.append("bf06_runtime_hermetic_go_environment_invalid")
        probe = certificate.get("evaluator_runtime_probe")
        probe = probe if isinstance(probe, dict) else {}
        expected_probe_source_hash = hashlib.sha256(
            BF06_RUNTIME_PROBE_SOURCE.encode("utf-8")).hexdigest()
        probe_command = probe.get("command")
        if not (
            isinstance(probe_command, list) and len(probe_command) >= 7
            and probe_command[:4] == ["go", "test", "-json", "-count=1"]
            and probe_command[-2:] == ["-run", "^" + BF06_RUNTIME_PROBE_TEST + "$"]
            and probe.get("exit_code") == 0
            and probe.get("test_outcome") == "pass"
            and probe.get("source_owned_by_evaluator") is True
            and probe.get("source_sha256") == expected_probe_source_hash
            and isinstance(probe.get("output_sha256"), str)
            and bool(re.fullmatch(r"[0-9a-f]{64}", probe["output_sha256"]))
        ):
            diagnostics.append("bf06_evaluator_runtime_probe_invalid")
    else:
        coverage = certificate.get("project_handler_coverage")
        coverage = coverage if isinstance(coverage, dict) else {}
        if not isinstance(coverage.get("total_statements"), int) or coverage.get(
                "total_statements", 0) <= 0:
            diagnostics.append("bf06_handler_coverage_missing")
        if not isinstance(coverage.get("covered_statements"), int) or coverage.get(
                "covered_statements", 0) <= 0 or coverage.get(
                "covered_statements", 0) > coverage.get("total_statements", 0):
            diagnostics.append("bf06_handler_code_not_executed")
        coverage_hash = coverage.get("profile_sha256")
        if not isinstance(coverage_hash, str) or not re.fullmatch(
                r"[0-9a-f]{64}", coverage_hash):
            diagnostics.append("bf06_handler_coverage_profile_sha256_invalid")
    return diagnostics


def validate_bf06_certificates(certificates):
    if not isinstance(certificates, dict) or certificates.get(
            "contract_version") != "domainry-bf06-evaluator-certificates-v1":
        return ["bf06_evaluator_certificate_contract_missing"]
    diagnostics = certificate_suite_diagnostics(
        certificates.get("handler"), "m1_req14_handler", BF06_HANDLER_TESTS)
    diagnostics.extend(certificate_suite_diagnostics(
        certificates.get("runtime_record_timer"), "m1_req14_runtime_record_timer",
        BF06_RUNTIME_TIMER_TESTS, require_runtime_dependencies=True))
    return diagnostics


def validate_bf06_steps(steps, phase, certificates=None):
    diagnostics = []
    by_operation = indexed_operations(steps)
    required = BF06_INITIAL_OPERATIONS if phase == "initial" else BF06_RESTART_OPERATIONS
    operation_names = [step.get("operation") for step in steps if isinstance(step, dict)]
    for operation, source in required.items():
        if operation_names.count(operation) > 1:
            diagnostics.append(f"duplicate_operation:{operation}")
        step = by_operation.get(operation)
        if not isinstance(step, dict):
            diagnostics.append(f"required_operation_missing:{operation}")
            continue
        if step.get("source") != source:
            diagnostics.append(f"required_operation_source_invalid:{operation}")
        observations = step.get("observations")
        if isinstance(observations, dict):
            if any(key.lower() == "timer_id" for key, _ in walk_json(observations)):
                diagnostics.append(f"bf06_internal_timer_id_self_reported:{operation}")
            diagnostics.extend(bf06_case_diagnostics(operation, observations))
    if phase == "initial":
        persisted = by_operation.get("lead.contacted.due.persisted", {}).get(
            "observations", {})
        immediate = by_operation.get("lead.contacted.no_immediate_reminder", {}).get(
            "observations", {})
        if persisted.get("record_id") != immediate.get("record_id"):
            diagnostics.append("bf06_initial_lead_identity_mismatch")
        if persisted.get("next_followup_at") != immediate.get("next_followup_at"):
            diagnostics.append("bf06_initial_due_identity_mismatch")
    diagnostics.extend(validate_bf06_certificates(certificates))
    return diagnostics


def validate_bf06_cross_phase(phases):
    initial_steps = ((phases.get("initial") or {}).get("BF06") or {}).get("steps") or []
    restart_steps = ((phases.get("restart") or {}).get("BF06") or {}).get("steps") or []
    initial = indexed_operations(initial_steps)
    restart = indexed_operations(restart_steps)
    persisted = initial.get("lead.contacted.due.persisted", {}).get("observations", {})
    durable = restart.get("lead.contacted.due.restart_durable", {}).get("observations", {})
    diagnostics = []
    if persisted.get("record_id") != durable.get("record_id"):
        diagnostics.append("bf06_restart_lead_identity_mismatch")
    for field in ("status_changed_at", "next_followup_at"):
        if persisted.get(field) != durable.get(field):
            diagnostics.append(f"bf06_restart_{field}_mismatch")
    return diagnostics


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


def validate_flow_evidence(document, bf06_certificates=None):
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
            if flow == "BF06":
                diagnostics[phase][flow].extend(
                    validate_bf06_steps(steps, phase, bf06_certificates))
            if flow == "BF08":
                diagnostics[phase][flow].extend(validate_bf08_steps(steps))
            valid[phase][flow] = row.get("status") == "passed" and not diagnostics[phase][flow]
    cross_phase_diagnostics = validate_bf06_cross_phase(phases)
    if cross_phase_diagnostics:
        diagnostics["restart"]["BF06"].extend(cross_phase_diagnostics)
        valid["restart"]["BF06"] = False
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


def package_source_sha256(directory):
    digest = hashlib.sha256()
    if directory.is_dir():
        for path in sorted(directory.rglob("*.go")):
            if path.is_file() and not path.is_symlink():
                digest.update(str(path.relative_to(directory)).encode("utf-8"))
                digest.update(b"\0")
                digest.update(path.read_bytes())
                digest.update(b"\0")
    return digest.hexdigest()


def go_test_outcomes(output, required_tests):
    outcomes = {}
    for line in output.splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        name = event.get("Test")
        action = event.get("Action")
        if name in required_tests and action in {"pass", "fail"}:
            outcomes[name] = action
    return outcomes


def file_sha256(path):
    if not path.is_file() or path.is_symlink():
        return ""
    return hashlib.sha256(path.read_bytes()).hexdigest()


def domain_sdk_build_tag(backend):
    build_target = backend / "generated/composition/build_target.gen.go"
    if not build_target.is_file():
        return ""
    match = re.search(
        r"^//go:build\s+(domainry_domain_sdk_[0-9a-f]+)\s*$",
        build_target.read_text(encoding="utf-8"), re.MULTILINE)
    return match.group(1) if match else ""


def existing_go_module_download_cache():
    module_cache = os.environ.get("GOMODCACHE", "").strip()
    if not module_cache:
        try:
            proc = subprocess.run(
                ["go", "env", "GOMODCACHE"], text=True, stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL, check=False, timeout=10)
            if proc.returncode == 0:
                module_cache = proc.stdout.strip()
        except (OSError, subprocess.TimeoutExpired):
            module_cache = ""
    download_cache = Path(module_cache) / "cache/download" if module_cache else None
    return download_cache.resolve() if download_cache and download_cache.is_dir() else None


def bf06_go_environment(project, backend, go_cache, go_mod_cache):
    proxy = (project / ".domainry/builder/contracts/go-module-proxy").resolve()
    proxies = [proxy.as_uri()]
    download_cache = existing_go_module_download_cache()
    if download_cache is not None and download_cache != proxy:
        proxies.append(download_cache.as_uri())
    build_tag = domain_sdk_build_tag(backend)
    goflags = "-mod=readonly"
    if build_tag:
        goflags += f" -tags={build_tag}"
    env = os.environ.copy()
    env.update({
        "GOCACHE": str(go_cache),
        "GOMODCACHE": str(go_mod_cache),
        "GONOPROXY": "none",
        "GOPROXY": ",".join(proxies),
        "GOSUMDB": "off",
        "GOWORK": "off",
        "GOFLAGS": goflags,
    })
    return env


def runtime_coverage_summary(path):
    total = covered = 0
    if not path.is_file():
        return {"total_statements": 0, "covered_statements": 0,
                "profile_sha256": ""}
    for line in path.read_text(encoding="utf-8").splitlines()[1:]:
        try:
            location, statements, count = line.rsplit(" ", 2)
            filename = location.split(":", 1)[0]
            statement_count = int(statements)
            execution_count = int(count)
        except (ValueError, IndexError):
            continue
        if not filename.startswith(BF06_RUNTIME_MODULE + "/runtime/"):
            continue
        if "/recordtimer/" not in filename:
            continue
        total += statement_count
        if execution_count > 0:
            covered += statement_count
    return {
        "total_statements": total,
        "covered_statements": covered,
        "profile_sha256": file_sha256(path),
    }


def project_handler_coverage_summary(path):
    total = covered = 0
    if not path.is_file():
        return {"total_statements": 0, "covered_statements": 0,
                "profile_sha256": ""}
    for line in path.read_text(encoding="utf-8").splitlines()[1:]:
        try:
            _location, statements, count = line.rsplit(" ", 2)
            statement_count = int(statements)
            execution_count = int(count)
        except (ValueError, IndexError):
            continue
        total += statement_count
        if execution_count > 0:
            covered += statement_count
    return {
        "total_statements": total,
        "covered_statements": covered,
        "profile_sha256": file_sha256(path),
    }


def parse_single_json_document(output):
    try:
        value = json.loads(output)
    except (TypeError, json.JSONDecodeError):
        return None
    return value if isinstance(value, dict) else None


def path_is_within(path, parent):
    try:
        Path(path).resolve().relative_to(parent.resolve())
        return True
    except (TypeError, ValueError):
        return False


def runtime_delivery_binding(project, module_identity):
    binding_path = project / ".domainry/builder/contracts/application-delivery-binding.json"
    try:
        binding = json.loads(binding_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        binding = {}
    runtime = binding.get("runtime_module") if isinstance(binding, dict) else None
    runtime = runtime if isinstance(runtime, dict) else {}
    version = runtime.get("version")
    proxy = project / ".domainry/builder/contracts/go-module-proxy"
    module_root = proxy.joinpath(*BF06_RUNTIME_MODULE.split("/"), "@v")
    zip_path = module_root / f"{version}.zip" if isinstance(version, str) else Path()
    mod_path = module_root / f"{version}.mod" if isinstance(version, str) else Path()
    evidence = {
        "path": runtime.get("path"),
        "version": version,
        "zip_sha256": runtime.get("zip_sha256"),
        "go_mod_sha256": runtime.get("go_mod_sha256"),
        "binding_sha256": file_sha256(binding_path),
    }
    evidence["matches_resolved_module"] = bool(
        runtime.get("path") == BF06_RUNTIME_MODULE
        and isinstance(version, str) and bool(version)
        and module_identity.get("Path") == BF06_RUNTIME_MODULE
        and module_identity.get("Version") == version
        and file_sha256(zip_path) == runtime.get("zip_sha256")
        and file_sha256(mod_path) == runtime.get("go_mod_sha256")
    )
    return evidence


def normalized_runtime_module_identity(project, value):
    value = value if isinstance(value, dict) else {}
    identity = {
        "Path": value.get("Path"),
        "Version": value.get("Version"),
        "Sum": value.get("Sum"),
        "GoModSum": value.get("GoModSum"),
        "Main": value.get("Main") is True,
        "Replace": value.get("Replace"),
        "Dir": value.get("Dir"),
        "GoMod": value.get("GoMod"),
    }
    identity["within_project_tree"] = any(
        path_is_within(identity.get(field), project)
        for field in ("Dir", "GoMod")
        if isinstance(identity.get(field), str) and identity.get(field)
    )
    return identity


def run_evaluator_runtime_probe(backend, env):
    with tempfile.TemporaryDirectory(prefix="bf06evaluatorprobe-", dir=backend) as directory:
        probe_dir = Path(directory)
        source = probe_dir / "runtime_probe_test.go"
        source.write_text(BF06_RUNTIME_PROBE_SOURCE, encoding="utf-8")
        package = "./" + probe_dir.name
        pattern = "^" + BF06_RUNTIME_PROBE_TEST + "$"
        command = ["go", "test", "-json", "-count=1", package, "-run", pattern]
        try:
            proc = subprocess.run(
                command, cwd=backend, text=True, stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT, check=False, timeout=120, env=env)
            output, exit_code = proc.stdout, proc.returncode
        except (OSError, subprocess.TimeoutExpired) as exc:
            output, exit_code = str(exc), 124
    return {
        "command": command,
        "exit_code": exit_code,
        "test_outcome": go_test_outcomes(output, {BF06_RUNTIME_PROBE_TEST}).get(
            BF06_RUNTIME_PROBE_TEST),
        "output_sha256": hashlib.sha256(output.encode("utf-8")).hexdigest(),
        "source_sha256": hashlib.sha256(
            BF06_RUNTIME_PROBE_SOURCE.encode("utf-8")).hexdigest(),
        "source_owned_by_evaluator": True,
    }


def run_bf06_certificate_suite(project, backend, package, suite_id, required_tests,
                               log_path, go_cache, go_mod_cache,
                               require_runtime_dependencies=False):
    pattern = "^(?:" + "|".join(re.escape(name) for name in sorted(required_tests)) + ")$"
    command = ["go", "test", "-json", "-count=1"]
    coverage_path = go_cache / f"{suite_id}.coverage"
    if require_runtime_dependencies:
        command.extend([
            "-coverpkg=" + ",".join(BF06_RUNTIME_COVER_PACKAGES),
        ])
    command.append("-coverprofile=" + str(coverage_path))
    command.extend([package, "-run", pattern])
    env = bf06_go_environment(project, backend, go_cache, go_mod_cache)
    try:
        proc = subprocess.run(
            command, cwd=backend, text=True, stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT, check=False, timeout=120, env=env)
        output, exit_code = proc.stdout, proc.returncode
    except (OSError, subprocess.TimeoutExpired) as exc:
        output, exit_code = str(exc), 124
    log_path.write_text(output, encoding="utf-8")
    package_directory = backend / package.removeprefix("./")
    certificate = {
        "suite_id": suite_id,
        "command": command,
        "exit_code": exit_code,
        "test_outcomes": go_test_outcomes(output, required_tests),
        "output_sha256": hashlib.sha256(output.encode("utf-8")).hexdigest(),
        "source_sha256": package_source_sha256(package_directory),
    }
    if require_runtime_dependencies:
        try:
            deps = subprocess.run(
                ["go", "list", "-deps", "-test", "-f", "{{.ImportPath}}", package],
                cwd=backend, text=True, stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT, check=False, timeout=60, env=env)
            certificate["runtime_dependencies"] = [
                line.strip() for line in deps.stdout.splitlines() if line.strip()
            ] if deps.returncode == 0 else []
            certificate["dependency_command_exit_code"] = deps.returncode
            certificate["dependency_output_sha256"] = hashlib.sha256(
                deps.stdout.encode("utf-8")).hexdigest()
        except (OSError, subprocess.TimeoutExpired):
            certificate["runtime_dependencies"] = []
            certificate["dependency_command_exit_code"] = 124
        module_command = ["go", "list", "-m", "-json", BF06_RUNTIME_MODULE]
        try:
            module = subprocess.run(
                module_command, cwd=backend, text=True, stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT, check=False, timeout=60, env=env)
            resolved = parse_single_json_document(module.stdout) or {}
            identity = normalized_runtime_module_identity(project, resolved)
            certificate.update({
                "runtime_module_query_command": module_command,
                "runtime_module_query_exit_code": module.returncode,
                "runtime_module_query_output_sha256": hashlib.sha256(
                    module.stdout.encode("utf-8")).hexdigest(),
                "runtime_module_identity": identity,
                "runtime_delivery_binding": runtime_delivery_binding(project, identity),
            })
        except (OSError, subprocess.TimeoutExpired) as exc:
            certificate.update({
                "runtime_module_query_command": module_command,
                "runtime_module_query_exit_code": 124,
                "runtime_module_query_output_sha256": hashlib.sha256(
                    str(exc).encode("utf-8")).hexdigest(),
                "runtime_module_identity": {},
                "runtime_delivery_binding": {},
            })
        certificate["runtime_record_timer_coverage"] = runtime_coverage_summary(
            coverage_path)
        certificate["evaluator_runtime_probe"] = run_evaluator_runtime_probe(
            backend, env)
        certificate["hermetic_go_environment"] = {
            key: env[key] for key in ("GOPROXY", "GOFLAGS", "GOWORK", "GONOPROXY", "GOSUMDB")
        }
    else:
        certificate["project_handler_coverage"] = project_handler_coverage_summary(
            coverage_path)
    return certificate


def run_bf06_certificates(project, run_dir):
    backend = project / "backend"
    with tempfile.TemporaryDirectory(prefix="domainry-bf06-go-cache-") as cache, \
            tempfile.TemporaryDirectory(prefix="domainry-bf06-go-mod-cache-") as mod_cache:
        go_cache, go_mod_cache = Path(cache), Path(mod_cache)
        document = {
            "contract_version": "domainry-bf06-evaluator-certificates-v1",
            "handler": run_bf06_certificate_suite(
                project, backend, "./actions/crm", "m1_req14_handler", BF06_HANDLER_TESTS,
                run_dir / "bf06-handler-tests.jsonl", go_cache, go_mod_cache),
            "runtime_record_timer": run_bf06_certificate_suite(
                project, backend, "./tests/recordtimer", "m1_req14_runtime_record_timer",
                BF06_RUNTIME_TIMER_TESTS, run_dir / "bf06-runtime-record-timer-tests.jsonl",
                go_cache, go_mod_cache, require_runtime_dependencies=True),
        }
    (run_dir / "bf06-evaluator-certificates.json").write_text(
        json.dumps(document, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8")
    return document


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


def verified_flow_outcomes(project, raw_result, structured_evidence, bf06_certificates=None):
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
    flow_validity, flow_diagnostics = validate_flow_evidence(
        structured_evidence, bf06_certificates)
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
        "bf06_evaluator_certificates": bf06_certificates,
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
    bf06_certificates = run_bf06_certificates(args.project, args.run_dir)
    structured_evidence = (
        json.loads(args.flow_evidence.read_text(encoding="utf-8"))
        if args.flow_evidence else None
    )
    if args.verify_result:
        verify_result = json.loads(args.verify_result.read_text(encoding="utf-8"))
        flows, exit_code, flow_evidence, flow_validity = verified_flow_outcomes(
            args.project, verify_result, structured_evidence, bf06_certificates)
    else:
        live = (args.base_url, args.database, args.bootstrap_password, args.acceptance_password)
        if not all(live):
            parser.error("use --verify-result or provide all legacy live-Runtime arguments")
        assert_fresh_sqlite(args.database, lead_table, seed_count)
        flows, exit_code, captured_evidence = run_flows(
            args.project, args.base_url, args.bootstrap_password,
            args.acceptance_password, log_path)
        structured_evidence = structured_evidence or captured_evidence
        flow_validity, diagnostics = validate_flow_evidence(
            structured_evidence, bf06_certificates)
        flows = {
            flow: flows[flow] and all(flow_validity[phase][flow] for phase in FLOW_PHASES)
            for flow in FLOW_IDS
        }
        flow_evidence = {
            "mode": "legacy_live_runtime",
            "log": str(log_path),
            "bf06_evaluator_certificates": bf06_certificates,
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
