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
import sqlite3
import subprocess
import sys
import time


FLOW_TESTS = {
    "BF01": ("TestBF01LeadOwnershipLifecycleAndScope", "TestBF01ScopeCreatePaginationAndNavigation"),
    "BF02": ("TestBF02DirectLowValueConversion", "TestBF02LowValueConversionIdempotency"),
    "BF03": ("TestBF03HighValueConversionApproval", "TestBF03HighestRiskLargeApproval"),
    "BF04": ("TestBF04RejectedHighValueConversion", "TestBF03RejectedApproval"),
    "BF05": ("TestBF05DepartmentGlobalScopeAndPagination", "TestBF01ScopeCreatePaginationAndNavigation"),
    "BF06": ("TestBF06WeekdayStaleReminderDedupe", "TestBF04ScheduledReminderDailyDedupe"),
    "BF07": ("TestBF07DirectorFunnelReport", "TestBF05DirectorFunnelAuthorization"),
    "BF08": ("TestBF08GovernedExportZeroNormalAnd1000Boundary", "TestBF05DirectorFunnelAuthorization"),
}

FEATURES = {
    "M01": ("P0", ["schema"], ["BF01"]),
    "M02": ("P0", ["lead_state_machine"], ["BF01", "BF02"]),
    "M03": ("P0", ["lead_scope_fields"], ["BF01"]),
    "M04": ("P0", ["advance_action"], ["BF01"]),
    "M05": ("P0", [], ["BF01"]),
    "M06": ("P0", ["conversion_actions"], ["BF02", "BF03"]),
    "M07": ("P0", ["approval_workflow"], ["BF03", "BF04"]),
    "M08": ("P0", [], ["BF02", "BF03"]),
    "M09": ("P1", ["conversion_notifications"], ["BF03", "BF04"]),
    "M10": ("P0", ["customer_read_only"], ["BF02"]),
    "M11": ("P0", ["department_scope"], ["BF01", "BF05"]),
    "M12": ("P0", ["director_scope"], ["BF05"]),
    "M13": ("P1", ["audit_events"], ["BF01", "BF03", "BF04"]),
    "M14": ("P1", ["stale_scheduler"], ["BF06"]),
    "M15": ("P0", ["funnel_report"], ["BF07"]),
    "M16": ("P0", ["export_control"], ["BF08"]),
    "M17": ("P0", ["detail_report"], ["BF05"]),
    "M18": ("P1", ["role_menus"], ["BF01"]),
    "M19": ("P0", ["acceptance_identities", "seed_coverage"], []),
}


def keyed(items):
    return {item.get("key"): item for item in items or [] if isinstance(item, dict)}


def field_map(obj):
    return keyed((obj or {}).get("fields"))


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
                     if {"company_name", "source", "status"} <= set(field_map(value))
                     and {"owner_user", "owner_department_id"} <= set(field_map(value))), None)
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
    identity = manifest.get("identity_bootstrap") or {}
    users = identity.get("users") or []
    departments = identity.get("departments") or []
    seeds = manifest.get("seed_records") or []
    lead_seeds = [s for s in seeds if s.get("object_key") == lead_key]
    seed_states = {(s.get("data") or {}).get("status") for s in lead_seeds}
    amount_key = next((key for key, value in lead_fields.items()
                       if value.get("type") == "currency" and "amount" in key), None)
    seed_amounts = [float((s.get("data") or {}).get(amount_key) or 0)
                    for s in lead_seeds] if amount_key else []

    role_permissions = {key: set(value.get("permissions") or [])
                        for key, value in roles.items()}
    director_permissions = role_permissions.get("sales_director", set())
    customer_write = {p for permissions in role_permissions.values()
                      for p in permissions if p in {"customer.update", "customer.delete"}}
    menu_roles = {row.get("role_id") for row in identity.get("role_menus") or []}
    action_keys = set(actions)

    return {
        "schema": (lead_fields.get("company_name", {}).get("required") is True
                   and amount.get("type") == "currency"
                   and int((amount.get("config") or {}).get("scale", -1)) == 2
                   and source_values == {"website", "exhibition", "referral", "outbound"}),
        "lead_state_machine": (states == {"new", "contacted", "qualified", "converted", "lost"}
                               and terminals == {"converted", "lost"}),
        "lead_scope_fields": all(k in lead_fields for k in
                                 ("owner_user", "owner_department_id", "owner_department_path")),
        "advance_action": any(key.startswith(f"{lead_key}.") and ("advance" in key or "status" in key)
                              for key in action_keys),
        "conversion_actions": (any(key.startswith(f"{lead_key}.") and "conversion" in key for key in action_keys)
                               and any("conversion" in key and ("resolve" in key or "approve" in key)
                                       for key in action_keys)),
        "approval_workflow": any("conversion" in key and "approval" in key for key in workflows),
        "conversion_notifications": (any("conversion" in key and "approv" in key for key in notifications)
                                     and any("conversion" in key and "reject" in key for key in notifications)),
        "customer_read_only": "customer" in objects and not customer_write,
        "department_scope": "sales_rep" in roles and len(departments) >= 2,
        "director_scope": ("sales_director" in roles
                           and any(permission == f"{lead_key}.read" or permission.startswith(f"{lead_key}.read_")
                                   for permission in director_permissions)),
        "audit_events": all((actions[k].get("audit_event") for k in action_keys)),
        "stale_scheduler": (any("stale" in key or "reminder" in key for key in schedules)
                            and any("stale" in key or "reminder" in key for key in workflows)
                            and any(("stale" in key or "reminder" in key) for key in action_keys)),
        "funnel_report": any("funnel" in key for key in reports),
        "export_control": bool(manifest.get("report_export_controls")),
        "detail_report": any("detail" in key for key in reports),
        "role_menus": {"sales_rep", "sales_director"} <= menu_roles,
        "acceptance_identities": (len(departments) >= 2
                                  and sum("sales_rep" in (u.get("role_keys") or []) for u in users) >= 2
                                  and any("sales_director" in (u.get("role_keys") or []) for u in users)),
        "seed_coverage": (len(lead_seeds) >= 6
                          and seed_states >= {"new", "contacted", "qualified", "converted", "lost"}
                          and any(v >= 100000 for v in seed_amounts)
                          and any(0 < v < 100000 for v in seed_amounts)),
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
    outcomes = {key: False for key in FLOW_TESTS}
    by_test = {}
    for key, names in FLOW_TESTS.items():
        for name in names:
            by_test.setdefault(name, set()).add(key)
    for line in proc.stdout.splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        keys = by_test.get(event.get("Test"), ())
        if keys and event.get("Action") in {"pass", "fail"}:
            for key in keys:
                outcomes[key] = event["Action"] == "pass"
    return outcomes, proc.returncode


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--project", required=True, type=Path)
    parser.add_argument("--run-dir", required=True, type=Path)
    parser.add_argument("--base-url", required=True)
    parser.add_argument("--database", required=True, type=Path)
    parser.add_argument("--bootstrap-password", required=True)
    parser.add_argument("--acceptance-password", required=True)
    args = parser.parse_args()

    manifest_path = args.project / ".domainry/builder/project-delivery/runtime-manifest.json"
    manifest = json.loads(manifest_path.read_text())
    facts, lead_table, seed_count = manifest_facts(manifest)
    assert_fresh_sqlite(args.database, lead_table, seed_count)
    args.run_dir.mkdir(parents=True, exist_ok=True)
    log_path = args.run_dir / "m1-businessflow-events.jsonl"
    flows, exit_code = run_flows(
        args.project, args.base_url, args.bootstrap_password,
        args.acceptance_password, log_path)

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
        "results": results,
        "generated_epoch": int(time.time()),
    }
    out_path = args.run_dir / "checklist-results.json"
    out_path.write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps(output, ensure_ascii=False, indent=2))
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
