#!/usr/bin/env python3
"""Scorecard 生成器。

读取一个 run 目录(见 docs/run-protocol.md),按 docs/metrics-spec.md 输出 scorecard.json。

run 目录约定:
  meta.json               {benchmark, candidate_id, skill_version, run_id, agent_declared_done, human_interventions,
                           started_epoch, ended_epoch}
  cli/NNN-<family>.json   capture.sh 产出的 CLI 工件
  stage-timing.json       evaluator 从事件接收时刻推导的五段时间线
  tokens.json             可选 {total_tokens, input_tokens, cached_input_tokens,
                                non_cached_input_tokens, output_tokens,
                                reasoning_output_tokens, budget_tokens, reading_tokens}
  stages.json             可选 {stage: seconds}
  checklist-results.json  金标准探针结果 [{id, priority, status: pass|fail|missing,
                           mechanism: reuse|custom|missing, silent_downgrade: bool}]
  failures.json           可选 归因记录 [{stage, owner, note}]
  lifecycle.json          新 driver 的运行类型、预算、终态与完整性事实
"""
import datetime
import json
import re
import sys
from pathlib import Path


def load(path, default=None):
    p = Path(path)
    if not p.exists():
        return default
    return json.loads(p.read_text())


C5_STAGES = ("requirements", "model", "apply", "verify")
C5_OBSERVED_STAGES = ("discovery", "plan", "apply", "finalize", "verify")
STAGE_TIMING_CONTRACT = "domainry-eval-stage-timing-v1"
BUILDER_STATE_RELATIVE = Path(".domainry/builder")
BUILDER_STATE_PARENT_RELATIVE = Path(".domainry")
LEGACY_BUILDER_STATE_PREFIX = "builder-"

# 阶段产物时间戳来源(run/project/.domainry/builder 下,best-effort):
#   model      journal/model-sync-*.json、blueprint-validation.json
#   apply      model-apply.json、receipts/materialization*.json、receipts/finalization*.json
#   verify     receipts/verification*.json、receipts/package.json、runtime/runtime-process.json
# 局限:回执/域源文件被后续 evolution 轮覆盖时 mtime 只保留最后一次,首轮建模耗时会归并
# 到相邻阶段;requirements 无可靠产物时间戳,恒为 null。


def builder_state_root(project):
    """Prefer the stable root and generically read one legacy root for old runs."""
    project = Path(project)
    parent = project / BUILDER_STATE_PARENT_RELATIVE
    current = project / BUILDER_STATE_RELATIVE
    if not parent.exists() and not parent.is_symlink():
        return current
    if parent.is_symlink() or not parent.is_dir():
        raise ValueError(f"Builder state parent is not a real directory: {parent}")
    candidates = [child for child in parent.iterdir()
                  if child.name == current.name
                  or child.name.startswith(LEGACY_BUILDER_STATE_PREFIX)]
    invalid = [child for child in candidates if child.is_symlink() or not child.is_dir()]
    if invalid:
        raise ValueError("invalid Builder state roots: " + ", ".join(map(str, invalid)))
    present = sorted(candidates)
    if len(present) > 1:
        raise ValueError("multiple Builder state roots exist: " + ", ".join(map(str, present)))
    return present[0] if present else current


def _fname_ts(name):
    """evidence 文件名内嵌时间戳,如 ...-20260818T161850568820Z.json → epoch 秒。"""
    m = re.search(r"-(\d{8}T\d{6})(\d*)Z", name)
    if not m:
        return None
    dt = datetime.datetime.strptime(m.group(1), "%Y%m%dT%H%M%S").replace(
        tzinfo=datetime.timezone.utc)
    frac = m.group(2)
    return dt.timestamp() + (int(frac) / 10 ** len(frac) if frac else 0.0)


def approx_stage_seconds(run, meta):
    """C5 mtime 近似:把相邻产物时间戳的间隔计入"后一个产物所属阶段"。

    返回 {stage: seconds|null} 或 None(项目产物不存在/无任何时间戳来源)。
    """
    project = Path(meta.get("project_path") or (Path(run) / "project"))
    state = builder_state_root(project)
    if not state.is_dir():
        return None

    events = []

    def add(stage, paths, prefer_name=False):
        for p in paths:
            if not p.is_file():
                continue
            ts = (_fname_ts(p.name) if prefer_name else None) or p.stat().st_mtime
            events.append((ts, stage))

    add("model", state.glob("journal/model-sync-*.json"))
    add("model", [state / "blueprint-validation.json"])
    add("apply", [state / "model-apply.json",
                  state / "receipts" / "materialization.json",
                  state / "receipts" / "runtime-client-materialization.json"])
    add("apply", state.glob("receipts/finalization*.json"))
    add("verify", state.glob("receipts/verification*.json"))
    add("verify", [state / "receipts" / "package.json"])
    add("verify", [state / "runtime" / "runtime-process.json"])

    if not events:
        return None
    events.sort()
    secs = {s: None for s in C5_STAGES}
    prev = events[0][0]
    if meta.get("started_epoch"):
        prev = min(prev, meta["started_epoch"])
    for ts, stage in events:
        secs[stage] = (secs[stage] or 0) + (ts - prev)
        prev = ts
    ended = meta.get("ended_epoch")
    if ended and ended > prev:
        # 末段(最后产物 → 结束)计给最后一个产物所属阶段
        last_stage = events[-1][1]
        secs[last_stage] = (secs[last_stage] or 0) + (ended - prev)
    return {s: (None if v is None else round(v)) for s, v in secs.items()}


def first_of(artifacts, family):
    for a in artifacts:
        if a["family"] == family:
            return a
    return None


def derive_a_from_receipts(run, project=None):
    """Agent-driven run 回退:从 project/.domainry/ 回执推导 A1-A4 最终事实。

    语义与局限:回执多为"最后状态"文件(演化轮覆盖),推导口径是
    「成功回执存在、状态干净、且无对应失败回执」——与 cli-capture 的
    「首次调用即通过」并非严格同义;字段来源在 A_source 里标
    receipts-derived 以示区分。推不出的字段不出现在返回值里
    (调用方标 not_measurable)。
    """
    state = builder_state_root(project or (run / "project"))
    out = {}
    if not state.is_dir():
        return out

    # A1:model plan 的完整模型诊断。model-apply preflight 只作为无 CLI capture 时
    # 对最终模型可受理性的补充证据，不把 apply 成功冒充 plan 首过。
    bp = load(state / "blueprint-validation.json")
    ma = load(state / "model-apply.json")
    if isinstance(bp, dict) and bp.get("parse_status"):
        errs = len(bp.get("unsupported_capabilities") or [])
        if bp.get("parse_status") != "valid":
            errs = max(errs, 1)
        pf = ma.get("preflight") if isinstance(ma, dict) else None
        if isinstance(pf, dict) and isinstance(pf.get("issue_count"), int):
            errs += pf["issue_count"]
        out["A1"] = errs == 0
        out["A1_errors"] = errs

    # A2:apply model 事务回执 state=applied,且 model-sync journal 全部 committed
    # (whole-model sync 为原子事务,失败不落 committed journal)
    if isinstance(ma, dict) and ma.get("state"):
        syncs = [load(p) for p in state.glob("journal/model-sync-*.json")]
        out["A2"] = ma["state"] == "applied" and all(
            isinstance(s, dict) and s.get("state") == "committed" for s in syncs)

    # A3:apply finalize 回执存在且 checks 全 passed。
    finalization = load(state / "receipts" / "finalization.json")
    final_checks = finalization.get("checks") if isinstance(finalization, dict) else None
    if isinstance(finalization, dict):
        if isinstance(final_checks, list) and final_checks:
            out["A3"] = all(c.get("status") == "passed" for c in final_checks)
        elif finalization.get("receipt_sha256"):
            out["A3"] = True

    # A4:verify 必须同时留下结构验证、包与已停止的同 cohort Runtime 证据。
    ver = load(state / "receipts" / "verification.json")
    package = load(state / "receipts" / "package.json")
    runtime = load(state / "runtime" / "runtime-process.json")
    if isinstance(ver, dict) and isinstance(ver.get("checks"), list) and ver["checks"]:
        out["A4"] = (
            all(c.get("status") == "passed" for c in ver["checks"])
            and isinstance(package, dict) and bool(package.get("receipt_sha256"))
            and isinstance(runtime, dict)
            and runtime.get("state") == "stopped"
            and runtime.get("cohort_state") == "current"
            and bool(runtime.get("stopped_at"))
        )

    return out


def normalize_stage_seconds(raw):
    """stages.json → {stage: seconds}。

    支持两种形态(docs/run-protocol.md):
      {stage: {"started": epoch, "ended": epoch}}   agent 产出(project/.domainry/development/)
      {stage: seconds}                              driver 手工(run 目录)
    """
    out = {}
    for s in C5_STAGES:
        v = (raw or {}).get(s)
        if isinstance(v, (int, float)) and not isinstance(v, bool):
            out[s] = round(v)
        elif (isinstance(v, dict)
              and isinstance(v.get("started"), (int, float))
              and isinstance(v.get("ended"), (int, float))):
            out[s] = round(v["ended"] - v["started"])
        else:
            out[s] = None
    return out


def normalize_agent_stage_seconds(raw, boundary_start, boundary_end):
    """Validate untrusted Agent epoch intervals before using them for C5."""
    unavailable = {stage: None for stage in C5_STAGES}
    if not isinstance(raw, dict):
        return unavailable, "invalid_shape"
    if not all(
        isinstance(value, (int, float)) and not isinstance(value, bool)
        for value in (boundary_start, boundary_end)
    ) or boundary_end < boundary_start:
        return unavailable, "invalid_lifecycle_boundary"

    result = dict(unavailable)
    previous_end = None
    open_stage = False
    observed = False
    for stage in C5_STAGES:
        value = raw.get(stage)
        if value is None:
            continue
        if not isinstance(value, dict):
            return unavailable, "invalid_shape"
        started = value.get("started")
        ended = value.get("ended")
        started_valid = isinstance(started, (int, float)) and not isinstance(started, bool)
        ended_valid = isinstance(ended, (int, float)) and not isinstance(ended, bool)
        if started is None and ended is None:
            continue
        observed = True
        if not started_valid or (ended is not None and not ended_valid):
            return unavailable, "invalid_shape"
        if (started < boundary_start or started > boundary_end
                or (ended_valid and (ended < boundary_start or ended > boundary_end))):
            return unavailable, "invalid_out_of_bounds"
        if ended_valid and ended < started:
            return unavailable, "invalid_interval"
        if open_stage or (previous_end is not None and started < previous_end):
            return unavailable, "invalid_non_monotonic"
        if ended_valid:
            result[stage] = round(ended - started)
            previous_end = ended
        else:
            open_stage = True
    return result, "valid" if observed else "unavailable"


def normalize_evaluator_stage_timing(raw, boundary_start, boundary_end):
    """Validate evaluator-owned stage intervals and recompute all summaries."""
    if (not isinstance(raw, dict)
            or raw.get("contract_version") != STAGE_TIMING_CONTRACT
            or raw.get("boundary_rule") != "evaluator-cli-transition-v1"
            or raw.get("stage_order") != list(C5_OBSERVED_STAGES)
            or not isinstance(raw.get("stages"), dict)):
        return None, "invalid_shape"
    if not all(
        isinstance(value, (int, float)) and not isinstance(value, bool)
        for value in (boundary_start, boundary_end)
    ) or boundary_end < boundary_start:
        return None, "invalid_lifecycle_boundary"

    raw_diagnostics = raw.get("diagnostic_intervals", [])
    if not isinstance(raw_diagnostics, list):
        return None, "invalid_shape"
    diagnostics = []
    for value in raw_diagnostics:
        if not isinstance(value, dict) or value.get("family") != "verify_fixture":
            return None, "invalid_shape"
        started = value.get("started_epoch")
        ended = value.get("ended_epoch")
        status = value.get("status")
        valid_started = (
            isinstance(started, (int, float)) and not isinstance(started, bool))
        valid_ended = (
            isinstance(ended, (int, float)) and not isinstance(ended, bool))
        if status == "observed":
            if not valid_started or not valid_ended:
                return None, "invalid_shape"
            if started < boundary_start or ended > boundary_end:
                return None, "invalid_out_of_bounds"
            if ended < started:
                return None, "invalid_interval"
            seconds = round(ended - started, 3)
        elif status == "in_progress":
            if not valid_started or ended is not None:
                return None, "invalid_shape"
            if started < boundary_start or started > boundary_end:
                return None, "invalid_out_of_bounds"
            seconds = None
        elif status == "unknown":
            if started is not None or ended is not None:
                return None, "invalid_shape"
            seconds = None
        else:
            return None, "invalid_shape"
        diagnostics.append({
            "family": "verify_fixture",
            "started_epoch": float(started) if valid_started else None,
            "ended_epoch": float(ended) if valid_ended else None,
            "seconds": seconds,
            "status": status,
            "failed": value.get("failed") if isinstance(value.get("failed"), bool) else None,
            "exit_code": (
                value.get("exit_code")
                if isinstance(value.get("exit_code"), int)
                and not isinstance(value.get("exit_code"), bool) else None),
            "start_provenance": value.get("start_provenance"),
            "end_provenance": value.get("end_provenance"),
            "scoring_effect": "none",
            "display_stage": "pre_verify_diagnostic",
        })

    stages = {}
    previous_end = None
    observed = []
    for stage in C5_OBSERVED_STAGES:
        value = raw["stages"].get(stage)
        if not isinstance(value, dict):
            return None, "invalid_shape"
        status = value.get("status")
        if status == "unknown":
            stages[stage] = {
                "started_epoch": None, "ended_epoch": None, "seconds": None,
                "status": "unknown", "start_provenance": None,
                "end_provenance": None,
            }
            continue
        started = value.get("started_epoch")
        ended = value.get("ended_epoch")
        if status != "observed" or not all(
            isinstance(point, (int, float)) and not isinstance(point, bool)
            for point in (started, ended)
        ):
            return None, "invalid_shape"
        if started < boundary_start or ended > boundary_end:
            return None, "invalid_out_of_bounds"
        if ended < started:
            return None, "invalid_interval"
        if previous_end is not None and started < previous_end:
            return None, "invalid_non_monotonic"
        seconds = round(ended - started, 3)
        stages[stage] = {
            "started_epoch": float(started),
            "ended_epoch": float(ended),
            "seconds": seconds,
            "status": "observed",
            "start_provenance": value.get("start_provenance"),
            "end_provenance": value.get("end_provenance"),
        }
        observed.append((stage, seconds))
        previous_end = ended

    unknown = [stage for stage in C5_OBSERVED_STAGES
               if stages[stage]["status"] == "unknown"]
    hotspot = max(observed, key=lambda value: value[1]) if observed else None
    status = "valid" if not unknown else "partial" if observed else "unavailable"
    return {
        "contract_version": STAGE_TIMING_CONTRACT,
        "boundary_rule": raw.get("boundary_rule"),
        "stage_order": list(C5_OBSERVED_STAGES),
        "status": status,
        "stages": stages,
        "critical_path": {
            "observed_seconds": round(sum(value for _, value in observed), 3),
            "unknown_stages": unknown,
            "hotspot": ({"stage": hotspot[0], "seconds": hotspot[1]}
                        if hotspot else None),
        },
        "diagnostic_intervals": diagnostics,
    }, status


def legacy_stage_seconds_from_evaluator(timing):
    stages = timing["stages"]

    def seconds(stage):
        return stages[stage]["seconds"]

    apply = None
    if seconds("apply") is not None and seconds("finalize") is not None:
        apply = round(seconds("apply") + seconds("finalize"), 3)
    return {
        "requirements": seconds("discovery"),
        "model": seconds("plan"),
        "apply": apply,
        "verify": seconds("verify"),
    }


def project_stage_report(raw, boundary_start, boundary_end, evaluator_seconds):
    reported, status = normalize_agent_stage_seconds(
        raw, boundary_start, boundary_end)
    comparison = {}
    for stage in C5_STAGES:
        observed = evaluator_seconds.get(stage)
        project = reported.get(stage)
        comparable = observed is not None and project is not None
        comparison[stage] = {
            "evaluator_seconds": observed,
            "reported_seconds": project,
            "delta_seconds": round(project - observed, 3) if comparable else None,
            "status": "comparable" if comparable else "unknown",
        }
    return {
        "source": "agent-stages.json" if raw is not None else None,
        "status": status if raw is not None else "unavailable",
        "stage_seconds": reported,
        "comparison": comparison,
    }


def main(run_dir, out_path=None):
    run = Path(run_dir)
    meta = load(run / "meta.json", {})
    lifecycle = load(run / "lifecycle.json", {})
    project = Path(meta.get("project_path") or (run / "project"))
    artifacts = [
        json.loads(p.read_text()) | {"_file": p.name}
        for p in sorted((run / "cli").glob("*.json"))
    ] if (run / "cli").exists() else []
    diagnostic_artifacts = [
        artifact for artifact in artifacts
        if artifact.get("family") == "verify_fixture"
    ]
    scoring_artifacts = [
        artifact for artifact in artifacts
        if artifact.get("family") != "verify_fixture"
    ]

    # A. 准确率漏斗
    v1 = first_of(scoring_artifacts, "model_plan")
    a1 = first_of(scoring_artifacts, "apply_model")
    f1 = first_of(scoring_artifacts, "apply_finalize")
    b1 = first_of(scoring_artifacts, "verify")
    acc = first_of(scoring_artifacts, "acceptance_check")

    def error_count(art):
        if art is None:
            return None
        out = art.get("output")
        if isinstance(out, dict):
            if isinstance(out.get("issue_count"), int):
                return out["issue_count"]
            for key in ("errors", "diagnostics", "findings"):
                if isinstance(out.get(key), list):
                    return len(out[key])
            # CLI 可能 exit 0 但仍显式返回失败状态。
            if out.get("state") in {
                "repair_required", "failed", "invalid", "blocked", "error", "stale",
            }:
                return 1
        return 0 if art["exit_code"] == 0 else 1

    def captured_first_pass(artifact, family):
        if artifact is None:
            return None
        if artifact.get("exit_code") != 0 or error_count(artifact) != 0:
            return False
        output = artifact.get("output")
        if not isinstance(output, dict):
            return False
        if family == "model_plan":
            return output.get("state") == "valid"
        if family == "apply_model":
            return output.get("state") in {"implementation_ready", "applied"}
        if family == "apply_finalize":
            return (
                output.get("state") == "finalized"
                or (
                    output.get("contract_version")
                    == "domainry-source-finalization-receipt-v2"
                    and isinstance(output.get("receipt_sha256"), str)
                    and bool(output["receipt_sha256"])
                )
            )
        if family == "verify":
            return output.get("state") == "verified_and_stopped"
        return True

    # 返工轮数:同 family 出现第 2+ 次且前一次未有效通过。
    rework = 0
    seen = {}
    for a in scoring_artifacts:
        fam = a["family"]
        if fam == "model_capability":
            continue
        failed = a["exit_code"] != 0 or (error_count(a) or 0) > 0
        if fam in seen and seen[fam]:
            rework += 1
        seen[fam] = failed

    retries = rework
    total_cli = len(scoring_artifacts)

    # B. 覆盖度
    checklist_document = load(run / "checklist-results.json", [])
    checklist_executed = not (
        isinstance(checklist_document, dict)
        and checklist_document.get("status") == "not_executed"
    )
    checklist = checklist_document
    if isinstance(checklist, dict):
        checklist = checklist.get("results", [])
    weight = lambda f: 2 if f.get("priority") == "P0" else 1
    scored = [f for f in checklist if f.get("status") != "deferred"]  # deferred: 本层级不可验证,延后到更高层级
    total_w = sum(weight(f) for f in scored) or None
    hit_w = sum(weight(f) for f in scored if f.get("status") == "pass")
    # 新结果显式声明 reuse_eligible，避免把必须由项目 Handler 实现的功能点
    # 错放进平台复用分母。旧 checklist 没有该字段时保持历史口径可读。
    reusable = [
        f for f in scored
        if (f.get("reuse_eligible") is True
            or ("reuse_eligible" not in f and f.get("mechanism") in ("reuse", "custom")))
    ]
    reuse = [f for f in reusable
             if f.get("mechanism") == "reuse" and f.get("status") == "pass"]
    golden_all_pass = bool(scored) and all(f.get("status") == "pass" for f in scored)

    # C. 成本
    tokens = load(run / "tokens.json", {})
    total_tokens = tokens.get("total_tokens")
    token_usage = {
        "input_tokens": tokens.get("input_tokens"),
        "cached_input_tokens": tokens.get("cached_input_tokens"),
        "non_cached_input_tokens": tokens.get("non_cached_input_tokens"),
        "output_tokens": tokens.get("output_tokens"),
        "reasoning_output_tokens": tokens.get("reasoning_output_tokens"),
        "budget_tokens": tokens.get("budget_tokens", total_tokens),
        "budget_basis": tokens.get(
            "budget_basis", "provider_cumulative_input_plus_output"),
        "cached_input_included_in_input": tokens.get(
            "cached_input_included_in_input", True),
        "reasoning_output_included_in_output": tokens.get(
            "reasoning_output_included_in_output", True),
        "observability_status": tokens.get(
            "observability_status",
            "legacy_total_only" if total_tokens is not None else "unavailable"),
    }
    # C5 uses evaluator-observed event boundaries first. Project-reported
    # stages are untrusted cross-validation evidence and never replace or
    # invalidate valid evaluator observations.
    agent_stages_path = project / ".domainry" / "development" / "stages.json"
    try:
        agent_stages = load(agent_stages_path) if agent_stages_path.exists() else None
    except (OSError, UnicodeDecodeError, json.JSONDecodeError):
        agent_stages = "invalid-json"
    driver_stages = load(run / "stages.json", {})
    agent_boundary_start = lifecycle.get("started_epoch", meta.get("started_epoch"))
    agent_boundary_end = lifecycle.get(
        "agent_ended_epoch", meta.get("agent_ended_epoch"))
    if agent_boundary_end is None:
        agent_boundary_end = lifecycle.get("ended_epoch", meta.get("ended_epoch"))
    evaluator_timing_raw = load(run / "stage-timing.json")
    c5_timing = None
    if evaluator_timing_raw is not None:
        c5_timing, c5_status = normalize_evaluator_stage_timing(
            evaluator_timing_raw, agent_boundary_start, agent_boundary_end)
        c5 = (
            legacy_stage_seconds_from_evaluator(c5_timing)
            if c5_timing is not None else {stage: None for stage in C5_STAGES})
        c5_source = "evaluator-events"
    elif driver_stages:
        c5, c5_source, c5_status = (
            normalize_stage_seconds(driver_stages), "stages.json", "valid")
    else:
        c5 = approx_stage_seconds(run, meta)
        c5_source = "mtime-approx" if c5 is not None else None
        c5_status = "approximate" if c5 is not None else "unavailable"
        if c5 is None:
            c5 = {stage: None for stage in C5_STAGES}
    c5_project_report = project_stage_report(
        agent_stages, agent_boundary_start, agent_boundary_end, c5)
    wall = None
    if meta.get("started_epoch") and meta.get("ended_epoch"):
        wall = meta["ended_epoch"] - meta["started_epoch"]

    failures = load(run / "failures.json", [])
    owner_counts = {}
    diagnostic_owner_counts = {}
    for f in failures:
        owner = f.get("owner") or "unattributed"
        target = (
            diagnostic_owner_counts
            if f.get("failure_kind") == "diagnostic" else owner_counts)
        target[owner] = target.get(owner, 0) + 1

    declared_done = bool(meta.get("agent_declared_done"))
    run_kind = lifecycle.get("run_kind") or meta.get("run_kind")
    terminal_state = lifecycle.get("state") or meta.get("terminal_state")
    measurement_complete = lifecycle.get("measurement_complete")
    if measurement_complete is None:
        measurement_complete = meta.get("measurement_complete")
    environment_valid = lifecycle.get("environment_valid")
    if environment_valid is None:
        environment_valid = meta.get("environment_valid", True)

    # A 组数据源:cli-capture 工件优先;agent-driven run 无 cli/ 时逐字段回退
    # 到 .domainry 回执推导;两边都推不出 → not_measurable(值 null)。
    # A measured lifecycle run is scored from its captured attempts.  Falling
    # back to final receipts there could turn a stage that never occurred (or
    # whose event was not captured) into a fabricated first-pass observation.
    # Receipt fallback remains available only for legacy, pre-driver runs.
    rec = {} if lifecycle else derive_a_from_receipts(run, project)

    a1_first = captured_first_pass(v1, "model_plan") if v1 is not None \
        else rec.get("A1")
    a1_errors = error_count(v1) if v1 is not None else rec.get("A1_errors")
    a2_first = captured_first_pass(a1, "apply_model") if a1 is not None \
        else rec.get("A2")
    a3_first = captured_first_pass(f1, "apply_finalize") if f1 is not None \
        else rec.get("A3")
    a4_first = captured_first_pass(b1, "verify") if b1 is not None \
        else rec.get("A4")
    if acc is not None:
        a5_first = acc["exit_code"] == 0
    elif checklist_executed:
        a5_first = golden_all_pass
    else:
        a5_first = None
    a6_rework = rework if scoring_artifacts else None

    def a_src(art, key):
        if art is not None:
            return "cli-capture"
        return "receipts-derived" if key in rec else "not_measurable"

    a_source = {
        "A1": a_src(v1, "A1"),
        "A2": a_src(a1, "A2"),
        "A3": a_src(f1, "A3"),
        "A4": a_src(b1, "A4"),
        "A5": (
            "cli-capture" if acc is not None else
            "golden-result" if checklist_executed else "not_measurable"
        ),
        "A6": "cli-capture" if scoring_artifacts else "not_measurable",
    }

    # 严格 pass@1 必须由当前四条评分 CLI family 的首次捕获证明。
    # 最终回执只能辅助定位，无法证明第一次调用；基础条件失败仍直接为 false。
    funnel = [x for x in (a1_first, a2_first, a3_first, a4_first, a5_first) if x is not None]
    if a6_rework is not None:
        funnel.append(a6_rework == 0)
    first_pass_captured = all(a is not None for a in (v1, a1, f1, b1))
    base_ok = (declared_done and golden_all_pass
               and meta.get("human_interventions", 0) == 0)
    pass_at_1_eligible = (
        run_kind != "convergence"
        and environment_valid is not False
        and measurement_complete is not False
        and terminal_state not in {
            "baseline_first_scoring_failure",
            "budget_exhausted_wall_clock",
            "budget_exhausted_tokens",
            "budget_exhausted_cli_invocations",
            "budget_exhausted_cli_retries",
            "invalid_agent_event_stream",
            "agent_process_failed",
            "delivery_incomplete",
            "acceptance_not_executed",
            "scorer_failed",
        }
    )
    if run_kind == "convergence":
        pass_at_1 = None
    elif not pass_at_1_eligible or not base_ok:
        pass_at_1 = False
    elif not first_pass_captured:
        pass_at_1 = None
    elif funnel:
        pass_at_1 = all(funnel)
    else:
        pass_at_1 = None

    mismatch = declared_done and checklist_executed and not golden_all_pass
    non_agent_owners = {"benchmark_defect", "cli_platform"}
    attributed_owners = {
        f.get("owner") for f in failures
        if f.get("owner") and f.get("failure_kind") != "diagnostic"
    }
    if not mismatch:
        false_done = False
        false_done_classification = "no_oracle_done_mismatch"
    elif attributed_owners and attributed_owners <= non_agent_owners:
        false_done = False
        false_done_classification = "benchmark_or_platform_mismatch"
    else:
        # Missing attribution retains the historical fail-closed behavior.
        false_done = True
        false_done_classification = (
            "agent_false_done" if attributed_owners else "unattributed_mismatch"
        )

    diagnostic_failed = [
        artifact for artifact in diagnostic_artifacts
        if artifact.get("exit_code") != 0 or (error_count(artifact) or 0) > 0
    ]
    diagnostic_first_failure = lifecycle.get("diagnostic_first_failure")
    if diagnostic_first_failure is None and diagnostic_failed:
        first = diagnostic_failed[0]
        diagnostic_first_failure = {
            "failure_kind": "diagnostic",
            "family": first.get("family"),
            "exit_code": first.get("exit_code"),
            "output": first.get("output"),
            "capture_file": first.get("capture_file") or (
                f"cli/{first.get('_file')}" if first.get("_file") else None),
            "scoring_effect": "none",
        }

    scorecard = {
        "scorer_schema": "domainry-builder-eval-v3",
        "benchmark": meta.get("benchmark"),
        "candidate_id": meta.get("candidate_id"),
        "skill_version": meta.get("skill_version"),
        "run_id": meta.get("run_id"),
        "run_kind": run_kind,
        "parent_run_id": lifecycle.get("parent_run_id") or meta.get("parent_run_id"),
        "terminal_state": terminal_state,
        "measurement_complete": measurement_complete,
        "environment_valid": environment_valid,
        "pass_at_1_eligible": pass_at_1_eligible,
        "pass_at_1": pass_at_1,
        "run_outcome_pass": (
            base_ok and measurement_complete is not False and environment_valid is not False),
        "A_source": a_source,
        "A1_plan_first_pass": a1_first,
        "A1_plan_error_count": a1_errors,
        "A2_apply_first_pass": a2_first,
        "A3_finalize_first_pass": a3_first,
        "A4_verify_first_pass": a4_first,
        "A5_acceptance_first_pass": a5_first,
        "A6_rework_rounds": a6_rework,
        # Keep A7 for old readers, but only label an Agent false-done when the
        # mismatch is not purely a frozen-oracle/platform defect.
        "A7_false_done": false_done,
        "A7_oracle_done_mismatch": mismatch,
        "A7_false_done_classification": false_done_classification,
        "B1_golden_hit_rate": None if total_w is None else round(hit_w / total_w, 4),
        "B1_hit_detail": {f["id"]: f.get("status") for f in checklist},
        "B2_silent_downgrade_count": sum(1 for f in checklist if f.get("silent_downgrade")),
        "B3_platform_reuse_rate": None if not reusable else round(len(reuse) / len(reusable), 4),
        "C1_wall_clock_seconds": wall,
        "C2_total_tokens": total_tokens,
        "C2_usage_breakdown": token_usage,
        "C3_reading_token_ratio": (
            round(tokens["reading_tokens"] / tokens["total_tokens"], 4)
            if tokens.get("total_tokens") and tokens.get("reading_tokens") is not None else None
        ),
        "C4_cli_invocations": total_cli,
        "C4_cli_retries": retries,
        "C4_diagnostic_cli": {
            "invocations": len(diagnostic_artifacts),
            "failures": len(diagnostic_failed),
            "first_failure": diagnostic_first_failure,
            "included_in_scoring_invocations": False,
            "included_in_retry_budget": False,
        },
        "C5_stage_seconds": c5,
        "C5_stage_seconds_source": c5_source,
        "C5_stage_seconds_status": c5_status,
        "C5_stage_timing": c5_timing,
        "C5_project_stage_report": c5_project_report,
        "D2_human_interventions": meta.get("human_interventions", 0),
        "failure_attribution": owner_counts or None,
        "diagnostic_failure_attribution": diagnostic_owner_counts or None,
        "scoring_first_failure": (
            lifecycle.get("scoring_first_failure", lifecycle.get("first_scoring_failure"))
            if lifecycle else None),
        "diagnostic_first_failure": diagnostic_first_failure,
    }

    out = Path(out_path) if out_path else run / "scorecard.json"
    out.write_text(json.dumps(scorecard, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps(scorecard, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    if len(sys.argv) not in (2, 3):
        sys.exit("usage: scorer.py <run_dir> [out_scorecard.json]")
    main(*sys.argv[1:])
