#!/usr/bin/env python3
"""从交付物离线派生 golden probe 的环境参数默认值(S1 工单系统 / M2 现场服务)。

数据源(离线可得,不需要 Runtime 在线):
  <project_dir>/.domainry/builder/project-delivery/runtime-manifest.json
  —— Builder 发布产物,含 objects/actions/state_machines/roles/identity_bootstrap/
     seed_records/reports/report_export_controls。
  <project_dir>/.domainry/builder/runtime/acceptance-secrets.json(仅取键名核对身份 id,
  不读取密码值)。

用法:
  probe_derive.py [--task s1|m2] <project_dir>             打印派生结果 JSON(含 notes)
  probe_derive.py [--task s1|m2] --export <project_dir>    打印 shell export 行(可 eval)

库用法:
  derive_s1_params(project_dir) -> {"params": {...}, "notes": [...]}
  derive_m2_params(project_dir) -> {"params": {...}, "notes": [...]}
  派生失败抛 DeriveError,错误信息说明缺什么;调用方保证显式环境变量优先于派生值。

背景:TICKET_FIELDS/IDEM_FIELD/TRANSITION_BODY/CREATE_ACTION 等曾靠手工配置,
配错导致整轮验收级联假失败(opt-12 CREATE_ACTION 缺失、opt-13 TICKET_FIELDS 无
request_no)。M2 探针的参数量更大(身份/对象/动作/字段/payload 形状/种子 fixture),
run m2-fieldservice-95bda9c73eaf-01 仍靠 driver 手工配参(driver-notes.md);
本模块从真实契约推导,消除该类配置成本与配置错误。
"""
import json
import re
import sys
from pathlib import Path

STATE_RELATIVE = Path(".domainry/builder")
STATE_PARENT_RELATIVE = Path(".domainry")
LEGACY_STATE_PREFIX = "builder-"
MANIFEST_SUFFIX = "project-delivery/runtime-manifest.json"
SECRETS_SUFFIX = "runtime/acceptance-secrets.json"


class DeriveError(Exception):
    pass


def _state_root(project_dir):
    project = Path(project_dir)
    parent = project / STATE_PARENT_RELATIVE
    current = project / STATE_RELATIVE
    if not parent.exists() and not parent.is_symlink():
        return current
    if parent.is_symlink() or not parent.is_dir():
        raise DeriveError(f"Builder 状态父目录不是普通目录:{parent}")
    candidates = [child for child in parent.iterdir()
                  if child.name == current.name or child.name.startswith(LEGACY_STATE_PREFIX)]
    invalid = [child for child in candidates if child.is_symlink() or not child.is_dir()]
    if invalid:
        raise DeriveError("Builder 状态根不是普通目录:" + ",".join(map(str, invalid)))
    present = sorted(candidates)
    if len(present) > 1:
        raise DeriveError("检测到多个 Builder 状态根,拒绝猜测:" + ",".join(map(str, present)))
    return present[0] if present else current


def _load_manifest(project_dir):
    p = _state_root(project_dir) / MANIFEST_SUFFIX
    if not p.is_file():
        raise DeriveError(
            f"缺少运行时清单 {p}(派生探针参数需要 Builder 发布产物;"
            "请确认 project_dir 指向 agent 项目目录,且该项目已完成 model apply/发布)")
    try:
        return json.loads(p.read_text())
    except Exception as e:
        raise DeriveError(f"运行时清单 {p} 解析失败:{e}")


def _match_actions(actions, keywords):
    return [a for a in actions
            if any(k in (a.get("key") or "") or k in (a.get("audit_event") or "")
                   for k in keywords)]


def _payload_keys(action):
    return [f.get("key") for f in action.get("payload_fields") or []]


def _relation_target(field):
    """兼容 metadata 中 relation 目标的几种稳定表达。"""
    return (field.get("target_object_key")
            or (field.get("config") or {}).get("object_key")
            or (field.get("config") or {}).get("target")
            or (field.get("validation") or {}).get("target"))


def _s1_writable_ticket_fields(manifest, ticket):
    fields = ticket.get("fields") or []
    state_fields = {
        sm.get("state_field") or sm.get("field_key")
        for sm in manifest.get("state_machines") or []
        if sm.get("object_key") == "ticket"
        and (sm.get("state_field") or sm.get("field_key"))
    }
    runtime_owned = set(state_fields)
    for field in fields:
        key = field.get("key")
        config = field.get("config") or {}
        if config.get("auto_assign_current_user") or config.get("scope_owner"):
            runtime_owned.add(key)
        if key in {"owner_department_id", "owner_department_path"}:
            runtime_owned.add(key)
    writable = [field.get("key") for field in fields
                if field.get("key") not in runtime_owned]
    return writable, runtime_owned


def _s1_status_report_key(manifest):
    reports = [r.get("key") for r in manifest.get("reports") or [] if r.get("key")]
    status_reports = [key for key in reports if "status" in key and "ticket" in key]
    if len(status_reports) == 1:
        return status_reports[0]
    if len(reports) == 1:
        return reports[0]
    raise DeriveError(
        f"无法唯一派生工单状态报表 key:reports={reports};"
        "请用显式环境变量 REPORT_STATUS 指定")


def derive_s1_params(project_dir):
    m = _load_manifest(project_dir)
    notes = []
    params = {}

    # --- 对象与字段 ---
    objects = {o.get("key"): o for o in m.get("objects", [])}
    if "ticket" not in objects:
        raise DeriveError(
            "清单 objects 中没有 key='ticket' 的对象;实际对象:" + str(sorted(objects)))
    raw_ticket_fields = objects["ticket"].get("fields") or []
    ticket_fields = [f.get("key") for f in raw_ticket_fields]
    if not ticket_fields:
        raise DeriveError("ticket 对象没有字段定义,无法派生 TICKET_FIELDS")

    # TICKET_FIELDS controls the payload sent to direct CRUD create/update. A
    # field being present in the object contract does not imply that clients
    # may write it: state-machine state, automatic scope ownership and Runtime
    # governance fields are managed by the Runtime itself.
    writable_ticket_fields, runtime_owned = _s1_writable_ticket_fields(
        m, objects["ticket"])
    if not writable_ticket_fields:
        raise DeriveError("ticket 对象没有可由 CRUD 探针写入的字段")
    params["TICKET_FIELDS"] = ",".join(writable_ticket_fields)
    if runtime_owned:
        notes.append("CRUD payload 排除 Runtime 管理字段:" + str(sorted(runtime_owned)))

    params["REPORT_STATUS"] = _s1_status_report_key(m)

    comment_obj = objects.get("ticket_comment")

    actions = m.get("actions", [])
    ticket_actions = [a for a in actions if a.get("object_key") == "ticket"
                      or a.get("key", "").startswith("ticket.")]

    def pick_unique(role, keywords, pool, required):
        hits = _match_actions(pool, keywords)
        if len(hits) == 1:
            return hits[0]
        if not hits:
            if required:
                raise DeriveError(
                    f"找不到 {role} 动作(关键词 {keywords});"
                    f"清单动作:{sorted(a.get('key') for a in actions)}")
            return None
        raise DeriveError(
            f"{role} 动作匹配到多个候选 {sorted(a.get('key') for a in hits)},"
            "请用显式环境变量指定")

    # --- 状态机转换动作(F02/F05/F06/F07 必需) ---
    trans = {
        "ACT_START": pick_unique("start", ("start", "progress"), ticket_actions, True),
        "ACT_RESOLVE": pick_unique("resolve", ("resolve",), ticket_actions, True),
        "ACT_CLOSE": pick_unique("close", ("close",), ticket_actions, True),
        "ACT_REOPEN": pick_unique("reopen", ("reopen",), ticket_actions, True),
    }
    for k, a in trans.items():
        params[k] = a["key"]

    # --- 分派动作与字段(F04 必需) ---
    assign = pick_unique("assign", ("assign",), ticket_actions, True)
    params["ACT_ASSIGN"] = assign["key"]
    idem_candidates = set()
    for a in actions:
        for k in a.get("idempotency_keys") or []:
            idem_candidates.add(k)
    if len(idem_candidates) > 1:
        raise DeriveError(
            f"各动作幂等字段不一致 {sorted(idem_candidates)},探针只支持单一 IDEM_FIELD,"
            "请用显式环境变量指定")
    idem_field = next(iter(idem_candidates), None)
    if idem_field:
        params["IDEM_FIELD"] = idem_field
    else:
        notes.append("清单动作无 idempotency_keys,IDEM_FIELD 保持探针默认(仅 handler 模式使用)")
    assign_fields = [k for k in _payload_keys(assign)
                     if k not in (idem_field, "expected_updated_at", "version")]
    if len(assign_fields) == 1:
        params["ASSIGN_FIELD"] = assign_fields[0]
    else:
        guess = [k for k in assign_fields if "assign" in k or "owner" in k] or \
                [k for k in ticket_fields if "assign" in k]
        if not guess:
            raise DeriveError(
                f"无法从 {assign['key']} 的 payload {assign_fields} 或 ticket 字段推导 ASSIGN_FIELD")
        params["ASSIGN_FIELD"] = guess[0]

    # --- 创建/更新/评论模式(缺失表示走直接 CRUD,合法) ---
    create = next((a for a in ticket_actions
                   if a.get("kind") == "object_operation" and "create" in a.get("key", "")), None)
    params["CREATE_ACTION"] = create["key"] if create else ""
    if not create:
        notes.append("无 create handler 动作,创建走直接 CRUD(CREATE_ACTION 空)")

    update = next((a for a in ticket_actions
                   if a.get("kind") == "record_operation"
                   and ("update" in a.get("key", "") or "edit" in a.get("key", ""))), None)
    params["UPDATE_ACTION"] = update["key"] if update else ""
    if not update:
        notes.append("无 update 动作,更新走直接 CRUD PATCH(UPDATE_ACTION 空)")

    comment_record = next((a for a in ticket_actions
                           if a.get("kind") == "record_operation"
                           and "comment" in a.get("key", "")), None)
    comment_obj_action = next(
        (a for a in actions
         if a.get("object_key") == "ticket_comment" and a.get("kind") == "object_operation"),
        None)
    params["COMMENT_RECORD_ACTION"] = comment_record["key"] if comment_record else ""
    params["COMMENT_ACTION"] = "" if comment_record else (
        comment_obj_action["key"] if comment_obj_action else "")
    comment_src = comment_record or comment_obj_action

    content_field = None
    if comment_src:
        cands = [f for f in comment_src.get("payload_fields") or []
                 if f.get("key") not in (idem_field, "expected_updated_at", "version", "ticket_id")
                 and f.get("type") in ("text", "long_text", None)]
        req = [f for f in cands if f.get("required")]
        if len(req) == 1:
            content_field = req[0]["key"]
        elif len(cands) == 1:
            content_field = cands[0]["key"]
    if content_field is None and comment_obj is not None:
        ckeys = [f.get("key") for f in comment_obj.get("fields") or []]
        content_field = next((k for k in ("content", "body", "text", "message", "comment")
                              if k in ckeys), None)
        if content_field is None:
            raise DeriveError(
                f"无法从 ticket_comment 字段 {ckeys} 推导 COMMENT_FIELD,请显式指定")
    if content_field:
        params["COMMENT_FIELD"] = content_field
    else:
        notes.append("交付物无评论动作也无 ticket_comment 对象,COMMENT_FIELD 保持探针默认"
                     "(F09 将按能力缺失如实判负)")

    # --- 转换请求体形态 ---
    sm = next((s for s in m.get("state_machines", [])
               if s.get("object_key") == "ticket"), None)
    status_key = (sm or {}).get("field_key", "status")
    trans_payloads = [set(_payload_keys(a)) for a in trans.values()]
    if any(status_key in p for p in trans_payloads):
        params["TRANSITION_BODY"] = "status"
    elif any(p for p in trans_payloads):
        params["TRANSITION_BODY"] = "idem_only"  # handler 型转换:只收幂等字段,不收 status
    else:
        params["TRANSITION_BODY"] = "status"      # transition_state 型:请求体带目标 status
    notes.append(f"TRANSITION_BODY={params['TRANSITION_BODY']}"
                 f"(转换动作 payload:{[sorted(p) for p in trans_payloads]})")

    # --- 验收身份(角色按 close vs start/resolve 权限区分) ---
    def role_has(role, action):
        perms = set(role.get("permissions") or [])
        want = action.get("requires_permission") or action.get("key")
        if want in perms or action.get("key") in perms:
            return True
        # 权限键命名方差(两段式/三段式):按末段关键词兜底
        tail = action.get("key", "").split(".")[-1]
        return any(tail and tail in p for p in perms)

    roles = m.get("roles", [])
    manager_roles = {r.get("key") for r in roles if role_has(r, trans["ACT_CLOSE"])}
    agent_roles = {r.get("key") for r in roles
                   if role_has(r, trans["ACT_START"]) or role_has(r, trans["ACT_RESOLVE"])}
    if not manager_roles:
        raise DeriveError(
            f"没有角色持有关闭权限({trans['ACT_CLOSE'].get('requires_permission')}),"
            "无法推导 MANAGER")
    users = (m.get("identity_bootstrap") or {}).get("users", [])
    managers = sorted(u["id"] for u in users
                      if set(u.get("role_keys") or []) & manager_roles)
    agents = sorted(u["id"] for u in users
                    if set(u.get("role_keys") or []) & agent_roles)
    if not managers:
        raise DeriveError(f"identity_bootstrap 无持 {sorted(manager_roles)} 角色的用户,"
                          "无法推导 MANAGER")
    if len(agents) < 2:
        raise DeriveError(f"identity_bootstrap 持 {sorted(agent_roles)} 角色的用户不足 2 个"
                          f"({agents}),无法推导 AGENT_A/AGENT_B")
    params["MANAGER"] = managers[0]
    params["AGENT_A"], params["AGENT_B"] = agents[0], agents[1]

    assign_field = next(
        (f for f in raw_ticket_fields if f.get("key") == params["ASSIGN_FIELD"]), {})
    assign_target = _relation_target(assign_field)

    def owner_value(user_id):
        if not assign_target:
            return user_id
        hits = [s for s in m.get("seed_records") or []
                if s.get("object_key") == assign_target
                and (s.get("data") or {}).get("identity_user_id") == user_id]
        if len(hits) != 1 or not (hits[0].get("data") or {}).get("__seed_key"):
            raise DeriveError(
                f"无法为 {user_id} 唯一派生 {assign_target} owner seed")
        return f"{assign_target}_{hits[0]['data']['__seed_key']}"

    params["AGENT_A_OWNER"] = owner_value(params["AGENT_A"])
    params["AGENT_B_OWNER"] = owner_value(params["AGENT_B"])
    comment_author_fields = [f.get("key") for f in (comment_obj or {}).get("fields") or []
                             if "author" in (f.get("key") or "")]
    params["COMMENT_AUTHOR_FIELD"] = (
        comment_author_fields[0] if len(comment_author_fields) == 1 else "")
    notes.append(f"角色映射:agent={sorted(agent_roles)} 用户 {agents};"
                 f"manager={sorted(manager_roles)} 用户 {managers}")

    return {"params": params, "notes": notes}


# ---------------------------------------------------------------------------
# M2 fieldservice(benchmarks/m2-fieldservice/golden-probe.py)
# 对照真值:runs/m2-fieldservice-95bda9c73eaf-01/driver-notes.md 的手工配参清单。
# ---------------------------------------------------------------------------

def _seed_rid(object_key, seed_key):
    """Runtime 种子记录 id 约定:<object_key>_<__seed_key>(实证:service_site_site_east、
    repair_order_ro_waiver_small、warranty_waiver_wv_pending_reject 均按此存库)。"""
    return f"{object_key}_{seed_key}"


def _resolve_ref(ref, seed_key_to_obj):
    """种子内引用 '$record:<seed_key>' -> 记录 id。"""
    if not (isinstance(ref, str) and ref.startswith("$record:")):
        return ref
    sk = ref[len("$record:"):]
    obj = seed_key_to_obj.get(sk)
    if not obj:
        raise DeriveError(f"种子引用 {ref} 找不到对应 __seed_key 的种子记录")
    return _seed_rid(obj, sk)


def derive_m2_params(project_dir):
    m = _load_manifest(project_dir)
    notes = []
    params = {}
    actions = m.get("actions", [])
    objects = {o.get("key"): o for o in m.get("objects", [])}

    def pick_kw(role, pool, keywords, exclude=(), required=True):
        hits = [a for a in _match_actions(pool, keywords)
                if not any(x in (a.get("key") or "") for x in exclude)]
        if len(hits) == 1:
            return hits[0]
        if not hits:
            if required:
                raise DeriveError(
                    f"找不到 {role} 动作(关键词 {keywords},排除 {exclude});"
                    f"候选池:{sorted(a.get('key') for a in pool)}")
            return None
        raise DeriveError(
            f"{role} 动作匹配到多个候选 {sorted(a.get('key') for a in hits)}"
            f"(关键词 {keywords}),请用显式环境变量指定")

    # --- 主对象:含 dispatch 类转换的状态机所属对象 ---
    sms = m.get("state_machines", [])
    req_sms = [s for s in sms
               if any("dispatch" in (t.get("action_key") or "")
                      for t in s.get("transitions") or [])]
    if len(req_sms) != 1:
        raise DeriveError(
            "无法唯一确定报修主对象的状态机(要求恰有一个状态机含 dispatch 类转换);"
            f"实际:{[s.get('key') for s in req_sms] or [s.get('key') for s in sms]}")
    req_sm = req_sms[0]
    obj_req = req_sm["object_key"]
    params["OBJ_REQ"] = obj_req
    params["F_STATUS"] = req_sm.get("field_key", "status")
    req_field_defs = objects.get(obj_req, {}).get("fields") or []
    req_fields = [f.get("key") for f in req_field_defs]

    # --- 状态键 ---
    states = req_sm.get("states") or []
    for env_key, kws in (("ST_SUBMITTED", ("submit",)), ("ST_DISPATCHED", ("dispatch",)),
                         ("ST_IN_REPAIR", ("repair", "progress")),
                         ("ST_COMPLETED", ("complete", "done"))):
        hit = [s for s in states if any(k in s for k in kws)]
        if len(hit) != 1:
            raise DeriveError(f"状态机 {req_sm.get('key')} 无法唯一匹配 {env_key}"
                              f"(关键词 {kws}):states={states},候选 {hit}")
        params[env_key] = hit[0]

    # --- 主对象动作(关键词启发;dispatch 需排除 undispatch/recall) ---
    pool = [a for a in actions if a.get("object_key") == obj_req]
    # adapted@m2-fieldservice-e3881bed55da-01:提交动作可命名 create_ticket 类
    submit = pick_kw("submit", pool, ("submit",), required=False) \
        or pick_kw("submit", pool, ("create",), exclude=("dispatch", "waiver"))
    dispatch = pick_kw("dispatch", pool, ("dispatch",),
                       exclude=("undispatch", "recall", "cancel", "remind", "overdue"))
    recall = pick_kw("recall", pool, ("undispatch", "recall"), required=False)
    start = pick_kw("start", pool, ("start",))
    complete = pick_kw("complete", pool, ("complete",))
    waiver_req = pick_kw("waiver", pool, ("waiver",), required=False)
    remind = pick_kw("remind", pool, ("remind", "overdue"), required=False)
    # adapted@m2-fieldservice-e3881bed55da-01:减免发起可为审批对象上的集合级动作
    # (payload 以 relation 字段引用主对象),此时探针走 WAIVER_STYLE=collection。
    params["WAIVER_STYLE"] = ""
    params["F_WAIVER_TICKET"] = f"{obj_req}_id"
    if not waiver_req:
        cands = []
        for a in actions:
            if a.get("object_key") == obj_req:
                continue
            if not any(k in (a.get("key") or "") for k in ("waiver", "initiate", "request")):
                continue
            if any(x in (a.get("key") or "") for x in ("approve", "reject", "export")):
                continue
            refs = [f for f in a.get("payload_fields") or []
                    if f.get("type") == "relation"
                    and (f.get("target_object_key") == obj_req
                         or f.get("key") in (f"{obj_req}_id", "ticket_id", "order_id"))]
            if len(refs) == 1:
                cands.append((a, refs[0]["key"]))
        if len(cands) != 1:
            raise DeriveError(
                "主对象无 waiver 类动作,且无法唯一确定集合级减免发起动作"
                f"(候选 {[a.get('key') for a, _ in cands]}),请显式指定 ACT_WAIVER/WAIVER_STYLE/F_WAIVER_TICKET")
        waiver_req, params["F_WAIVER_TICKET"] = cands[0]
        params["WAIVER_STYLE"] = "collection"
        notes.append(f"减免发起为集合级动作 {waiver_req['key']}(引用字段 {params['F_WAIVER_TICKET']})")
    params["ACT_SUBMIT"] = submit["key"]
    params["ACT_DISPATCH"] = dispatch["key"]
    params["ACT_RECALL"] = recall["key"] if recall else ""
    params["ACT_START"] = start["key"]
    params["ACT_COMPLETE"] = complete["key"]
    params["ACT_WAIVER"] = waiver_req["key"]
    params["ACT_REMIND"] = remind["key"] if remind else ""
    if not remind:
        notes.append("无 remind/overdue 类动作,N18 将按能力缺失如实判负(ACT_REMIND 空)")

    # --- 审批对象与 approve/reject 动作 ---
    waiver_objs = sorted({a.get("object_key") for a in actions
                          if "waiver" in (a.get("key") or "") and a.get("object_key") != obj_req})
    if len(waiver_objs) != 1:
        raise DeriveError(f"无法唯一确定减免审批对象(waiver 类动作所属对象):{waiver_objs}")
    obj_waiver = waiver_objs[0]
    params["OBJ_WAIVER"] = obj_waiver
    wpool = [a for a in actions if a.get("object_key") == obj_waiver]
    approve = pick_kw("approve", wpool, ("approve", "apply"))
    reject = pick_kw("reject", wpool, ("reject",))
    params["ACT_APPROVE"] = approve["key"]
    params["ACT_REJECT"] = reject["key"]

    # --- 受控导出(平台无通用 /records/export 路由,走交付声明的导出动作) ---
    controls = m.get("report_export_controls") or []
    if len(controls) == 1:
        c = controls[0]
        for k, v in (("ACT_EXPORT", c.get("export_action")),
                     ("OBJ_EXPORT", c.get("audit_object")),
                     ("EXPORT_REPORT_KEY", c.get("report_key"))):
            if not v:
                raise DeriveError(f"report_export_controls 缺少 {k} 对应字段:{c}")
            params[k] = v
    elif not controls:
        exp = pick_kw("export", actions, ("export",), required=False)
        params["ACT_EXPORT"] = exp["key"] if exp else ""
        params["OBJ_EXPORT"] = exp["object_key"] if exp else ""
        params["EXPORT_REPORT_KEY"] = ""
        notes.append("清单无 report_export_controls,"
                     + ("按 export 关键词动作兜底" if exp else "N20 回退平台通用导出路由(大概率 404)"))
    else:
        raise DeriveError(f"report_export_controls 有多个 {[c.get('key') for c in controls]},"
                          "请用显式环境变量指定 ACT_EXPORT/OBJ_EXPORT/EXPORT_REPORT_KEY")

    # --- payload 字段 ---
    def pf(action):
        return action.get("payload_fields") or []

    idem = (submit.get("idempotency_keys") or [None])[0]
    if not idem:
        raise DeriveError(f"{submit['key']} 无 idempotency_keys,无法派生 IDEM_FIELD")
    params["IDEM_FIELD"] = idem
    others = {k for a in (dispatch, start, complete, waiver_req)
              for k in a.get("idempotency_keys") or []}
    if others - {idem}:
        raise DeriveError(f"各动作幂等字段不一致:submit={idem} vs {sorted(others)},请显式指定")

    def unique_pf(action, role, pred):
        hit = [f for f in pf(action) if f.get("key") != idem and pred(f)]
        if len(hit) != 1:
            raise DeriveError(
                f"无法从 {action['key']} 的 payload {[(f.get('key'), f.get('type')) for f in pf(action)]} "
                f"唯一推导 {role}(候选 {[f.get('key') for f in hit]})")
        return hit[0]

    params["F_ASSIGNEE"] = unique_pf(dispatch, "F_ASSIGNEE", lambda f: f.get("type") == "user")["key"]
    # 站点字段可为 relation/select,也可由 handler 接收组织单元 id 文本。
    # adapted@m2-fieldservice-cfc514a2b129-01
    site_fields = [f for f in pf(dispatch)
                   if f.get("key") != params["F_ASSIGNEE"]
                   and any(k in (f.get("key") or "")
                           for k in ("site", "store", "organization_unit"))]
    if not site_fields:
        site_fields = [f for f in pf(dispatch)
                       if f.get("type") in ("relation", "select")
                       and f.get("key") != params["F_ASSIGNEE"]]
    params["SITE_FIELD"] = site_fields[0]["key"] if len(site_fields) == 1 else ""
    if len(site_fields) > 1:
        raise DeriveError(f"{dispatch['key']} 有多个 relation/select 字段 "
                          f"{[f.get('key') for f in site_fields]},无法确定 SITE_FIELD")
    # dispatch 契约可含额外必填字段(如 technician_name);探针按键名通用填充
    # adapted@m2-fieldservice-e3881bed55da-01
    params["SUBMIT_FIELDS"] = ",".join(f.get("key") for f in pf(submit))
    params["DISPATCH_FIELDS"] = ",".join(f.get("key") for f in pf(dispatch))
    params["COMPLETE_FIELDS"] = ",".join(f.get("key") for f in pf(complete))
    # 设备/装备字段由 submit 的唯一 relation 及主对象同名字段的 target 推导,
    # 不把英文单词 device 固化进业务契约。
    device_pf = unique_pf(submit, "F_DEVICE", lambda f: f.get("type") == "relation")
    params["F_DEVICE"] = device_pf["key"]
    device_field = next((f for f in req_field_defs if f.get("key") == device_pf["key"]), {})
    device_target = _relation_target(device_pf) or _relation_target(device_field)
    params["F_DESC"] = unique_pf(submit, "F_DESC",
                                 lambda f: f.get("type") == "long_text" and f.get("required"))["key"]
    # 报价是主对象的金额事实;可在 submit/dispatch/complete 任一业务阶段写入。
    quote_fields = [f for f in req_field_defs if f.get("type") == "currency"]
    if len(quote_fields) != 1:
        raise DeriveError(f"{obj_req} 无法唯一推导报价金额字段(候选 "
                          f"{[f.get('key') for f in quote_fields]})")
    params["F_QUOTE"] = quote_fields[0]["key"]
    quote_actions = [a["key"] for a in (submit, dispatch, complete)
                     if params["F_QUOTE"] in _payload_keys(a)]
    if not quote_actions:
        raise DeriveError(f"报价字段 {params['F_QUOTE']} 未出现在 submit/dispatch/complete 任一动作 payload")
    notes.append(f"报价字段 {params['F_QUOTE']} 由动作 {quote_actions} 写入")
    # 形态一:槽位式(part_<n>_id relation + part_<n>_qty integer 成对出现)
    # adapted@m2-fieldservice-cfc514a2b129-01
    slot_pat = re.compile(r"^(.*part.*?)(\d+)(_[a-z_]+)$")
    slot_pairs = {}
    for f in pf(complete):
        mt = slot_pat.match(f.get("key", ""))
        if mt:
            slot_pairs.setdefault(mt.group(2), {})[mt.group(3)] = (mt.group(1), f.get("type"))
    slot_ok = {n: v for n, v in slot_pairs.items()
               if any(t == "relation" for _, t in v.values()) and len(v) >= 2}
    if not slot_ok:
        # 形态一b:后缀编号槽位(part_id_1 relation + quantity_1 integer 成对)
        # adapted@m2-fieldservice-e3881bed55da-01
        suf_pat = re.compile(r"^([a-z_]+?)_(\d+)$")
        suf_pairs = {}
        for f in pf(complete):
            mt = suf_pat.match(f.get("key", ""))
            if mt:
                suf_pairs.setdefault(mt.group(2), {})[mt.group(1)] = f.get("type")
        good = {n: v for n, v in suf_pairs.items()
                if any(t == "relation" for t in v.values())
                and any(t != "relation" for t in v.values())}
        if good:
            n0 = sorted(good)[0]
            id_base = next(b for b, t in good[n0].items() if t == "relation")
            qty_base = next(b for b, t in good[n0].items() if t != "relation")
            params["PARTS_STYLE"] = "slots"
            params["PART_SLOT_ID_TPL"] = f"{id_base}_{{n}}"
            params["PART_SLOT_QTY_TPL"] = f"{qty_base}_{{n}}"
            params["PART_SLOT_MAX"] = str(len(good))
            params["PARTS_KEY"] = ""
            params["PARTS_AS_JSON"] = ""
        slot_ok = {}
    if params.get("PARTS_STYLE") == "slots":
        pass  # 已按形态一b 处理
    elif slot_ok:
        n0 = sorted(slot_ok)[0]
        id_suf = next(s for s, (_, t) in slot_ok[n0].items() if t == "relation")
        qty_suf = next(s for s, (_, t) in slot_ok[n0].items() if t != "relation")
        prefix = slot_ok[n0][id_suf][0]
        params["PARTS_STYLE"] = "slots"
        params["PART_SLOT_ID_TPL"] = f"{prefix}{{n}}{id_suf}"
        params["PART_SLOT_QTY_TPL"] = f"{prefix}{{n}}{qty_suf}"
        params["PART_SLOT_MAX"] = str(len(slot_ok))
        params["PARTS_KEY"] = ""
        params["PARTS_AS_JSON"] = ""
    else:
        parts_f = unique_pf(complete, "PARTS_KEY",
                            lambda f: f.get("type") in ("long_text", "text", "json", "list")
                            and any(k in f.get("key", "") for k in ("part", "consum", "usage")))
        params["PARTS_KEY"] = parts_f["key"]
        # 形态二:consumed_parts 为 long_text 时,明细行以 JSON 字符串而非数组提交
        params["PARTS_AS_JSON"] = "1" if parts_f.get("type") in ("long_text", "text") else ""
        params["PARTS_STYLE"] = ""
    params["F_WAIVER_AMT"] = unique_pf(waiver_req, "F_WAIVER_AMT",
                                       lambda f: f.get("type") == "currency")["key"]
    if remind:
        remind_fields = [f.get("key") for f in pf(remind)]
        if not remind_fields:
            raise DeriveError(f"{remind['key']} 无 payload_fields,无法派生 REMIND_FIELDS")
        params["REMIND_FIELDS"] = ",".join(remind_fields)
    # 拒绝/导出动作 payload 键序列(探针按键名通用填充;平台严格解码,多一个键即 400)
    # adapted@m2-fieldservice-cfc514a2b129-01:reject 要 decision_reason+request_id,export 无 reason
    params["REJECT_FIELDS"] = ",".join(f.get("key") for f in pf(reject))
    # 动作 payload 字段类型表(date/datetime 填充格式随交付契约变化)
    # adapted@m2-fieldservice-e3881bed55da-01:run_date 可为 datetime 型,需 RFC3339
    exp_act = (next((a for a in actions if a.get("key") == params["ACT_EXPORT"]), None)
               if params.get("ACT_EXPORT") else None)
    ftypes = {}
    for a in (submit, dispatch, start, complete, waiver_req, remind, reject, approve, exp_act):
        for f in pf(a) if a else []:
            ftypes[f.get("key")] = f.get("type")
    params["FIELD_TYPES"] = json.dumps(ftypes, sort_keys=True)
    if params.get("ACT_EXPORT"):
        params["EXPORT_FIELDS"] = ",".join(f.get("key") for f in pf(exp_act)) if exp_act else ""
    else:
        params["EXPORT_FIELDS"] = ""

    # --- 主对象字段(final / 老化字段) ---
    finals = [k for k in req_fields if "final" in k]
    if len(finals) > 1:
        raise DeriveError(f"{obj_req} 字段 {req_fields} 无法唯一推导 F_FINAL(候选 {finals})")
    params["F_FINAL"] = finals[0] if finals else ""
    params["OBJ_LEDGER"] = ""
    params["LEDGER_ORDER_FIELD"] = ""
    params["LEDGER_AMOUNT_FIELD"] = ""
    if not finals:
        ledger_hits = []
        for key, obj in objects.items():
            if key == obj_req:
                continue
            fields = obj.get("fields") or []
            order_refs = [f for f in fields
                          if f.get("type") == "relation" and _relation_target(f) == obj_req]
            amounts = [f for f in fields if f.get("type") == "currency"]
            if len(order_refs) == 1 and len(amounts) == 1:
                ledger_hits.append((key, order_refs[0]["key"], amounts[0]["key"]))
        preferred = [x for x in ledger_hits if "ledger" in x[0] or "ledger" in x[2]]
        chosen = preferred if len(preferred) == 1 else ledger_hits
        if len(chosen) != 1:
            raise DeriveError(f"{obj_req} 无 final 字段,且无法唯一推导费用台账"
                              f"(候选 {ledger_hits})")
        params["OBJ_LEDGER"], params["LEDGER_ORDER_FIELD"], params["LEDGER_AMOUNT_FIELD"] = chosen[0]
        notes.append("最终费用由 append-only 台账求和:"
                     f"{chosen[0][0]}.{chosen[0][2]} where {chosen[0][1]}={obj_req}.id")
    aged = [k for k in req_fields if "dispatch" in k and k.endswith("_at")]
    params["AGE_FIELD"] = aged[0] if len(aged) == 1 else "updated_at"
    if len(aged) != 1:
        notes.append(f"{obj_req} 无唯一 dispatch 时间戳字段({aged}),N18 老化回退 updated_at")

    # --- 设备 / 备件 / 耗用对象与字段 ---
    dev_objs = [device_target] if device_target in objects else [k for k in objects if "device" in k]
    if len(dev_objs) != 1:
        raise DeriveError(f"无法由 {params['F_DEVICE']} relation target 唯一确定设备对象:"
                          f"target={device_target!r},fallback={dev_objs}")
    params["OBJ_DEVICE"] = dev_objs[0]
    device_fields = objects[params["OBJ_DEVICE"]].get("fields") or []
    device_owner_fields = [f for f in device_fields
                           if f.get("type") == "relation"
                           and any(k in (f.get("key") or "") for k in ("customer", "owner", "profile"))]
    if len(device_owner_fields) != 1:
        relation_fields = [f for f in device_fields if f.get("type") == "relation"]
        device_owner_fields = relation_fields if len(relation_fields) == 1 else device_owner_fields
    if len(device_owner_fields) != 1:
        raise DeriveError(f"{params['OBJ_DEVICE']} 无法唯一推导客户归属 relation:"
                          f"{[(f.get('key'), _relation_target(f)) for f in device_owner_fields]}")
    device_owner_field = device_owner_fields[0]["key"]
    device_owner_target = _relation_target(device_owner_fields[0])
    stock_objs = [(k, f.get("key")) for k, o in objects.items()
                  for f in o.get("fields") or [] if "stock" in f.get("key", "")]
    if len(stock_objs) != 1:
        raise DeriveError(f"无法唯一确定备件对象(含 stock 字段):{stock_objs}")
    params["OBJ_PART"], params["F_STOCK"] = stock_objs[0]
    # 引用字段可为全名(spare_part_id/repair_ticket_id)或短名(part_id/ticket_id)
    # adapted@m2-fieldservice-e3881bed55da-01
    part_refs = (f"{params['OBJ_PART']}_id", "part_id")
    req_refs = (f"{obj_req}_id", "ticket_id", "order_id")
    usage_hits = []
    for k, o in objects.items():
        if k == params["OBJ_PART"]:
            continue
        fkeys = {f.get("key") for f in o.get("fields") or []}
        pr = [r for r in part_refs if r in fkeys]
        rr = [r for r in req_refs if r in fkeys]
        if pr and rr and any(f.get("key") in ("quantity", "qty") for f in o.get("fields") or []):
            usage_hits.append((k, pr[0]))
    if len(usage_hits) != 1:
        raise DeriveError(f"无法唯一确定备件耗用对象(含 {part_refs}+{req_refs}+quantity):"
                          f"{[k for k, _ in usage_hits]}")
    params["OBJ_USAGE"], params["PART_ID_KEY"] = usage_hits[0]
    params["QTY_KEY"] = next(f.get("key") for f in objects[params["OBJ_USAGE"]].get("fields") or []
                             if f.get("key") in ("quantity", "qty"))

    # --- 报表 ---
    reports = [r.get("key") for r in m.get("reports") or []]
    thru = [k for k in reports if "throughput" in k]
    partsr = [k for k in reports if ("consumption" in k or "part" in k)
              and k != params.get("EXPORT_REPORT_KEY")]
    if len(thru) != 1 or len(partsr) != 1:
        raise DeriveError(f"报表键无法唯一匹配:reports={reports} "
                          f"throughput 候选={thru} parts 候选={partsr},请显式指定")
    params["REPORT_THRU"], params["REPORT_PARTS"] = thru[0], partsr[0]

    # --- 种子 fixtures(记录 id 约定 <object_key>_<seed_key>) ---
    seeds = m.get("seed_records") or []
    seed_key_to_obj = {s.get("data", {}).get("__seed_key"): s.get("object_key")
                       for s in seeds if s.get("data", {}).get("__seed_key")}

    def seed_rows(obj):
        return [s.get("data", {}) for s in seeds if s.get("object_key") == obj]

    identity_bootstrap = m.get("identity_bootstrap") or {}
    workforce_by_user = {p.get("identity_user_id"): p.get("id")
                         for p in identity_bootstrap.get("workforce_profiles") or []
                         if p.get("identity_user_id") and p.get("id")}
    site_by_profile = {a.get("workforce_profile_id"): a.get("organization_unit_id")
                       for a in identity_bootstrap.get("workforce_assignments") or []
                       if a.get("workforce_profile_id") and a.get("organization_unit_id")
                       and a.get("status", "active") == "active"}
    site_by_user = {u: site_by_profile.get(p) for u, p in workforce_by_user.items()
                    if site_by_profile.get(p)}

    # SITE_EAST / TECH_EAST:小额减免 fixture(quote=300.00 完成单)的受派工程师及其站点。
    # 记录侧受派键可能与 dispatch payload 键不同名(adapted@m2-fieldservice-cfc514a2b129-01:
    # payload=technician,记录=assigned_technician_id),按记录字段独立推导。
    rec_assignee_keys = [k for k in req_fields
                         if ("assignee" in k or "technician" in k or k == params["F_ASSIGNEE"])
                         and "name" not in k]  # 排除展示名字段(assigned_technician_name)
    if len(rec_assignee_keys) != 1:
        raise DeriveError(f"{obj_req} 记录侧受派字段无法唯一推导(候选 {rec_assignee_keys})")
    rec_assignee = rec_assignee_keys[0]
    small = [d for d in seed_rows(obj_req)
             if d.get(params["F_STATUS"]) == params["ST_COMPLETED"]
             and d.get(params["F_QUOTE"]) == "300.00"
             and (not params["F_FINAL"]
                  or d.get(params["F_FINAL"]) == d.get(params["F_QUOTE"]))
             and d.get(rec_assignee)]
    if not small:
        # 无 quote=300 种子:该锚点只用于 TECH_EAST/SITE_EAST 推导(探针小额场景已改
        # 全自建订单,SMALL_WAIVER_ORDER 不再被断言使用),放宽为任一已完成带受派种子
        # adapted@m2-fieldservice-e3881bed55da-01
        small = sorted((d for d in seed_rows(obj_req)
                        if d.get(params["F_STATUS"]) == params["ST_COMPLETED"]
                        and d.get(rec_assignee)),
                       key=lambda d: d.get("__seed_key") or "")[:1]
        if small:
            notes.append(f"无 quote=300 种子,东站锚点取已完成种子 {small[0].get('__seed_key')}(行为等价)")
    if len(small) != 1:
        raise DeriveError(
            "无法确定东站锚点种子(需已完成且带受派人的主对象种子):"
            f"候选 {[d.get('__seed_key') for d in seed_rows(obj_req)]}")
    params["SMALL_WAIVER_ORDER"] = _seed_rid(obj_req, small[0]["__seed_key"])
    tech_east = _resolve_ref(small[0][rec_assignee], seed_key_to_obj) or small[0][rec_assignee]
    params["TECH_EAST"] = tech_east
    # 记录侧站点键同样可能与 payload 键不同名(store_id vs site_id);select 型站点取字面值
    site_keys = [k for k in small[0]
                 if k != "__seed_key"
                 and any(x in k for x in ("site", "store", "organization_unit"))]
    site_east_ref = (small[0].get(params["SITE_FIELD"]) if params["SITE_FIELD"] else None) \
        or (small[0].get(site_keys[0]) if len(site_keys) == 1 else None)
    params["SITE_EAST"] = (_resolve_ref(site_east_ref, seed_key_to_obj) or site_east_ref) if site_east_ref else ""
    params["SITE_EAST"] = site_by_user.get(tech_east) or params["SITE_EAST"]
    if params["SITE_FIELD"] and not params["SITE_EAST"]:
        raise DeriveError(f"dispatch 必填 {params['SITE_FIELD']},但小额减免 fixture 种子无站点值,"
                          "无法派生 SITE_EAST")

    # TECH_WEST:站点工程师映射中,属于非 SITE_EAST 站点的工程师
    se_rows = []
    for k, o in objects.items():
        fkeys = {f.get("key") for f in o.get("fields") or []}
        if "engineer_user_id" in fkeys or ({"site_id"} <= fkeys and any("engineer" in f or "user" in f for f in fkeys)):
            se_rows = [(d.get(next(f for f in fkeys if "user" in f)),
                        _resolve_ref(d.get("site_id"), seed_key_to_obj)) for d in seed_rows(k)]
            break
    west_techs = sorted({u for u, s in se_rows if u and u != tech_east and s != params["SITE_EAST"]})
    if not west_techs:
        # 回退:无站点-工程师映射对象时,从主对象种子取"受派人≠tech_east 且站点≠SITE_EAST"
        # adapted@m2-fieldservice-cfc514a2b129-01
        for d in seed_rows(obj_req):
            u = _resolve_ref(d.get(rec_assignee), seed_key_to_obj) or d.get(rec_assignee)
            skeys = [k for k in d if k != "__seed_key"
                     and any(x in k for x in ("site", "store", "organization_unit"))]
            sv = (_resolve_ref(d.get(skeys[0]), seed_key_to_obj) or d.get(skeys[0])) if len(skeys) == 1 else None
            if u and u != tech_east and sv and sv != params["SITE_EAST"]:
                west_techs.append(u)
        west_techs = sorted(set(west_techs))
    if not west_techs:
        west_techs = sorted(u for u, site in site_by_user.items()
                            if u != tech_east and site != params["SITE_EAST"])
    if not west_techs:
        raise DeriveError(f"站点工程师种子中找不到非 {params['SITE_EAST']} 站点的工程师"
                          f"(映射 {se_rows}),无法派生 TECH_WEST")
    params["TECH_WEST"] = west_techs[0]
    params["WORKFORCE_BY_USER"] = json.dumps(workforce_by_user, sort_keys=True)
    params["SITE_BY_USER"] = json.dumps(site_by_user, sort_keys=True)

    # 待拒绝减免 fixture 及其工单
    wrows = seed_rows(obj_waiver)
    w_status_key = next((s.get("field_key") for s in sms if s.get("object_key") == obj_waiver), "status")
    # 待审状态名可为 pending_approval/pending 等,按含 pending 的状态匹配
    # adapted@m2-fieldservice-e3881bed55da-01
    w_sm = next((s for s in sms if s.get("object_key") == obj_waiver), {})
    pend_states = [s for s in (w_sm.get("states") or ["pending_approval"]) if "pending" in s]
    pend = [d for d in wrows if d.get(w_status_key) in pend_states]
    rej = [d for d in pend if "reject" in (d.get("__seed_key") or "")] or (pend if len(pend) == 1 else [])
    if not rej and pend:
        # 多个 pending 且无 reject 命名:拒绝哪个行为等价(断言=拒绝后减免 rejected、
        # 工单 final 不变),取 seed_key 字典序首个并记录 note。
        # adapted@m2-fieldservice-cfc514a2b129-01
        rej = [sorted(pend, key=lambda d: d.get("__seed_key") or "")[0]]
        notes.append(f"待拒绝减免 fixture 多候选 {[d.get('__seed_key') for d in pend]},"
                     f"取字典序首个 {rej[0].get('__seed_key')}(行为等价)")
    if len(rej) != 1:
        raise DeriveError(f"无法唯一确定待拒绝减免 fixture:pending 种子 "
                          f"{[d.get('__seed_key') for d in pend]}(需 seed_key 含 reject 或唯一 pending)")
    params["REJECT_WAIVER_ID"] = _seed_rid(obj_waiver, rej[0]["__seed_key"])
    rej_order_ref = next((rej[0].get(r) for r in req_refs if rej[0].get(r)), None)
    if not rej_order_ref:
        raise DeriveError(f"待拒绝减免种子 {rej[0].get('__seed_key')} 无 {req_refs} 引用")
    params["REJECT_ORDER_ID"] = _resolve_ref(rej_order_ref, seed_key_to_obj)
    rej_order_seed_key = params["REJECT_ORDER_ID"][len(obj_req) + 1:]
    rej_order = [d for d in seed_rows(obj_req) if d.get("__seed_key") == rej_order_seed_key]
    params["REJECT_ORDER_FINAL"] = ((rej_order[0].get(params["F_FINAL"]) or "")
                                    if rej_order and params["F_FINAL"] else "")

    # 探针常量与交付约束核对:主单减免 800 须 >= 审批阈值,小额 100 须 < 阈值
    thresholds = {d.get("threshold") for d in wrows if d.get("threshold")}
    if len(thresholds) == 1:
        t = float(next(iter(thresholds)))
        if not (100.0 < t <= 800.0):
            raise DeriveError(f"审批阈值 {t} 与探针金标准常量不兼容"
                              "(要求 100 < threshold <= 800:小额 100 直接生效、主单 800 走审批)")
        notes.append(f"减免审批阈值={t}(种子),探针常量 800/100 兼容")

    # --- 身份(经理=持 dispatch 权限角色的用户;客户=customer 类角色且名下有设备) ---
    roles = m.get("roles", [])
    disp_perm = dispatch.get("requires_permission") or dispatch["key"]
    mgr_roles = {r.get("key") for r in roles if disp_perm in (r.get("permissions") or [])}
    if not mgr_roles:
        raise DeriveError(f"没有角色持有分派权限 {disp_perm},无法推导 MANAGER")
    users = (m.get("identity_bootstrap") or {}).get("users", [])
    managers = sorted(u["id"] for u in users if set(u.get("role_keys") or []) & mgr_roles)
    if not managers:
        raise DeriveError(f"identity_bootstrap 无持 {sorted(mgr_roles)} 角色的用户,无法推导 MANAGER")
    params["MANAGER"] = managers[0]

    submit_perm = submit.get("requires_permission") or submit["key"]
    cust_roles = {r.get("key") for r in roles
                  if submit_perm in (r.get("permissions") or []) and r.get("key") not in mgr_roles}
    custs = sorted(u["id"] for u in users if set(u.get("role_keys") or []) & cust_roles)
    if len(custs) < 2:
        raise DeriveError(f"持提交权限角色 {sorted(cust_roles)} 的用户不足 2 个({custs}),"
                          "无法派生 CUST_A/CUST_B")
    # Business Profile 交付使用请求级 profile selector;离线派生 binding/surface,
    # profile_id 在 Runtime 启动后由 identity_profile_bindings 实证解析。
    params["PROFILE_BINDING_KEY"] = ""
    params["PROFILE_SURFACE_KEY"] = ""
    profile_exts = m.get("identity_profile_extensions") or []
    matching_exts = [x for x in profile_exts if x.get("object_key") == device_owner_target]
    if not matching_exts and len(profile_exts) == 1:
        matching_exts = profile_exts
    if len(matching_exts) > 1:
        raise DeriveError(f"客户 Business Profile extension 无法唯一确定:{matching_exts}")
    profile_ext = matching_exts[0] if matching_exts else None
    if profile_ext:
        business_identity = profile_ext.get("business_identity") or {}
        surfaces = business_identity.get("surface_keys") or []
        portal_surfaces = [s for s in surfaces if "portal" in s]
        surface = portal_surfaces[0] if len(portal_surfaces) == 1 else (
            surfaces[0] if len(surfaces) == 1 else "")
        binding = business_identity.get("key") or ""
        if not binding or not surface:
            raise DeriveError(f"Business Profile extension 缺唯一 binding/surface:{profile_ext}")
        params["PROFILE_BINDING_KEY"] = binding
        params["PROFILE_SURFACE_KEY"] = surface

    # 校验两名客户名下均有设备。旧形态可由 profile.identity_user_id 离线关联;
    # 新形态绑定后置到 Runtime,离线只验证客户/设备基数,在线由探针查询绑定表。
    profile_by_user = {}
    profile_objects = ([profile_ext.get("object_key")] if profile_ext else []) + list(objects)
    for k in dict.fromkeys(profile_objects):
        o = objects.get(k, {})
        fkeys = {f.get("key") for f in o.get("fields") or []}
        identity_field = ((profile_ext or {}).get("identity_relation_field")
                          if profile_ext and k == profile_ext.get("object_key") else "identity_user_id")
        if identity_field in fkeys:
            profile_by_user = {d.get(identity_field): _seed_rid(k, d.get("__seed_key"))
                               for d in seed_rows(k) if d.get("__seed_key") and d.get(identity_field)}
            break
    dev_owners = {_resolve_ref(d.get(device_owner_field), seed_key_to_obj)
                  for d in seed_rows(params["OBJ_DEVICE"])}
    with_dev = [u for u in custs if profile_by_user.get(u) in dev_owners]
    if len(with_dev) < 2 and profile_ext and len(dev_owners) >= 2:
        with_dev = custs[:2]
        notes.append("客户 profile 绑定为 Runtime 后置数据;离线按客户角色确定两名身份,"
                     "在线将由 identity_profile_bindings 校验并注入请求头")
    if len(with_dev) < 2:
        raise DeriveError(f"名下有设备种子的客户不足 2 个(客户 {custs},有设备 {with_dev}),"
                          "无法派生 CUST_A/CUST_B")
    params["CUST_A"], params["CUST_B"] = with_dev[0], with_dev[1]

    # --- 身份键名与 acceptance-secrets.json 核对(如 ops_mgr vs ops_manager) ---
    sp = _state_root(project_dir) / SECRETS_SUFFIX
    idents = {k: params[k] for k in ("TECH_EAST", "TECH_WEST", "MANAGER", "CUST_A", "CUST_B")}
    if sp.is_file():
        try:
            keys = set(json.loads(sp.read_text()).keys())
        except Exception as e:
            raise DeriveError(f"acceptance-secrets.json 解析失败:{e}")
        missing = {k: v for k, v in idents.items() if v not in keys}
        if missing:
            notes.append(f"派生身份 {missing} 未出现在 acceptance-secrets.json;"
                         "探针将对这些身份按标准初始/已轮换密码登录")
        else:
            notes.append(f"身份已对 acceptance-secrets.json 键名核对通过:{sorted(idents.values())}")
    else:
        notes.append(f"未找到 {sp},跳过身份键名核对")

    notes.append(f"身份映射:manager 角色={sorted(mgr_roles)} -> {managers};"
                 f"customer 角色={sorted(cust_roles)} -> {with_dev[:2]};"
                 f"tech_east 取自小额减免 fixture 受派人,tech_west 取自异站工程师映射")
    return {"params": params, "notes": notes}


DERIVERS = {"s1": derive_s1_params, "m2": derive_m2_params}


def main(argv):
    export = "--export" in argv
    task = "s1"
    argv = list(argv)
    if "--task" in argv:
        i = argv.index("--task")
        try:
            task = argv[i + 1]
        except IndexError:
            sys.exit("usage: probe_derive.py [--export] [--task s1|m2] <project_dir>")
        del argv[i:i + 2]
    args = [a for a in argv if not a.startswith("--")]
    if len(args) != 1 or task not in DERIVERS:
        sys.exit("usage: probe_derive.py [--export] [--task s1|m2] <project_dir>")
    try:
        out = DERIVERS[task](args[0])
    except DeriveError as e:
        sys.exit(f"[probe-derive] 派生失败:{e}")
    if export:
        for k, v in out["params"].items():
            print(f"export {k}={json.dumps(v, ensure_ascii=False)}")
        for n in out["notes"]:
            print(f"# {n}")
    else:
        print(json.dumps(out, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main(sys.argv[1:])
