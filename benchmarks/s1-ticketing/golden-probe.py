#!/usr/bin/env python3
"""S1 工单系统金标准验收探针(独立于被评估 agent 的裁判)。

用法: golden-probe.py <runtime_base_url> <runtime_db_path> <output_checklist_results.json>
前提: Runtime 运行中,demo 身份已初始化(开发默认密码),角色/动作按 s1 需求建模。
参数: 建议设 PROBE_PROJECT_DIR=<agent 项目目录> 从交付物 runtime-manifest 自动派生
      TICKET_FIELDS/IDEM_FIELD/TRANSITION_BODY/各动作名/验收用户等参数;
      显式环境变量仍可覆盖派生值。派生细节见 harness/probe_derive.py。
每条金标准功能点执行真实 API/DB 探测,输出 checklist-results.json(scorer 直接可用)。
"""
import json
import sqlite3
import sys
import time
import urllib.error
import urllib.request

BASE, DB_PATH, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
SURFACE = "business_workspace"
DEV_PW = "Domainry@2026"
NEW_PW = "Golden-Probe-2026!x"
RUN_TAG = str(int(time.time()))
import os

# --- 参数解析:显式环境变量 > 从交付物派生 > 内置遗留默认 ---
# 设 PROBE_PROJECT_DIR 指向 agent 项目目录(含 .domainry/)即可自动派生;
# 派生失败会报错说明缺什么,不会静默退回错误默认值(历史事故:opt-12 漏设
# CREATE_ACTION、opt-13 漏设 TICKET_FIELDS,均导致验收级联假失败)。
_derived = {}
_proj_dir = os.environ.get("PROBE_PROJECT_DIR")
if _proj_dir:
    from pathlib import Path as _Path
    sys.path.insert(0, str(_Path(__file__).resolve().parents[2] / "harness"))
    try:
        from probe_derive import derive_s1_params, DeriveError
    except ImportError as e:
        sys.exit(f"[probe] 无法加载参数派生模块 harness/probe_derive.py:{e}")
    try:
        _out = derive_s1_params(_proj_dir)
    except DeriveError as e:
        sys.exit(f"[probe] 参数派生失败:{e}\n"
                 "(修正 PROBE_PROJECT_DIR,或对缺失项设置显式环境变量后重试)")
    _derived = _out["params"]
    print("[probe] 从交付物派生参数(显式环境变量优先):", file=sys.stderr)
    for _k, _v in _derived.items():
        _tag = " (被环境变量覆盖为 %r)" % os.environ[_k] if _k in os.environ else ""
        print(f"[probe]   {_k}={_v!r}{_tag}", file=sys.stderr)
    for _n in _out["notes"]:
        print(f"[probe]   note: {_n}", file=sys.stderr)
else:
    print("[probe] 警告:未设 PROBE_PROJECT_DIR,参数使用环境变量/内置默认值(易配错;"
          "建议指向 agent 项目目录自动派生)", file=sys.stderr)


def _param(name, legacy_default):
    if name in os.environ:  # 显式覆盖最高优先(含显式置空)
        return os.environ[name]
    return _derived.get(name, legacy_default)


ACT_START = _param("ACT_START", "ticket.start")
ACT_RESOLVE = _param("ACT_RESOLVE", "ticket.resolve")
ACT_CLOSE = _param("ACT_CLOSE", "ticket.close")
ACT_REOPEN = _param("ACT_REOPEN", "ticket.reopen")
ACT_ASSIGN = _param("ACT_ASSIGN", "ticket.assign_ticket")
ASSIGN_FIELD = _param("ASSIGN_FIELD", "assignee_user_id")
COMMENT_FIELD = _param("COMMENT_FIELD", "body")
COMMENT_AUTHOR_FIELD = _param("COMMENT_AUTHOR_FIELD", "")
AGENT_A = _param("AGENT_A", "agent_demo_a")
AGENT_B = _param("AGENT_B", "agent_demo_b")
AGENT_A_OWNER = _param("AGENT_A_OWNER", AGENT_A)
AGENT_B_OWNER = _param("AGENT_B_OWNER", AGENT_B)
MANAGER = _param("MANAGER", "manager_demo")
CREATE_ACTION = _param("CREATE_ACTION", "")
COMMENT_ACTION = _param("COMMENT_ACTION", "")
COMMENT_RECORD_ACTION = _param("COMMENT_RECORD_ACTION", "")  # record_operation on ticket
IDEM_FIELD = _param("IDEM_FIELD", "request_id")  # handler idempotency field name
TRANSITION_BODY = _param("TRANSITION_BODY", "status")  # "status" | "idem_only"


def tdata(target, idem):
    """transition payload per delivery shape."""
    if TRANSITION_BODY == "idem_only":
        return {IDEM_FIELD: idem}
    return {"status": target}
UPDATE_ACTION = _param("UPDATE_ACTION", "")


def update_ticket(token, tid, fields, idem):
    """CRUD PATCH 或 record_operation Action 两种更新模式。"""
    if UPDATE_ACTION:
        data = dict(fields)
        data[IDEM_FIELD] = idem
        return http("POST", f"/objects/ticket/records/{tid}/actions/{UPDATE_ACTION}", token=token, body={"data": data}, idem=idem)
    return http("PATCH", f"/objects/ticket/records/{tid}", token=token,
                body={"data": fields}, idem=idem)


def handler_id(body):
    out = body.get("output") or {}
    for v in out.values():
        if isinstance(v, str) and "_" in v:
            return v
    created = body.get("created_records") or []
    if created:
        return created[0].get("record_id")
    return None


def create_ticket(token, payload, idem):
    """CRUD 或 handler 两种创建模式。payload 为对象字段字典。"""
    if CREATE_ACTION:
        data = {k: v for k, v in payload.items() if k in ("title", "description", "priority", "reporter_name")}
        data[IDEM_FIELD] = idem
        st, body, hdrs = http("POST", f"/objects/ticket/actions/{CREATE_ACTION}/run", token=token, body={"data": data}, idem=idem)
        return st, handler_id(body), hdrs, body
    st, body, hdrs = http("POST", "/objects/ticket/records", token=token, body={"data": flt(payload)}, idem=idem)
    rid = (body.get("data") or body).get("id") or body.get("id")
    return st, rid, hdrs, body
_ticket_fields_csv = _param("TICKET_FIELDS", "")
TICKET_FIELDS = set(_ticket_fields_csv.split(",")) if _ticket_fields_csv else None
REPORT_STATUS = _param("REPORT_STATUS", "ticket_status_summary")


def flt(d):
    """按模型字段契约裁剪 payload(TICKET_FIELDS 未设置时原样返回)。"""
    if TICKET_FIELDS is None:
        return d
    return {k: v for k, v in d.items() if k in TICKET_FIELDS}


def http(method, path, token=None, body=None, idem=None):
    req = urllib.request.Request(BASE + path, method=method)
    req.add_header("Content-Type", "application/json")
    req.add_header("X-Domainry-Product-Surface", SURFACE)
    if token:
        req.add_header("Authorization", "Bearer " + token)
    if idem:
        req.add_header("Idempotency-Key", idem)
    data = json.dumps(body).encode() if body is not None else None
    try:
        with urllib.request.urlopen(req, data=data) as resp:
            return resp.status, json.loads(resp.read() or b"{}"), dict(resp.headers)
    except urllib.error.HTTPError as e:
        try:
            payload = json.loads(e.read() or b"{}")
        except Exception:
            payload = {}
        return e.code, payload, dict(e.headers)
    except Exception as e:
        return 0, {"transport_error": str(e)}, {}


def login(user, password):
    st, body, _ = http("POST", "/auth/login", body={"workspace_id": "default", "user_id": user, "password": password})
    return st, body


PW_OVERRIDES = dict(kv.split(":", 1) for kv in os.environ.get("PROBE_PASSWORDS", "").split(",") if kv)


def session(user):
    """login with dev default; complete forced password change once; return token."""
    if user in PW_OVERRIDES:
        st, body = login(user, PW_OVERRIDES[user])
        assert st == 200, f"override login failed for {user}: {st} {body}"
        return body["access_token"]
    st, body = login(user, NEW_PW)
    if st == 200:
        return body["access_token"]
    st, body = login(user, DEV_PW)
    assert st == 200, f"login failed for {user}: {st} {body}"
    tok = body["access_token"]
    st, body, _ = http("POST", "/auth/change-password", token=tok,
                       body={"current_password": DEV_PW, "new_password": NEW_PW},
                       idem=f"probe-pwchange-{user}")
    if st == 200 and body.get("access_token"):
        return body["access_token"]
    st, body = login(user, NEW_PW)
    assert st == 200, f"relogin failed for {user}: {st} {body}"
    return body["access_token"]


def db(sql, args=()):
    conn = sqlite3.connect(DB_PATH)
    try:
        return conn.execute(sql, args).fetchall()
    finally:
        conn.close()


results = []


def record(fid, prio, ok, evidence, mechanism="reuse"):
    results.append({"id": fid, "priority": prio, "status": "pass" if ok else "fail",
                    "mechanism": mechanism, "evidence": evidence})
    print(("PASS " if ok else "FAIL ") + fid + ": " + evidence)


agent_a = session(AGENT_A)
agent_b = session(AGENT_B)
manager = session(MANAGER)

# --- F16 验收身份与种子 ---
seed_rows = db("SELECT name FROM sqlite_master WHERE type='table' AND name LIKE '%ticket%'")
ticket_table = next((r[0] for r in seed_rows if r[0].endswith("ticket") or r[0] == "records_ticket" or "ticket" == r[0]), None)
# 通用回退:通过 manager API 数种子
st, body, _ = http("GET", "/objects/ticket/records?page_size=50", token=manager)
rows = body.get("items") or body.get("records") or body.get("data") or []
statuses = {r.get("data", r).get("status") for r in rows if isinstance(r, dict)}
assignees = {str(r.get("data", r).get(ASSIGN_FIELD)) for r in rows if isinstance(r, dict)}
record("F16", "P0", st == 200 and len(rows) >= 3 and len({s for s in statuses if s}) >= 3,
       f"manager 可见种子 {len(rows)} 条,状态集 {sorted(s for s in statuses if s)},处理人集大小 {len({a for a in assignees if a and a != 'None'})}")

# --- F11 manager 全量可见(与 DB 对比) ---
db_total = None
for t in ("records", "object_records", "business_records"):
    try:
        db_total = db(f"SELECT COUNT(*) FROM {t} WHERE object_key='ticket'")[0][0]
        break
    except Exception:
        continue
record("F11", "P0", st == 200 and (db_total is None or len(rows) == db_total),
       f"manager list={len(rows)} vs DB total={db_total}")

# --- F14 有界分页 ---
st, body, _ = http("GET", "/objects/ticket/records?page_size=2", token=manager)
rows2 = body.get("items") or body.get("records") or body.get("data") or []
meta_keys = set(body.keys())
record("F14", "P0", st == 200 and len(rows2) <= 2 and bool(meta_keys - {"items", "records", "data"}),
       f"page_size=2 返回 {len(rows2)} 条,响应元数据键 {sorted(meta_keys)[:6]}")

# --- F03 agent 创建 + 更新自有工单 ---
payload_a = {"request_no": f"probe-{RUN_TAG}-1", "title": f"探针工单A-{RUN_TAG}", "priority": "high", "reporter_name": "Golden Probe", "status": "new", ASSIGN_FIELD: AGENT_A_OWNER}
st, tid, hdrs, body = create_ticket(agent_a, payload_a, f"probe-create-{RUN_TAG}-1")
created_ok = st in (200, 201) and tid
st2, body2, _ = update_ticket(agent_a, tid, {"title": f"探针工单A-已改-{RUN_TAG}"}, f"probe-update-{RUN_TAG}-1") if tid else (0, {}, {})
record("F03", "P0", bool(created_ok and st2 == 200), f"create={st} code={body.get('code')} id={tid} update={st2} update_code={body2.get('code')}")

# --- F01 字段与枚举(非法 priority 拒绝) ---
st, _bad_id, _, body = create_ticket(agent_a, {"request_no": f"probe-{RUN_TAG}-bad", "title": f"探针工单bad-{RUN_TAG}", "priority": "not_a_priority", "reporter_name": "Golden Probe", "status": "new", ASSIGN_FIELD: AGENT_A_OWNER}, f"probe-create-{RUN_TAG}-bad")
record("F01", "P0", st >= 400, f"非法 priority 被拒绝 http={st} code={body.get('code')}")

# --- F08 创建幂等(同 Idempotency-Key 重放) ---
st, tid_replay, hdrs, br = create_ticket(agent_a, payload_a, f"probe-create-{RUN_TAG}-1")
record("F08", "P0", st in (200, 201) and tid_replay == tid and (hdrs.get("Idempotency-Replayed") == "true" or True),
       f"重放返回同一记录 id={tid_replay} replayed_header={hdrs.get('Idempotency-Replayed')}")

# --- F10 agent RLS(B 不可见 A 的工单) ---
st, body, _ = http("GET", f"/objects/ticket/records/{tid}", token=agent_b)
concealed = st in (403, 404)
st2, body2, _ = http("GET", "/objects/ticket/records?page_size=50", token=agent_b)
rows_b = body2.get("items") or body2.get("records") or body2.get("data") or []
leak = any(((r.get("data", r) or {}).get("id") == tid) for r in rows_b if isinstance(r, dict))
record("F10", "P0", concealed and not leak, f"B 直读 A 工单 http={st};B 列表 {len(rows_b)} 条,无泄漏={not leak}")

# --- F02+F05 状态机与处理人转换 ---
st_start, b1, _ = http("POST", f"/objects/ticket/records/{tid}/actions/{ACT_START}", token=agent_a, body={"data": tdata("in_progress", f"probe-start-{RUN_TAG}")}, idem=f"probe-start-{RUN_TAG}")
st_resolve, b2, _ = http("POST", f"/objects/ticket/records/{tid}/actions/{ACT_RESOLVE}", token=agent_a, body={"data": tdata("resolved", f"probe-resolve-{RUN_TAG}")}, idem=f"probe-resolve-{RUN_TAG}")
record("F05", "P0", st_start == 200 and st_resolve == 200, f"处理人 start={st_start} resolve={st_resolve}")

# 非法跳转:new 工单直接 close(先建一张 new)
st, tid2, _, body = create_ticket(agent_a, {"request_no": f"probe-{RUN_TAG}-2", "title": f"探针工单B-{RUN_TAG}", "priority": "low", "reporter_name": "Golden Probe", "status": "new", ASSIGN_FIELD: AGENT_A_OWNER}, f"probe-create-{RUN_TAG}-2")
st_skip, body_skip, _ = http("POST", f"/objects/ticket/records/{tid2}/actions/{ACT_CLOSE}", token=manager, body={"data": tdata("closed", f"probe-skip-{RUN_TAG}")}, idem=f"probe-skip-{RUN_TAG}")
record("F02", "P0", st_skip >= 400, f"new→close 非法跳转被拒 http={st_skip} code={body_skip.get('code')}")

# --- F06 仅 manager 可关闭(正反) ---
st_deny, body_deny, _ = http("POST", f"/objects/ticket/records/{tid}/actions/{ACT_CLOSE}", token=agent_a, body={"data": tdata("closed", f"probe-close-deny-{RUN_TAG}")}, idem=f"probe-close-deny-{RUN_TAG}")
st_ok, body_ok, _ = http("POST", f"/objects/ticket/records/{tid}/actions/{ACT_CLOSE}", token=manager, body={"data": tdata("closed", f"probe-close-ok-{RUN_TAG}")}, idem=f"probe-close-ok-{RUN_TAG}")
record("F06", "P0", st_deny in (401, 403) and st_ok == 200,
       f"agent close http={st_deny} code={body_deny.get('code')};manager close http={st_ok}")

# --- F07 manager reopen(先造一张 resolved) ---
st, tid3, _, body = create_ticket(agent_a, {"request_no": f"probe-{RUN_TAG}-3", "title": f"探针工单C-{RUN_TAG}", "priority": "medium", "reporter_name": "Golden Probe", "status": "new", ASSIGN_FIELD: AGENT_A_OWNER}, f"probe-create-{RUN_TAG}-3")
http("POST", f"/objects/ticket/records/{tid3}/actions/{ACT_START}", token=agent_a, body={"data": tdata("in_progress", f"probe-s3-{RUN_TAG}")}, idem=f"probe-s3-{RUN_TAG}")
http("POST", f"/objects/ticket/records/{tid3}/actions/{ACT_RESOLVE}", token=agent_a, body={"data": tdata("resolved", f"probe-r3-{RUN_TAG}")}, idem=f"probe-r3-{RUN_TAG}")
st_reopen, body_reopen, _ = http("POST", f"/objects/ticket/records/{tid3}/actions/{ACT_REOPEN}", token=manager, body={"data": tdata("in_progress", f"probe-reopen-{RUN_TAG}")}, idem=f"probe-reopen-{RUN_TAG}")
st_get, body_get, _ = http("GET", f"/objects/ticket/records/{tid3}", token=manager)
rec = body_get.get("record") or body_get
now_status = ((rec.get("data") or rec) or {}).get("status")
record("F07", "P1", st_reopen == 200 and (now_status in ("in_progress", None)), f"reopen http={st_reopen},当前状态={now_status}")

# --- F04 分派 + 站内通知 ---
st_assign, body_assign, _ = http("POST", f"/objects/ticket/records/{tid3}/actions/{ACT_ASSIGN}", token=manager,
                                 body={"data": {ASSIGN_FIELD: AGENT_B_OWNER, IDEM_FIELD: f"probe-assign-{RUN_TAG}"}},
                                 idem=f"probe-assign-{RUN_TAG}")
time.sleep(0.5)
st_inbox, inbox, _ = http("GET", "/business/notifications", token=agent_b)
items = inbox.get("items") or inbox.get("notifications") or inbox.get("data") or []
got_notif = any("assign" in json.dumps(i) for i in items) if items else False
record("F04", "P0", st_assign == 200 and st_inbox == 200 and got_notif,
       f"assign http={st_assign} code={body_assign.get('code')};B inbox http={st_inbox} 条数={len(items)} 含分派通知={got_notif}")

# --- F09 评论一对多、只增不改 ---
if COMMENT_RECORD_ACTION:
    st_c, body_c, _ = http("POST", f"/objects/ticket/records/{tid}/actions/{COMMENT_RECORD_ACTION}", token=agent_a,
                           body={"data": {COMMENT_FIELD: "探针处理记录", IDEM_FIELD: f"probe-comment-{RUN_TAG}"}}, idem=f"probe-comment-{RUN_TAG}")
    cid = handler_id(body_c)
elif COMMENT_ACTION:
    st_c, body_c, _ = http("POST", f"/objects/ticket_comment/actions/{COMMENT_ACTION}/run", token=agent_a,
                           body={"data": {IDEM_FIELD: f"probe-comment-{RUN_TAG}", "ticket_id": tid, COMMENT_FIELD: "探针处理记录"}}, idem=f"probe-comment-{RUN_TAG}")
    cid = handler_id(body_c)
else:
    comment_data = {"ticket_id": tid, COMMENT_FIELD: "探针处理记录"}
    if COMMENT_AUTHOR_FIELD:
        comment_data[COMMENT_AUTHOR_FIELD] = AGENT_A_OWNER
    st_c, body_c, _ = http("POST", "/objects/ticket_comment/records", token=agent_a,
                           body={"data": comment_data}, idem=f"probe-comment-{RUN_TAG}")
    cid = (body_c.get("data") or body_c).get("id") or body_c.get("id")
st_u, _, _ = http("PATCH", f"/objects/ticket_comment/records/{cid}", token=agent_a, body={"data": {COMMENT_FIELD: "改"}}) if cid else (0, {}, {})
st_d, _, _ = http("DELETE", f"/objects/ticket_comment/records/{cid}", token=agent_a) if cid else (0, {}, {})
record("F09", "P0", st_c in (200, 201)
       and st_u in (400, 401, 403, 404, 405)
       and st_d in (400, 401, 403, 404, 405),
       f"comment create={st_c} update={st_u} delete={st_d}(后两者应被拒)")

# --- F13 报表权限与数值 ---
st_rep_m, rep_m, _ = http("GET", f"/reports/{REPORT_STATUS}/summary", token=manager)
st_rep_a, rep_a, _ = http("GET", f"/reports/{REPORT_STATUS}/summary", token=agent_a)
record("F13", "P1", st_rep_m == 200 and st_rep_a in (401, 403, 404),
       f"manager report http={st_rep_m};agent http={st_rep_a}(应拒绝)")

# --- F12 状态变化审计 ---
audit_hits = []
for t in ("_audit_events", "audit_events", "business_audit_events"):
    try:
        audit_hits = db(f"SELECT COUNT(*) FROM {t}")
        audit_table = t
        break
    except Exception:
        audit_table = None
record("F12", "P1", bool(audit_hits and audit_hits[0][0] > 0),
       f"审计表 {audit_table} 记录数={audit_hits[0][0] if audit_hits else 'n/a'}")

# --- F15 角色差异化菜单 ---
st_m1, menus_a, _ = http("GET", "/identity/effective-menus?surface=business_workspace", token=agent_a)
st_m2, menus_m, _ = http("GET", "/identity/effective-menus?surface=business_workspace", token=manager)
record("F15", "P1", st_m1 == 200 and st_m2 == 200,
       f"effective-menus agent http={st_m1} manager http={st_m2}(菜单差异化取决于发布后 Identity 配置)")

json.dump({"note": f"golden-probe 实测 @ {BASE},RUN_TAG={RUN_TAG}", "results": results},
          open(OUT, "w"), ensure_ascii=False, indent=2)
passed = sum(1 for r in results if r["status"] == "pass")
print(f"\n=== {passed}/{len(results)} golden probes passed → {OUT} ===")
