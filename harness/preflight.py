#!/usr/bin/env python3
"""Fail-closed preflight for an installed Builder candidate and its service."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
import sys
import urllib.error
import urllib.request

import eval_config


HEALTH_CONTRACT = "domainry-control-plane-health-v1"
SEMVER_PATTERN = re.compile(
    r"^v?(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)"
    r"(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?"
    r"(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?$"
)


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


def parse_semver(value: object) -> tuple[int, int, int, tuple[str, ...]] | None:
    if not isinstance(value, str):
        return None
    match = SEMVER_PATTERN.fullmatch(value.strip())
    if match is None:
        return None
    return (
        int(match.group(1)), int(match.group(2)), int(match.group(3)),
        tuple(match.group(4).split(".")) if match.group(4) else (),
    )


def compare_semver(
    left: tuple[int, int, int, tuple[str, ...]],
    right: tuple[int, int, int, tuple[str, ...]],
) -> int:
    if left[:3] != right[:3]:
        return 1 if left[:3] > right[:3] else -1
    left_pre, right_pre = left[3], right[3]
    if not left_pre or not right_pre:
        if left_pre == right_pre:
            return 0
        return -1 if left_pre else 1
    for left_part, right_part in zip(left_pre, right_pre):
        if left_part == right_part:
            continue
        left_numeric, right_numeric = left_part.isdigit(), right_part.isdigit()
        if left_numeric and right_numeric:
            return 1 if int(left_part) > int(right_part) else -1
        if left_numeric != right_numeric:
            return -1 if left_numeric else 1
        return 1 if left_part > right_part else -1
    if len(left_pre) == len(right_pre):
        return 0
    return 1 if len(left_pre) > len(right_pre) else -1


def application_delivery_version(document: object) -> object:
    if not isinstance(document, dict):
        return None
    checks = document.get("checks")
    if isinstance(checks, list):
        for check in checks:
            if isinstance(check, dict) and check.get("name") == "application_delivery":
                detail = check.get("detail")
                if isinstance(detail, str) and detail.strip():
                    return detail.strip()
    return document.get("version")


def assess_candidate_update_risk(candidate_version: object, document: object) -> list[str]:
    """Reject only the version relation that makes the CLI mutate a frozen Skill.

    The production CLI auto-updates only when both versions are valid SemVer and
    the service Application Delivery is newer. Mirroring that exact predicate
    keeps auto-update as a product feature while preventing measured-run drift.
    """
    candidate = parse_semver(candidate_version)
    service = parse_semver(application_delivery_version(document))
    if candidate is None or service is None:
        return []
    if compare_semver(service, candidate) > 0:
        return ["service.application_delivery_newer_than_candidate"]
    return []


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
        if healthy:
            diagnostics.extend(assess_candidate_update_risk(
                candidate.get("skill_version"), health))
        if not healthy:
            service_state = "unhealthy"
        elif diagnostics:
            service_state = "candidate_update_risk"
        else:
            service_state = "healthy"
        service = {
            "state": service_state,
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
