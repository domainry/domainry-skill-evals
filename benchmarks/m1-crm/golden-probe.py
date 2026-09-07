#!/usr/bin/env python3
"""M1 CRM 金标准验收探针(独立裁判)。

用法: golden-probe.py <base_url> <runtime_db_path> <out.json>
身份与键位经环境变量适配:REP_EAST, REP_EAST2, REP_NORTH, DIRECTOR(user_id),
ACT_REGISTER, ACT_CONTACT, ACT_QUALIFY, ACT_LOSE, ACT_CONVERT, ACT_APPROVE, ACT_REJECT, ACT_EXPORT(action keys),
STATE_FIELD(默认 status)。
"""
import json
import os
import sqlite3
import sys
import time
import urllib.error
import urllib.request

BASE, DB_PATH, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
SURFACE = "business_workspace"
DEV_PW = "Domainry@2026"
NEW_PW = "Golden-Probe-2026!x"
TAG = str(int(time.time()))

REP_EAST = os.environ.get("REP_EAST", "rep_east_demo")
REP_EAST2 = os.environ.get("REP_EAST2", "rep_east2_demo")
REP_NORTH = os.environ.get("REP_NORTH", "rep_north_demo")
DIRECTOR = os.environ.get("DIRECTOR", "director_demo")
ACT_REGISTER = os.environ.get("ACT_REGISTER", "lead.register_lead")
ACT_CONTACT = os.environ.get("ACT_CONTACT", "lead.mark_contacted")
ACT_QUALIFY = os.environ.get("ACT_QUALIFY", "lead.mark_qualified")
ACT_CONVERT = os.environ.get("ACT_CONVERT", "lead.request_conversion")
ACT_APPROVE = os.environ.get("ACT_APPROVE", "conversion_request.approve_conversion")
ACT_REJECT = os.environ.get("ACT_REJECT", "conversion_request.reject_conversion")
ACT_EXPORT = os.environ.get("ACT_EXPORT", "report_export_audit.request_lead_export")
STATE_FIELD = os.environ.get("STATE_FIELD", "status")
DEPT_EAST = os.environ.get("DEPT_EAST", "dept_east")
SOURCE_FIELD = os.environ.get("SOURCE_FIELD", "source")
SOURCE_OK = os.environ.get("SOURCE_OK", "官网")
SOURCE_OK2 = os.environ.get("SOURCE_OK2", "展会")
DEPT_FIELD = os.environ.get("DEPT_FIELD", "department_id")


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


def session(user):
    st, body, _ = http("POST", "/auth/login", body={"workspace_id": "default", "user_id": user, "password": NEW_PW})
    if st == 200:
        return body["access_token"]
    st, body, _ = http("POST", "/auth/login", body={"workspace_id": "default", "user_id": user, "password": DEV_PW})
    assert st == 200, f"login failed {user}: {st} {body}"
    tok = body["access_token"]
    st, body, _ = http("POST", "/auth/change-password", token=tok,
                       body={"current_password": DEV_PW, "new_password": NEW_PW}, idem=f"pw-{user}")
    if st == 200 and body.get("access_token"):
        return body["access_token"]
    st, body, _ = http("POST", "/auth/login", body={"workspace_id": "default", "user_id": user, "password": NEW_PW})
    assert st == 200
    return body["access_token"]


def db(sql, args=(), write=False):
    conn = sqlite3.connect(DB_PATH)
    try:
        cur = conn.execute(sql, args)
        if write:
            conn.commit()
            return cur.rowcount
        return cur.fetchall()
    finally:
        conn.close()


def rows_of(body):
    return body.get("items") or body.get("records") or body.get("data") or []


def rec_data(r):
    return r.get("data", r) if isinstance(r, dict) else {}


def obj_action(token, obj, action, payload, idem, rid=None):
    path = f"/objects/{obj}/records/{rid}/actions/{action}" if rid else f"/objects/{obj}/actions/{action}/run"
    return http("POST", path, token=token, body={"data": payload}, idem=idem)


results = []


def record(fid, prio, ok, evidence, mech="reuse"):
    results.append({"id": fid, "priority": prio, "status": "pass" if ok else "fail", "mechanism": mech, "evidence": evidence})
    print(("PASS " if ok else "FAIL ") + fid + ": " + str(evidence))


east = session(REP_EAST)
east2 = session(REP_EAST2)
north = session(REP_NORTH)
director = session(DIRECTOR)

# M19 身份与种子
st, body, _ = http("GET", "/objects/lead/records?page_size=50", token=director)
leads = rows_of(body)
states = {rec_data(r).get(STATE_FIELD) for r in leads}
owner_ids = tuple({rec_data(r).get("owner_user_id") for r in leads if rec_data(r).get("owner_user_id")})
dept_rows = db(f"""SELECT DISTINCT a.organization_unit_id FROM identity_workforce_assignments a
 JOIN identity_workforce_profiles p ON p.id=a.workforce_profile_id
 WHERE p.identity_user_id IN ({','.join('?'*len(owner_ids))})""", owner_ids) if owner_ids else []
depts = {r[0] for r in dept_rows}
amounts = [float(rec_data(r).get("expected_amount") or 0) for r in leads]
record("M19", "P0", st == 200 and len({s for s in states if s}) >= 5 and len(depts) >= 2
       and any(a >= 100000 for a in amounts) and any(0 < a < 100000 for a in amounts),
       f"seeds={len(leads)} states={sorted(s for s in states if s)} depts={depts}")

# M12 总监全量
record("M12", "P0", st == 200 and len(leads) >= 6, f"director list={len(leads)}")

# M17 分页
st, b2, _ = http("GET", "/objects/lead/records?page_size=2", token=director)
record("M17", "P0", st == 200 and len(rows_of(b2)) <= 2 and "page_size" in b2, f"page_size=2 -> {len(rows_of(b2))} keys={sorted(set(b2.keys()))[:6]}")

# M03 销售注册线索(owner/部门默认)+ M01 非法枚举
st, body, _ = obj_action(east, "lead", ACT_REGISTER,
                         {"company_name": f"探针公司A-{TAG}", "contact_name": "张三", "contact_phone": "13800000001",
                          "expected_amount": "50000.00", SOURCE_FIELD: SOURCE_OK, DEPT_FIELD: DEPT_EAST, "request_id": f"reg-{TAG}-1"},
                         idem=f"reg-{TAG}-1")
def action_record_id(body):
    out = body.get("output") or {}
    for v in out.values():
        if isinstance(v, str) and v.startswith(("lead_", "conversion_request_", "customer_", "report_export_")):
            return v
    created = body.get("created_records") or []
    if created:
        return created[0].get("record_id")
    return (body.get("record") or {}).get("id") or body.get("record_id") or (body.get("data") or {}).get("id")


lead_small = action_record_id(body)
st_get, g, _ = http("GET", f"/objects/lead/records/{lead_small}", token=east) if lead_small else (0, {}, {})
d = rec_data(g.get("record") or g)
record("M03", "P0", st == 200 and lead_small and st_get == 200 and d.get("owner_user_id") and d.get(STATE_FIELD) == "new",
       f"register http={st} id={lead_small} owner={d.get('owner_user_id')} status={d.get(STATE_FIELD)}")

st_bad, bb, _ = obj_action(east, "lead", ACT_REGISTER,
                           {"company_name": "x", "expected_amount": "1.00", SOURCE_FIELD: "not_a_channel", DEPT_FIELD: DEPT_EAST, "request_id": f"reg-{TAG}-bad"},
                           idem=f"reg-{TAG}-bad")
record("M01", "P0", st_bad >= 400, f"非法 source http={st_bad} code={bb.get('code')}")

# M05 注册幂等
st_r, br, _ = obj_action(east, "lead", ACT_REGISTER,
                         {"company_name": f"探针公司A-{TAG}", "contact_name": "张三", "contact_phone": "13800000001",
                          "expected_amount": "50000.00", SOURCE_FIELD: SOURCE_OK, DEPT_FIELD: DEPT_EAST, "request_id": f"reg-{TAG}-1"},
                         idem=f"reg-{TAG}-1")
lead_replay = action_record_id(br)
record("M05", "P0", st_r == 200 and lead_replay == lead_small, f"replay id={lead_replay} orig={lead_small}")

# M02+M04 状态机与负责人
st1, _, _ = obj_action(east, "lead", ACT_CONTACT, {STATE_FIELD: "contacted"}, f"c-{TAG}", rid=lead_small)
st2, _, _ = obj_action(east, "lead", ACT_QUALIFY, {STATE_FIELD: "qualified"}, f"q-{TAG}", rid=lead_small)
record("M04", "P0", st1 == 200 and st2 == 200, f"owner contacted={st1} qualified={st2}")

# 非负责人(同部门)执行转换动作应被拒(owner 守卫)
st_ne, bne, _ = obj_action(east2, "lead", ACT_CONTACT, {STATE_FIELD: "contacted"}, f"ne-{TAG}", rid=lead_small)
record("M11", "P0", st_ne >= 400, f"同部门非 owner 转换 http={st_ne} code={bne.get('code')};跨部门可见性见 M11b")

# 跨部门不可见
st_x, gx, _ = http("GET", f"/objects/lead/records/{lead_small}", token=north)
st_xl, bxl, _ = http("GET", "/objects/lead/records?page_size=50", token=north)
leak = any(((r.get("id") or rec_data(r).get("id")) == lead_small) for r in rows_of(bxl))
results[-1]["evidence"] += f" | 北区直读 http={st_x} 泄漏={leak}"
if st_x not in (403, 404) or leak:
    results[-1]["status"] = "fail"

# M06 小额直转
st_c, bc, _ = obj_action(east, "lead", ACT_CONVERT, {"request_id": f"cv-{TAG}-1"}, f"cv-{TAG}-1", rid=lead_small)
time.sleep(0.3)
st_g, gg, _ = http("GET", f"/objects/lead/records/{lead_small}", token=east)
now_state = rec_data(gg.get("record") or gg).get(STATE_FIELD)
st_cu, cu, _ = http("GET", "/objects/customer/records?page_size=50", token=director)
custs = [r for r in rows_of(cu) if lead_small and lead_small in json.dumps(r)]
record("M06", "P0", st_c == 200 and now_state == "converted" and len(custs) == 1,
       f"小额转化 http={st_c} state={now_state} customer={len(custs)}")

# M08 转化幂等
st_c2, _, _ = obj_action(east, "lead", ACT_CONVERT, {"request_id": f"cv-{TAG}-1"}, f"cv-{TAG}-1", rid=lead_small)
st_cu2, cu2, _ = http("GET", "/objects/customer/records?page_size=50", token=director)
custs2 = [r for r in rows_of(cu2) if lead_small and lead_small in json.dumps(r)]
record("M08", "P0", len(custs2) == 1, f"重放后 customer 数={len(custs2)}")

# 大额线索 → 审批
st, body, _ = obj_action(east, "lead", ACT_REGISTER,
                         {"company_name": f"探针公司B-{TAG}", "contact_name": "李四", "contact_phone": "13800000002",
                          "expected_amount": "250000.00", SOURCE_FIELD: SOURCE_OK2, DEPT_FIELD: DEPT_EAST, "request_id": f"reg-{TAG}-2"},
                         idem=f"reg-{TAG}-2")
lead_big = action_record_id(body)
obj_action(east, "lead", ACT_CONTACT, {STATE_FIELD: "contacted"}, f"c2-{TAG}", rid=lead_big)
obj_action(east, "lead", ACT_QUALIFY, {STATE_FIELD: "qualified"}, f"q2-{TAG}", rid=lead_big)
st_cb, bcb, _ = obj_action(east, "lead", ACT_CONVERT, {"request_id": f"cv-{TAG}-2"}, f"cv-{TAG}-2", rid=lead_big)
time.sleep(0.5)
st_cr, crb, _ = http("GET", "/objects/conversion_request/records?page_size=50", token=director)
pend = [r for r in rows_of(crb) if lead_big and lead_big in json.dumps(r)]
st_gb, gb2, _ = http("GET", f"/objects/lead/records/{lead_big}", token=east)
big_state = rec_data(gb2.get("record") or gb2).get(STATE_FIELD)
crq_id = (pend[0].get("id") or rec_data(pend[0]).get("id")) if pend else None
record("M06b" if False else "M06", "P0", results[-3]["status"] == "pass" and st_cb == 200 and len(pend) == 1 and big_state == "qualified",
       f"[大额分支] http={st_cb} pending={len(pend)} lead_state={big_state}") if False else None
# 合并进 M06 证据
for r in results:
    if r["id"] == "M06":
        ok_big = st_cb == 200 and len(pend) == 1 and big_state == "qualified"
        r["evidence"] += f" | 大额分支 http={st_cb} pending={len(pend)} state={big_state}"
        if not ok_big:
            r["status"] = "fail"

# M07 审批通过(直接 action)
st_ap, bap, _ = obj_action(director, "conversion_request", ACT_APPROVE, {"request_id": f"ap-{TAG}"}, f"ap-{TAG}", rid=crq_id) if crq_id else (0, {}, {})
time.sleep(0.5)
st_gb3, gb3, _ = http("GET", f"/objects/lead/records/{lead_big}", token=director)
big_state2 = rec_data(gb3.get("record") or gb3).get(STATE_FIELD)
st_cu3, cu3, _ = http("GET", "/objects/customer/records?page_size=50", token=director)
custs_big = [r for r in rows_of(cu3) if lead_big and lead_big in json.dumps(r)]
record("M07", "P0", st_ap == 200 and big_state2 == "converted" and len(custs_big) == 1,
       f"approve http={st_ap} lead={big_state2} customer={len(custs_big)}")

# M09 审批通知
st_ib, ib, _ = http("GET", "/business/notifications", token=east)
notif = any("appro" in json.dumps(i) or "审批" in json.dumps(i) or "conversion" in json.dumps(i) for i in rows_of(ib) or ib.get("notifications", []))
record("M09", "P1", st_ib == 200 and notif, f"requester inbox http={st_ib} 含审批通知={notif}")

# M10 客户只读
cust_id = (custs_big[0].get("id") or rec_data(custs_big[0]).get("id")) if custs_big else ((custs2[0].get("id") or rec_data(custs2[0]).get("id")) if custs2 else None)
st_u, _, _ = http("PATCH", f"/objects/customer/records/{cust_id}", token=director, body={"data": {"company_name": "改"}}) if cust_id else (0, {}, {})
st_d, _, _ = http("DELETE", f"/objects/customer/records/{cust_id}", token=director) if cust_id else (0, {}, {})
record("M10", "P0", st_u in (401, 403, 404, 405) and st_d in (401, 403, 404, 405), f"customer update={st_u} delete={st_d}")

# M02 终态拒绝
st_t, bt, _ = obj_action(east, "lead", ACT_CONTACT, {STATE_FIELD: "contacted"}, f"t-{TAG}", rid=lead_small)
record("M02", "P0", st_t >= 400, f"converted 终态再转换 http={st_t} code={bt.get('code')}")

# M14 必须由当前契约驱动 checker 的两阶段 BF06 验证。这个遗留探针没有
# record_timer 生命周期观察面，禁止再通过直写 SQLite/手动 dispatch 伪造时间因果。
record("M14", "P1", False,
       "legacy fixed probe cannot prove event-driven one-shot due continuation; use run_m1_baseline.py BF06")

# M15 漏斗报表
st_rep, rep, _ = http("GET", "/reports/lead_funnel/summary", token=director)
st_rep2, _, _ = http("GET", "/reports/lead_funnel/summary", token=east)
record("M15", "P0", st_rep == 200 and st_rep2 in (401, 403, 404), f"director http={st_rep};rep http={st_rep2}(应拒)")

# M16 受控导出
st_ex, bex, _ = obj_action(director, "report_export_audit", ACT_EXPORT, {"request_id": f"ex-{TAG}"}, f"ex-{TAG}")
st_ex2, _, _ = obj_action(east, "report_export_audit", ACT_EXPORT, {"request_id": f"ex2-{TAG}"}, f"ex2-{TAG}")
record("M16", "P0", st_ex == 200 and st_ex2 in (401, 403), f"director export http={st_ex};rep http={st_ex2}(应拒)")

# M13 审计
audit = db("SELECT COUNT(*) FROM _audit_events")[0][0]
record("M13", "P1", audit > 10, f"_audit_events={audit}")

# M18 菜单
st_m1, _, _ = http("GET", "/identity/effective-menus?surface=business_workspace", token=east)
st_m2, _, _ = http("GET", "/identity/effective-menus?surface=business_workspace", token=director)
record("M18", "P1", st_m1 == 200 and st_m2 == 200, f"menus rep={st_m1} director={st_m2}")

# M11 汇总已在上文(同部门写拒+跨部门隐藏);补同部门可见性
st_v, bv, _ = http("GET", "/objects/lead/records?page_size=50", token=east2)
visible = any((r.get("id") or rec_data(r).get("id")) == lead_big for r in rows_of(bv))
for r in results:
    if r["id"] == "M11":
        r["evidence"] += f" | 同部门同事列表可见={visible}"
        if not visible:
            r["status"] = "fail"

json.dump({"note": f"M1 golden-probe @ {BASE} TAG={TAG}", "results": results}, open(OUT, "w"), ensure_ascii=False, indent=2)
passed = sum(1 for r in results if r["status"] == "pass")
print(f"\n=== {passed}/{len(results)} M1 golden probes passed -> {OUT} ===")
