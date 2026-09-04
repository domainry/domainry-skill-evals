#!/usr/bin/env python3
"""Fail-closed preflight for an installed Builder candidate and its service."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys
import urllib.error
import urllib.request

import eval_config


HEALTH_CONTRACT = "domainry-control-plane-health-v1"


def assess_health(http_status: int, document: object) -> tuple[bool, list[str]]:
    diagnostics: list[str] = []
    if http_status != 200:
        diagnostics.append(f"service.health_http_{http_status}")
    if not isinstance(document, dict):
        return False, diagnostics + ["service.health_json_invalid"]
    if document.get("contract_version") != HEALTH_CONTRACT:
        diagnostics.append("service.health_contract_invalid")
    if document.get("status") != "healthy":
        diagnostics.append("service.status_unhealthy")
    checks = document.get("checks")
    if not isinstance(checks, list) or not checks:
        diagnostics.append("service.checks_missing")
    else:
        diagnostics.extend(
            f"service.check_failed:{check.get('name', 'unknown')}"
            for check in checks
            if not isinstance(check, dict) or check.get("status") != "passed"
        )
    return not diagnostics, diagnostics


def fetch_health(base_url: str, timeout: float) -> tuple[int, object]:
    url = base_url.rstrip("/") + "/health"
    request = urllib.request.Request(url, headers={"Accept": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            status = response.status
            raw = response.read()
    except urllib.error.HTTPError as error:
        status = error.code
        raw = error.read()
    except Exception as error:
        return 0, {"transport_error": str(error)}
    try:
        return status, json.loads(raw)
    except json.JSONDecodeError:
        return status, {"invalid_json": raw.decode("utf-8", errors="replace")[:500]}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", type=Path, default=eval_config.DEFAULT_CONFIG)
    parser.add_argument("--timeout", type=float, default=5.0)
    parser.add_argument("--out", type=Path)
    arguments = parser.parse_args()
    candidate = eval_config.load(arguments.config)
    diagnostics: list[str] = []
    service: dict[str, object]
    if candidate["apply_target_flag"] != "--service":
        service = {"state": "unresolved_environment_target"}
        diagnostics.append("service.environment_target_not_preflightable")
    else:
        status, health = fetch_health(str(candidate["apply_target_value"]), arguments.timeout)
        healthy, diagnostics = assess_health(status, health)
        service = {
            "state": "healthy" if healthy else "unhealthy",
            "http_status": status,
            "health": health,
        }
    output = {
        "contract_version": "domainry-eval-preflight-v1",
        "pass": not diagnostics,
        "candidate": candidate,
        "service": service,
        "diagnostics": diagnostics,
    }
    encoded = json.dumps(output, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    if arguments.out:
        arguments.out.write_text(encoded, encoding="utf-8")
    sys.stdout.write(encoded)
    return 0 if output["pass"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
