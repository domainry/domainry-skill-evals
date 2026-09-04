#!/usr/bin/env python3
"""Scorecard 生成器。

读取一个 run 目录(见 docs/run-protocol.md),按 docs/metrics-spec.md 输出 scorecard.json。

run 目录约定:
  meta.json               {benchmark, candidate_id, skill_version, run_id, agent_declared_done, human_interventions,
                           started_epoch, ended_epoch}
  cli/NNN-<family>.json   capture.sh 产出的 CLI 工件
  tokens.json             可选 {total_tokens, reading_tokens}
  stages.json             可选 {stage: seconds}
  checklist-results.json  金标准探针结果 [{id, priority, status: pass|fail|missing,
                           mechanism: reuse|custom|missing, silent_downgrade: bool}]
  failures.json           可选 归因记录 [{stage, owner, note}]
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
    state = builder_state_root(Path(run) / "project")
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


def derive_a_from_receipts(run):
    """Agent-driven run 回退:从 project/.domainry/ 回执推导 A1-A4 最终事实。

    语义与局限:回执多为"最后状态"文件(演化轮覆盖),推导口径是
    「成功回执存在、状态干净、且无对应失败回执」——与 cli-capture 的
    「首次调用即通过」并非严格同义;字段来源在 A_source 里标
    receipts-derived 以示区分。推不出的字段不出现在返回值里
    (调用方标 not_measurable)。
    """
    state = builder_state_root(run / "project")
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


def main(run_dir, out_path=None):
    run = Path(run_dir)
    meta = load(run / "meta.json", {})
    artifacts = [
        json.loads(p.read_text()) | {"_file": p.name}
        for p in sorted((run / "cli").glob("*.json"))
    ] if (run / "cli").exists() else []

    # A. 准确率漏斗
    v1 = first_of(artifacts, "model_plan")
    a1 = first_of(artifacts, "apply_model")
    f1 = first_of(artifacts, "apply_finalize")
    b1 = first_of(artifacts, "verify")
    acc = first_of(artifacts, "acceptance_check")

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

    # 返工轮数:同 family 出现第 2+ 次且前一次未有效通过。
    rework = 0
    seen = {}
    for a in artifacts:
        fam = a["family"]
        if fam == "model_capability":
            continue
        failed = a["exit_code"] != 0 or (error_count(a) or 0) > 0
        if fam in seen and seen[fam]:
            rework += 1
        seen[fam] = failed

    retries = rework
    total_cli = len(artifacts)

    # B. 覆盖度
    checklist = load(run / "checklist-results.json", [])
    if isinstance(checklist, dict):
        checklist = checklist.get("results", [])
    weight = lambda f: 2 if f.get("priority") == "P0" else 1
    scored = [f for f in checklist if f.get("status") != "deferred"]  # deferred: 本层级不可验证,延后到更高层级
    total_w = sum(weight(f) for f in scored) or None
    hit_w = sum(weight(f) for f in scored if f.get("status") == "pass")
    reusable = [f for f in scored if f.get("mechanism") in ("reuse", "custom")]
    reuse = [f for f in scored if f.get("mechanism") == "reuse"]
    golden_all_pass = bool(scored) and all(f.get("status") == "pass" for f in scored)

    # C. 成本
    tokens = load(run / "tokens.json", {})
    # C5 读取顺序:agent 产出的 project/.domainry/development/stages.json(实时记录,
    # 不受后期演化污染)> run 目录 stages.json(driver 手工)> 产物 mtime/文件名
    # 时间戳 best-effort 近似(会被后期演化轮覆盖产物污染,仅兜底)
    agent_stages = load(run / "project" / ".domainry" / "development" / "stages.json")
    driver_stages = load(run / "stages.json", {})
    if agent_stages:
        c5, c5_source = normalize_stage_seconds(agent_stages), "agent-stages.json"
    elif driver_stages:
        c5, c5_source = normalize_stage_seconds(driver_stages), "stages.json"
    else:
        c5 = approx_stage_seconds(run, meta)
        c5_source = "mtime-approx" if c5 is not None else None
    wall = None
    if meta.get("started_epoch") and meta.get("ended_epoch"):
        wall = meta["ended_epoch"] - meta["started_epoch"]

    failures = load(run / "failures.json", [])
    owner_counts = {}
    for f in failures:
        owner_counts[f.get("owner", "unknown")] = owner_counts.get(f.get("owner", "unknown"), 0) + 1

    declared_done = bool(meta.get("agent_declared_done"))

    # A 组数据源:cli-capture 工件优先;agent-driven run 无 cli/ 时逐字段回退
    # 到 .domainry 回执推导;两边都推不出 → not_measurable(值 null)。
    rec = derive_a_from_receipts(run)

    a1_first = (v1["exit_code"] == 0 and error_count(v1) == 0) if v1 is not None \
        else rec.get("A1")
    a1_errors = error_count(v1) if v1 is not None else rec.get("A1_errors")
    a2_first = (a1["exit_code"] == 0 and error_count(a1) == 0) if a1 is not None \
        else rec.get("A2")
    a3_first = (f1["exit_code"] == 0 and error_count(f1) == 0) if f1 is not None \
        else rec.get("A3")
    a4_first = (b1["exit_code"] == 0 and error_count(b1) == 0) if b1 is not None \
        else rec.get("A4")
    a5_first = acc["exit_code"] == 0 if acc is not None else golden_all_pass
    a6_rework = rework if artifacts else None

    def a_src(art, key):
        if art is not None:
            return "cli-capture"
        return "receipts-derived" if key in rec else "not_measurable"

    a_source = {
        "A1": a_src(v1, "A1"),
        "A2": a_src(a1, "A2"),
        "A3": a_src(f1, "A3"),
        "A4": a_src(b1, "A4"),
        "A5": "cli-capture" if acc is not None else "golden-result",
        "A6": "cli-capture" if artifacts else "not_measurable",
    }

    # 严格 pass@1 必须由当前四条评分 CLI family 的首次捕获证明。
    # 最终回执只能辅助定位，无法证明第一次调用；基础条件失败仍直接为 false。
    funnel = [x for x in (a1_first, a2_first, a3_first, a4_first, a5_first) if x is not None]
    if a6_rework is not None:
        funnel.append(a6_rework == 0)
    first_pass_captured = all(a is not None for a in (v1, a1, f1, b1))
    base_ok = (declared_done and golden_all_pass
               and meta.get("human_interventions", 0) == 0)
    if not base_ok:
        pass_at_1 = False
    elif not first_pass_captured:
        pass_at_1 = None
    elif funnel:
        pass_at_1 = all(funnel)
    else:
        pass_at_1 = None

    scorecard = {
        "scorer_schema": "domainry-builder-eval-v2",
        "benchmark": meta.get("benchmark"),
        "candidate_id": meta.get("candidate_id"),
        "skill_version": meta.get("skill_version"),
        "run_id": meta.get("run_id"),
        "pass_at_1": pass_at_1,
        "A_source": a_source,
        "A1_plan_first_pass": a1_first,
        "A1_plan_error_count": a1_errors,
        "A2_apply_first_pass": a2_first,
        "A3_finalize_first_pass": a3_first,
        "A4_verify_first_pass": a4_first,
        "A5_acceptance_first_pass": a5_first,
        "A6_rework_rounds": a6_rework,
        "A7_false_done": declared_done and not golden_all_pass,
        "B1_golden_hit_rate": None if total_w is None else round(hit_w / total_w, 4),
        "B1_hit_detail": {f["id"]: f.get("status") for f in checklist},
        "B2_silent_downgrade_count": sum(1 for f in checklist if f.get("silent_downgrade")),
        "B3_platform_reuse_rate": None if not reusable else round(len(reuse) / len(reusable), 4),
        "C1_wall_clock_seconds": wall,
        "C2_total_tokens": tokens.get("total_tokens"),
        "C3_reading_token_ratio": (
            round(tokens["reading_tokens"] / tokens["total_tokens"], 4)
            if tokens.get("total_tokens") and tokens.get("reading_tokens") is not None else None
        ),
        "C4_cli_invocations": total_cli,
        "C4_cli_retries": retries,
        "C5_stage_seconds": c5,
        "C5_stage_seconds_source": c5_source,
        "D2_human_interventions": meta.get("human_interventions", 0),
        "failure_attribution": owner_counts or None,
    }

    out = Path(out_path) if out_path else run / "scorecard.json"
    out.write_text(json.dumps(scorecard, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps(scorecard, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    if len(sys.argv) not in (2, 3):
        sys.exit("usage: scorer.py <run_dir> [out_scorecard.json]")
    main(*sys.argv[1:])
