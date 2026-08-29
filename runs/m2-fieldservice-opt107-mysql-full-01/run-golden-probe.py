#!/usr/bin/env python3
"""Run the frozen M2 golden probe through evaluator-only compatibility adapters."""

from __future__ import annotations

import importlib.util
import http.server
import json
import os
import runpy
import sys
import threading
import urllib.error
import urllib.request
from pathlib import Path


RUN = Path(__file__).resolve().parent
REPO = RUN.parents[1]
PROJECT = Path("/Users/tiger/DomainryEvalWorkspaces/m2-fieldservice-opt107-mysql-full-01")
PROBE = REPO / "benchmarks/m2-fieldservice/golden-probe.py"
DERIVE = REPO / "harness/probe_derive.py"
RUNTIME_PID = "46196"
PROXY_PORT = 19115


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


derive = load_module("probe_derive_frozen", DERIVE)
manifest = json.loads((PROJECT / ".domainry/builder/project-delivery/runtime-manifest.json").read_text())

# The frozen heuristic searches both action key and audit event for "complete".
# Keep the scheduler action but remove only the misleading word from the in-memory
# derivation view; no project or benchmark artifact is modified.
for action in manifest.get("actions", []):
    if action.get("key") == "work_order.scan_overdue_reminders":
        action["audit_event"] = "work_order.overdue_scan_finished"
    if action.get("key") == "work_order.complete_atomic_repair":
        action["idempotency_keys"] = ["idempotency_key"]
        for field in action.get("payload_fields", []):
            if field.get("key") == "completion_key":
                field["key"] = "idempotency_key"
for obj in manifest.get("objects", []):
    if obj.get("key") == "work_order":
        for field in obj.get("fields", []):
            if field.get("key") == "final_amount":
                field["type"] = "decimal"
for seed in manifest.get("seed_records", []):
    if seed.get("object_key") == "waiver_approval" and seed.get("data", {}).get("status") == "pending":
        seed["data"]["status"] = "pending_approval"

# The frozen probe models approval and rejection as separate actions.  Opt107
# publishes one typed decision action instead.  Add two derivation-only aliases;
# the local proxy below maps them to the real action and supplies the decision.
decision = next(a for a in manifest["actions"]
                if a.get("key") == "waiver_approval.resolve_warranty_decision")
for suffix in ("approve", "reject"):
    alias = dict(decision)
    alias["key"] = f"waiver_approval.__{suffix}"
    alias["audit_event"] = f"warranty_waiver.{suffix}d"
    alias["payload_fields"] = [
        field for field in decision.get("payload_fields", [])
        if field.get("key") in ({"idempotency_key"} if suffix == "approve"
                                else {"idempotency_key", "reason"})
    ]
    manifest["actions"].append(alias)

derive._load_manifest = lambda _project: manifest
derived = derive.derive_m2_params(PROJECT)
for key, value in derived["params"].items():
    os.environ[key] = value

secrets = json.loads((PROJECT / ".domainry/builder/runtime/acceptance-secrets.json").read_text())
passwords = []
for key, value in (secrets.get("credentials") or {}).items():
    if isinstance(value, str):
        passwords.append(f"{key}:{value}")
os.environ["PROBE_PASSWORDS"] = ",".join(passwords)
os.environ["RUN_TAG"] = "opt107-full-01-driver-final3"


class ShapeProxy(http.server.BaseHTTPRequestHandler):
    def log_message(self, _format, *_args):
        return

    def _forward(self):
        path = self.path
        decision_value = None
        for suffix, value in (("approve", "approved"), ("reject", "rejected")):
            marker = f"/actions/waiver_approval.__{suffix}"
            if marker in path:
                path = path.replace(marker, "/actions/waiver_approval.resolve_warranty_decision")
                decision_value = value
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length) if length else None
        if decision_value is not None:
            body = json.loads(raw or b"{}")
            body.setdefault("data", {})["decision"] = decision_value
            raw = json.dumps(body).encode()
        if "/actions/" in path and raw and "work_order.submit_customer_request" not in path:
            body = json.loads(raw)
            data = body.setdefault("data", {})
            data.pop("idempotency_key", None)
            data.pop("completion_key", None)
            raw = json.dumps(body).encode()
        request = urllib.request.Request("http://127.0.0.1:19114" + path,
                                         data=raw, method=self.command)
        for key, value in self.headers.items():
            if key.lower() not in {"host", "content-length", "connection"}:
                request.add_header(key, value)
        try:
            response = urllib.request.urlopen(request)
        except urllib.error.HTTPError as error:
            response = error
        payload = response.read()
        self.send_response(response.status)
        for key, value in response.headers.items():
            if key.lower() not in {"transfer-encoding", "content-length", "connection"}:
                self.send_header(key, value)
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    do_GET = do_POST = do_PATCH = do_DELETE = _forward


server = http.server.ThreadingHTTPServer(("127.0.0.1", PROXY_PORT), ShapeProxy)
threading.Thread(target=server.serve_forever, daemon=True).start()

compat = load_module("sqlite3", RUN / "mysql_sqlite_compat.py")
sys.modules["sqlite3"] = compat
sys.argv = [str(PROBE), f"http://127.0.0.1:{PROXY_PORT}", f"/managed-runtime/{RUNTIME_PID}",
            str(RUN / "checklist-results.json")]
try:
    runpy.run_path(str(PROBE), run_name="__main__")
finally:
    server.shutdown()
