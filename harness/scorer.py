#!/usr/bin/env python3
"""Scorecard 生成器。

读取一个 run 目录(见 docs/run-protocol.md),按 docs/metrics-spec.md 输出 scorecard.json。

run 目录约定:
  meta.json               {benchmark, skill_version, run_id, agent_declared_done, human_interventions,
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


C5_STAGES = ("requirements", "model", "apply", "implement", "verify")
BUILDER_STATE_RELATIVE = Path(".domainry/builder")
BUILDER_STATE_PARENT_RELATIVE = Path(".domainry")
LEGACY_BUILDER_STATE_PREFIX = "builder-"

# 阶段产物时间戳来源(run/project/.domainry/builder 下,best-effort):
#   model      journal/model-sync-*.json、blueprint-validation.json
#   apply      model-apply.json、receipts/materialization*.json、audits/、journal/delivery-*.json
#   implement  evidence/development-gates/*/apply_*.json(文件名内嵌 UTC 时间戳)、receipts/finalization*.json
#   verify     evidence verify_*/accept*、receipts/verification*.json、receipts/package.json、
#              Runtime 业务旅程证据目录
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

    gates = state / "evidence" / "development-gates"
    add("model", state.glob("journal/model-sync-*.json"))
    add("model", [state / "blueprint-validation.json"])
    add("apply", [state / "model-apply.json",
                  state / "receipts" / "materialization.json",
                  state / "receipts" / "runtime-client-materialization.json"])
    add("apply", state.glob("audits/project-delivery-*.json"))
    add("apply", state.glob("journal/delivery-audit-*.json"))
    add("apply", state.glob("journal/delivery-repair-*.json"))
    add("implement", gates.glob("*/apply_*.json"), prefer_name=True)
    add("implement", state.glob("receipts/finalization*.json"))
    add("verify", gates.glob("*/verify_*.json"), prefer_name=True)
    add("verify", state.glob("receipts/verification*.json"))
    add("verify", [state / "receipts" / "package.json"])
    add("verify", gates.glob("*/accept*.json"), prefer_name=True)
    acc_dir = state / "acceptance"
    if acc_dir.is_dir():
        add("verify", acc_dir.rglob("*"))

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
    """Agent-driven run 回退:从 project/.domainry/ 回执推导 A1-A4 首过事实。

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

    # A1:blueprint-validation.json 诊断数 + model-apply preflight 诊断数
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

    # A2:model apply 事务回执 state=applied,且 model-sync journal 全部 committed
    # (whole-model sync 为原子事务,失败不落 committed journal)
    if isinstance(ma, dict) and ma.get("state"):
        syncs = [load(p) for p in state.glob("journal/model-sync-*.json")]
        out["A2"] = ma["state"] == "applied" and all(
            isinstance(s, dict) and s.get("state") == "committed" for s in syncs)

    # A3:project verification 回执 checks 全 passed。
    # 口径与 cli-capture 漏斗对齐:A3 只看 project_verify(finalize 拒收轮
    # 属 source_finalize family,从不进 A1-A4;其返工计入 A5,而 A5 在
    # receipts 模式下不可测,见 A_source)。
    ver = load(state / "receipts" / "verification.json")
    if isinstance(ver, dict) and isinstance(ver.get("checks"), list) and ver["checks"]:
        out["A3"] = all(c.get("status") == "passed" for c in ver["checks"])

    # A4:验收结果回执 0 failed(declared_gap 是 typed 声明缺口,非失败,
    # 与 done/passed_with_declared_gaps 终态一致)
    acc = load(run / "project" / ".domainry" / "development" /
               "acceptance-evidence" / "backend-acceptance-results.json")
    results = acc.get("results") if isinstance(acc, dict) else None
    if isinstance(results, list) and results:
        out["A4"] = all(r.get("state") in ("passed", "declared_gap") for r in results)

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
    v1 = first_of(artifacts, "model_validate")
    a1 = first_of(artifacts, "model_apply")
    b1 = first_of(artifacts, "project_verify")
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
            # CLI 可能 exit 0 但 state=repair_required
            if out.get("state") not in (None, "ok", "clean", "ready"):
                return 1
        return 0 if art["exit_code"] == 0 else 1

    # 返工轮数:同 family 出现第 2+ 次且前一次未有效通过(exit!=0 或仍有诊断);
    # 设计内交接(apply 停在 fail-closed 骨架)不计失败
    rework = 0
    seen = {}
    for a in artifacts:
        fam = a["family"]
        failed = (a["exit_code"] != 0 or (error_count(a) or 0) > 0) and \
            "fail-closed project source placeholder remains" not in str(a.get("output", ""))
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

    def designed_handoff(art):
        # apply 停在 fail-closed Handler 骨架是两阶段流程的设计内交接,不计失败
        return "fail-closed project source placeholder remains" in str(art.get("output", ""))

    # A 组数据源:cli-capture 工件优先;agent-driven run 无 cli/ 时逐字段回退
    # 到 .domainry 回执推导;两边都推不出 → not_measurable(值 null)。
    rec = derive_a_from_receipts(run)

    a1_first = (v1["exit_code"] == 0 and error_count(v1) == 0) if v1 is not None \
        else rec.get("A1")
    a1_errors = error_count(v1) if v1 is not None else rec.get("A1_errors")
    a2_first = (a1["exit_code"] == 0 or designed_handoff(a1)) if a1 is not None \
        else rec.get("A2")
    a3_first = b1["exit_code"] == 0 if b1 is not None else rec.get("A3")
    a4_first = acc["exit_code"] == 0 if acc is not None else rec.get("A4")
    # A5 定义为 cli 工件序列的返工轮数(metrics-spec:数据源=artifacts 序号),
    # 无 cli 捕获时不可测。
    a5_rework = rework if artifacts else None

    def a_src(art, key):
        if art is not None:
            return "cli-capture"
        return "receipts-derived" if key in rec else "not_measurable"

    a_source = {
        "A1": a_src(v1, "A1"),
        "A2": a_src(a1, "A2"),
        "A3": a_src(b1, "A3"),
        "A4": a_src(acc, "A4"),
        "A5": "cli-capture" if artifacts else "not_measurable",
    }

    # pass@1 只依据可测得的字段:
    #   基础条件(恒可测):done 声明、金标准全过、零人工干预;
    #   漏斗条件:仅纳入非 not_measurable 的首过字段与 A5;
    #   漏斗全部 not_measurable 且基础条件成立 → null(不可判),而不是 false。
    funnel = [x for x in (a1_first, a2_first, a3_first, a4_first) if x is not None]
    if a5_rework is not None:
        funnel.append(a5_rework == 0)
    base_ok = (declared_done and golden_all_pass
               and meta.get("human_interventions", 0) == 0)
    if not base_ok:
        pass_at_1 = False
    elif funnel:
        pass_at_1 = all(funnel)
    else:
        pass_at_1 = None

    scorecard = {
        "benchmark": meta.get("benchmark"),
        "skill_version": meta.get("skill_version"),
        "run_id": meta.get("run_id"),
        "pass_at_1": pass_at_1,
        "A_source": a_source,
        "A1_validate_first_pass": a1_first,
        "A1_validate_error_count": a1_errors,
        "A2_apply_first_pass": a2_first,
        "A3_build_first_pass": a3_first,
        "A4_acceptance_first_pass": a4_first,
        "A5_rework_rounds": a5_rework,
        "A6_false_done": declared_done and not golden_all_pass,
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
