#!/usr/bin/env python3
"""Validate the evaluator-owned requirements-stage design artifact."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any


EXPECTED_STAGES = ["requirements", "model", "apply", "implement", "verify", "done"]


def require(condition: bool, code: str, diagnostics: list[str]) -> None:
    if not condition:
        diagnostics.append(code)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("artifact", type=Path)
    args = parser.parse_args()
    artifact_path = args.artifact.resolve()
    document: dict[str, Any] = json.loads(artifact_path.read_text(encoding="utf-8"))
    diagnostics: list[str] = []
    repository = artifact_path.parents[2]

    require(
        document.get("contract_version") == "domainry-eval-requirements-stage-v1",
        "artifact.contract_version",
        diagnostics,
    )
    require(document.get("stage_scope") == "requirements", "artifact.stage_scope", diagnostics)
    require(document.get("workflow_target") == EXPECTED_STAGES, "artifact.workflow_target", diagnostics)
    require(document.get("next_stage_executed") is False, "artifact.model_must_not_run", diagnostics)

    baseline = document.get("baseline", {})
    require(baseline.get("baseline_eligible") is False, "baseline.eligibility", diagnostics)
    require(baseline.get("wall_ms") == 384_264, "baseline.wall_ms", diagnostics)
    require(baseline.get("cli_active_ms") == 2_071, "baseline.cli_active_ms", diagnostics)
    require(baseline.get("orchestration_idle_ms") == 382_193, "baseline.idle_ms", diagnostics)
    require(baseline.get("inter_attempt_unallocated_ms") == 94_335, "baseline.inter_attempt", diagnostics)
    timing_path = repository / "runs/m2-fieldservice-opt107-mysql-full-01/timing-distribution.json"
    if timing_path.is_file():
        source_timing = json.loads(timing_path.read_text(encoding="utf-8"))
        source_stage = source_timing.get("stages", {}).get("requirements", {})
        require(source_stage.get("wall_ms") == baseline.get("wall_ms"), "baseline.source_wall_ms", diagnostics)
        require(source_stage.get("cli_active_ms") == baseline.get("cli_active_ms"), "baseline.source_cli_active_ms", diagnostics)
        require(source_stage.get("orchestration_idle_ms") == baseline.get("orchestration_idle_ms"), "baseline.source_idle_ms", diagnostics)
        require(
            source_timing.get("unallocated", {}).get("requirements_inter_attempt_ms")
            == baseline.get("inter_attempt_unallocated_ms"),
            "baseline.source_inter_attempt",
            diagnostics,
        )
    else:
        diagnostics.append("baseline.timing_source_missing")

    profile = document.get("typed_demand_profile", {})
    require(profile.get("contract_version") == "domainry-requirements-demand-profile-v1", "profile.version", diagnostics)
    require(profile.get("compiler_owned_capability_keys") is True, "profile.compiler_owned_keys", diagnostics)
    require(profile.get("keyword_inference_forbidden") is True, "profile.keyword_inference", diagnostics)
    require(profile.get("full_prd_copy_forbidden") is True, "profile.no_prd_copy", diagnostics)
    require(profile.get("accepted_identity_bound") is True, "profile.identity_binding", diagnostics)
    require(bool(profile.get("closed_demand_kind_enum")), "profile.demand_kinds", diagnostics)

    checkpoint = document.get("accepted_checkpoint", {})
    require(checkpoint.get("contract_version") == "domainry-accepted-stage-checkpoint-v1", "checkpoint.version", diagnostics)
    require(checkpoint.get("stage") == "requirements", "checkpoint.stage", diagnostics)
    require(checkpoint.get("reuse_scope") == "stage_optimization_and_diagnostics_only", "checkpoint.scope", diagnostics)
    require(checkpoint.get("fresh_e2e_reuse_forbidden") is True, "checkpoint.fresh_e2e", diagnostics)
    required_identity = {
        "requirements_identity_sha256", "prd_sha256", "frontend_evidence_manifest_sha256",
        "source_authority_manifest_sha256", "requirements_contract_bundle_sha256",
        "cli_requirements_contract_sha256", "stage_receipt_sha256",
        "typed_demand_profile_sha256", "git_tree_sha256", "git_status_sha256",
    }
    require(required_identity <= set(checkpoint.get("identity_fields", [])), "checkpoint.identity_fields", diagnostics)
    require(bool(checkpoint.get("invalidation_codes")), "checkpoint.invalidation_codes", diagnostics)
    require(checkpoint.get("clone_target_must_be_independent_blank_workspace") is True, "checkpoint.blank_clone", diagnostics)

    timing = document.get("timing_policy", {})
    require(timing.get("stage_local_and_fresh_e2e_separate") is True, "timing.separation", diagnostics)
    require(timing.get("projected_requirements_ms") is None, "timing.no_projection", diagnostics)
    require(timing.get("fresh_e2e_claim_ms") is None, "timing.no_fresh_claim", diagnostics)

    changes = document.get("change_request", [])
    require(any(row.get("id") == "CR-RQ-001" for row in changes), "change.atomic_transition", diagnostics)
    require(any(row.get("id") == "CR-RQ-002" for row in changes), "change.atomic_finalize", diagnostics)
    require(any(row.get("id") == "CR-RQ-003" for row in changes), "change.typed_profile", diagnostics)
    require(any(row.get("id") == "CR-RQ-004" for row in changes), "change.checkpoint", diagnostics)

    for evidence in document.get("evidence", {}).get("baseline_files", []):
        path = repository / evidence.get("path", "")
        if not path.is_file():
            diagnostics.append(f"evidence.missing:{evidence.get('path', '')}")
            continue
        require(sha256(path) == evidence.get("sha256"), f"evidence.sha256:{evidence.get('path', '')}", diagnostics)
        if "bytes" in evidence:
            require(path.stat().st_size == evidence["bytes"], f"evidence.bytes:{evidence.get('path', '')}", diagnostics)

    output = {
        "contract_version": "domainry-eval-artifact-validation-v1",
        "state": "passed" if not diagnostics else "failed",
        "diagnostics": diagnostics,
        "artifact": str(artifact_path),
    }
    print(json.dumps(output, ensure_ascii=False, indent=2, sort_keys=True))
    return 0 if not diagnostics else 1


if __name__ == "__main__":
    raise SystemExit(main())
