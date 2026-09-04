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

FEATURES = {
    "M01": ("P0", ["schema"], ["BF01"]),
    "M02": ("P0", ["lead_state_machine"], ["BF01", "BF02"]),
    "M03": ("P0", [], ["BF01"]),
    "M04": ("P0", ["advance_action"], ["BF01"]),
    "M05": ("P0", [], ["BF01"]),
    "M06": ("P0", ["conversion_actions"], ["BF02", "BF03"]),
    "M07": ("P0", ["approval_workflow"], ["BF03", "BF04"]),
    "M08": ("P0", [], ["BF02", "BF03"]),
    "M09": ("P1", ["conversion_notifications"], ["BF03", "BF04"]),
    "M10": ("P0", ["customer_read_only"], ["BF02"]),
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


def key_mentions(key, terms):
    value = key.lower() if isinstance(key, str) else ""
    return any(term in value for term in terms)


def manifest_facts(manifest):
    objects = keyed(manifest.get("objects"))
    actions = keyed(manifest.get("actions"))
    workflows = keyed(manifest.get("workflows"))
    schedules = keyed(manifest.get("scheduler_definitions"))
    reports = keyed(manifest.get("reports"))
    notifications = keyed(manifest.get("notification_event_types"))
    roles = keyed(manifest.get("roles"))
    state_machines = keyed(manifest.get("state_machines"))
    lead_key = next((key for key, value in objects.items()
                     if {"company_name", "source", "status"} <= set(field_map(value))), None)
    lead_fields = field_map(objects.get(lead_key))
    source = lead_fields.get("source", {})
    source_values = {o.get("value", o) if isinstance(o, dict) else o
                     for o in source.get("options", [])}
    amount = next((value for key, value in lead_fields.items()
                   if value.get("type") == "currency" and "amount" in key), {})
    lead_sm = next((value for value in state_machines.values()
                    if set(value.get("states") or []) == {"new", "contacted", "qualified", "converted", "lost"}), {})
    states = set(lead_sm.get("states") or [])
    terminals = set(lead_sm.get("terminal_states") or [])
    seeds = manifest.get("seed_records") or []
    lead_seeds = [s for s in seeds if s.get("object_key") == lead_key]

    customer_write = {
        key
        for role in roles.values()
        for permission in role.get("permissions") or []
        if (key := permission_key(permission))
        in {"customer.create", "customer.update", "customer.delete"}
    }
    action_keys = set(actions)
    reminder_terms = ("stale", "reminder", "overdue", "followup")

    return {
        "schema": (lead_fields.get("company_name", {}).get("required") is True
                   and amount.get("type") == "currency"
                   and int((amount.get("config") or {}).get("scale", -1)) == 2
                   and source_values == {"website", "exhibition", "referral", "outbound"}),
        "lead_state_machine": (states == {"new", "contacted", "qualified", "converted", "lost"}
                               and terminals == {"converted", "lost"}),
        "advance_action": bool(lead_sm.get("transitions")),
        "conversion_actions": (any(key.startswith(f"{lead_key}.") and "conversion" in key for key in action_keys)
                               and any("conversion" in key and ("resolve" in key or "approve" in key)
                                       for key in action_keys)),
        "approval_workflow": any("conversion" in key and "approval" in key for key in workflows),
        "conversion_notifications": (any("conversion" in key and "approv" in key for key in notifications)
                                     and any("conversion" in key and "reject" in key for key in notifications)),
        "customer_read_only": "customer" in objects and not customer_write,
        "stale_scheduler": (any(key_mentions(key, reminder_terms) for key in schedules)
                            and any(key_mentions(key, reminder_terms) for key in workflows)
                            and any(key_mentions(key, reminder_terms) for key in action_keys)),
        "funnel_report": any("funnel" in key for key in reports),
        "export_control": bool(manifest.get("report_export_controls")),
        "detail_report": any("detail" in key for key in reports),
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
    return parse_flow_outcomes(proc.stdout), proc.returncode


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


def verified_flow_outcomes(project, raw_result):
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
    outcomes = {flow: proof_ok and flow in declared and flow in traced for flow in FLOW_IDS}
    evidence = {
        "verify_state": result.get("state") if isinstance(result, dict) else None,
        "proof_ok": proof_ok,
        "declared_flow_ids": sorted(declared),
        "traced_flow_ids": sorted(traced),
        "initial_business_flow_status": initial_flow.get("status"),
        "restart_business_flow_status": restart_flow.get("status"),
        "same_cohort_identity": identities_match,
        "final_runtime_state": final_stop.get("state"),
    }
    return outcomes, (0 if proof_ok and all(outcomes.values()) else 1), evidence


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--project", required=True, type=Path)
    parser.add_argument("--run-dir", required=True, type=Path)
    parser.add_argument("--verify-result", type=Path,
                        help="current domainry-cli verify JSON (preferred)")
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
    if args.verify_result:
        verify_result = json.loads(args.verify_result.read_text(encoding="utf-8"))
        flows, exit_code, flow_evidence = verified_flow_outcomes(args.project, verify_result)
    else:
        live = (args.base_url, args.database, args.bootstrap_password, args.acceptance_password)
        if not all(live):
            parser.error("use --verify-result or provide all legacy live-Runtime arguments")
        assert_fresh_sqlite(args.database, lead_table, seed_count)
        flows, exit_code = run_flows(
            args.project, args.base_url, args.bootstrap_password,
            args.acceptance_password, log_path)
        flow_evidence = {"mode": "legacy_live_runtime", "log": str(log_path)}

    results = []
    for feature_id, (priority, required_facts, required_flows) in FEATURES.items():
        fact_state = {key: bool(facts.get(key)) for key in required_facts}
        flow_state = {key: bool(flows.get(key)) for key in required_flows}
        ok = all(fact_state.values()) and all(flow_state.values())
        results.append({
            "id": feature_id, "priority": priority,
            "status": "pass" if ok else "fail", "mechanism": "custom",
            "evidence": {"manifest_facts": fact_state, "business_flows": flow_state},
        })
    passed = all(row["status"] == "pass" for row in results) and exit_code == 0
    output = {
        "contract_version": "domainry-m1-evaluator-result-v2",
        "pass": passed,
        "runtime_manifest": str(manifest_path),
        "fresh_cohort_seed_rows": seed_count,
        "business_flow_exit_code": exit_code,
        "business_flows": flows,
        "business_flow_evidence": flow_evidence,
        "results": results,
        "generated_epoch": int(time.time()),
    }
    out_path = args.run_dir / "checklist-results.json"
    out_path.write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps(output, ensure_ascii=False, indent=2))
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
