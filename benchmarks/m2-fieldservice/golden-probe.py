#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""M2 fieldservice 金标准探针。
用法: golden-probe.py <runtime_base_url> <runtime_db_path> <output_checklist_results.json>

参数三级优先:显式环境变量 > PROBE_PROJECT_DIR 派生(harness/probe_derive.derive_m2_params,
从交付物 runtime-manifest.json 离线推导,失败 fail-loud)> 遗留默认。启动时打印各参数取值
与来源(不含密码;凭据仅经 PROBE_PASSWORDS 注入)。

形态兼容层(回灌自 adapted@m2-fieldservice-95bda9c73eaf-01,均为参数化/兼容构造,
金标准断言即 record(...) 判定条件保持不变):
 - rec_data 兼容平台列表/详情响应封套 {"id":..,"data":{..}}(id 在 data 外)
 - dispatch payload 注入交付契约必填的 site_id(SITE_FIELD/SITE_EAST)
 - consumed_parts 为 long_text JSON 字符串时按字符串提交(PARTS_AS_JSON)
 - 主完成单报价 QUOTE_MAIN 默认 1600.00,满足交付"减免≤报价"约束(N15 减免 800)
 - N20 受控导出走交付声明的导出动作(平台无通用 POST /objects/{obj}/records/export 路由)

脏 Runtime 假设(adapted@m2-fieldservice-cfc514a2b129-01):acceptance runner v1 会先于探针
机械执行全部分母用例,把种子 fixtures 审批掉、库刷到千级、占用当日提醒 dedupe 键。因此:
 - N11 record.update 带 Idempotency-Key(平台 key_required 先于不可变判定)
 - N12 小额减免期望值按申请前 final 动态计算;N13 拒绝链路全自建(rid2 完成→申请→拒绝)
 - N16 全量翻页对比;N18 只老化探针自建单并断言同日去重;N20/N13 payload 按契约字段派生填充
"""
import json, os, sys, time, urllib.request, urllib.error, sqlite3
from decimal import Decimal
from pathlib import Path

BASE, DB_PATH, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
TAG = os.environ.get("RUN_TAG", time.strftime("%H%M%S"))
DEV_PW = "Domainry@2026"
NEW_PW = "Golden-Probe-M2-2026!x"


def _derived_params():
    """PROBE_PROJECT_DIR 设定时从交付物派生参数;派生失败 fail-loud 终止。"""
    proj = os.environ.get("PROBE_PROJECT_DIR")
    if not proj:
        return {}
    import importlib.util
    cands = []
    if os.environ.get("PROBE_DERIVE_PATH"):
        cands.append(Path(os.environ["PROBE_DERIVE_PATH"]))
    cands.append(Path(__file__).resolve().parents[2] / "harness" / "probe_derive.py")
    cands.append(Path.cwd() / "harness" / "probe_derive.py")
    src = next((c for c in cands if c.is_file()), None)
    if src is None:
        sys.exit(f"[golden-probe] PROBE_PROJECT_DIR 已设但找不到 probe_derive.py"
                 f"(候选 {[str(c) for c in cands]});可用 PROBE_DERIVE_PATH 显式指定")
    spec = importlib.util.spec_from_file_location("probe_derive", src)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    try:
        out = mod.derive_m2_params(proj)
    except mod.DeriveError as e:
        sys.exit(f"[golden-probe] 参数派生失败(fail-loud):{e}")
    for n in out["notes"]:
        print(f"[derive] {n}")
    return out["params"]


_DERIVED = _derived_params()
_CFG_SRC = {}


def cfg(name, default):
    """三级优先:显式 env > PROBE_PROJECT_DIR 派生 > 遗留默认。"""
    if name in os.environ:
        _CFG_SRC[name] = ("env", os.environ[name])
    elif name in _DERIVED:
        _CFG_SRC[name] = ("derived", _DERIVED[name])
    else:
        _CFG_SRC[name] = ("default", default)
    return _CFG_SRC[name][1]


# 身份
TECH_EAST = cfg("TECH_EAST", "tech_east")
TECH_WEST = cfg("TECH_WEST", "tech_west")
MANAGER = cfg("MANAGER", "ops_manager")
CUST_A = cfg("CUST_A", "cust_a")
CUST_B = cfg("CUST_B", "cust_b")
# 对象
OBJ_REQ = cfg("OBJ_REQ", "repair_request")
OBJ_DEVICE = cfg("OBJ_DEVICE", "device")
OBJ_PART = cfg("OBJ_PART", "part")
OBJ_USAGE = cfg("OBJ_USAGE", "part_usage")
OBJ_WAIVER = cfg("OBJ_WAIVER", "warranty_waiver")  # adapted@m2-fieldservice-95bda9c73eaf-01
OBJ_LEDGER = cfg("OBJ_LEDGER", "")
# 动作(record 级默认;object 级创建以 /run 调用)
ACT_SUBMIT = cfg("ACT_SUBMIT", f"{OBJ_REQ}.submit_request")
ACT_DISPATCH = cfg("ACT_DISPATCH", f"{OBJ_REQ}.dispatch")
ACT_RECALL = cfg("ACT_RECALL", "")
ACT_START = cfg("ACT_START", f"{OBJ_REQ}.start_repair")
ACT_COMPLETE = cfg("ACT_COMPLETE", f"{OBJ_REQ}.complete_repair")
ACT_WAIVER = cfg("ACT_WAIVER", f"{OBJ_REQ}.request_waiver")
ACT_APPROVE = cfg("ACT_APPROVE", "")
ACT_REJECT = cfg("ACT_REJECT", "")
ACT_REMIND = cfg("ACT_REMIND", "")
# 受控导出动作(adapted@m2-fieldservice-95bda9c73eaf-01:平台无通用 /records/export 路由)
ACT_EXPORT = cfg("ACT_EXPORT", "")
OBJ_EXPORT = cfg("OBJ_EXPORT", "")
EXPORT_REPORT_KEY = cfg("EXPORT_REPORT_KEY", "")
# 字段
IDEM_FIELD = cfg("IDEM_FIELD", "request_no")
F_STATUS = cfg("F_STATUS", "status")
F_ASSIGNEE = cfg("F_ASSIGNEE", "assignee_id")
F_DEVICE = cfg("F_DEVICE", "device_id")
F_DESC = cfg("F_DESC", "fault_description")
F_QUOTE = cfg("F_QUOTE", "quote_amount")
F_WAIVER_AMT = cfg("F_WAIVER_AMT", "waiver_amount")
F_FINAL = cfg("F_FINAL", "final_amount")  # adapted@m2-fieldservice-95bda9c73eaf-01
LEDGER_ORDER_FIELD = cfg("LEDGER_ORDER_FIELD", "")
LEDGER_AMOUNT_FIELD = cfg("LEDGER_AMOUNT_FIELD", "")
PARTS_KEY = cfg("PARTS_KEY", "parts")
PART_ID_KEY = cfg("PART_ID_KEY", "part_id")
QTY_KEY = cfg("QTY_KEY", "quantity")
F_STOCK = cfg("F_STOCK", "stock_quantity")
REPORT_THRU = cfg("REPORT_THRU", "request_throughput")
REPORT_PARTS = cfg("REPORT_PARTS", "part_consumption")
ST_SUBMITTED, ST_DISPATCHED, ST_IN_REPAIR, ST_COMPLETED = (
    cfg("ST_SUBMITTED", "submitted"), cfg("ST_DISPATCHED", "dispatched"),
    cfg("ST_IN_REPAIR", "in_repair"), cfg("ST_COMPLETED", "completed"))
# payload 形态兼容(adapted@m2-fieldservice-95bda9c73eaf-01)
SITE_FIELD = cfg("SITE_FIELD", "")        # dispatch 契约必填站点字段
SITE_EAST = cfg("SITE_EAST", "")          # TECH_EAST 所属站点记录 id
PARTS_AS_JSON = cfg("PARTS_AS_JSON", "") == "1"  # consumed_parts 为 long_text JSON 字符串
# 槽位式配件(adapted@m2-fieldservice-cfc514a2b129-01:part_<n>_id/part_<n>_qty 成对字段)
PARTS_STYLE = cfg("PARTS_STYLE", "")
PART_SLOT_ID_TPL = cfg("PART_SLOT_ID_TPL", "part_{n}_id")
PART_SLOT_QTY_TPL = cfg("PART_SLOT_QTY_TPL", "part_{n}_qty")
QUOTE_MAIN = cfg("QUOTE_MAIN", "1600.00")  # 主完成单报价:须 >= N15 减免 800(减免≤报价约束)
LIST_PAGE = int(cfg("LIST_PAGE", "200"))   # 库内历史订单多时 50 截断会造成 N16/N23 假失败
# 减免审批 fixtures(adapted@m2-fieldservice-95bda9c73eaf-01:N12/N13 按交付形态驱动)
SMALL_WAIVER_ORDER = cfg("SMALL_WAIVER_ORDER", "")
REJECT_WAIVER_ID = cfg("REJECT_WAIVER_ID", "")
REJECT_ORDER_ID = cfg("REJECT_ORDER_ID", "")
REJECT_ORDER_FINAL = cfg("REJECT_ORDER_FINAL", "")
# N18 老化 fixture 字段与 remind payload 形态(adapted@m2-fieldservice-95bda9c73eaf-01)
AGE_FIELD = cfg("AGE_FIELD", "updated_at")
REMIND_FIELDS = cfg("REMIND_FIELDS", f"run_date,{IDEM_FIELD}")
# 拒绝/导出 payload 键序列(adapted@m2-fieldservice-cfc514a2b129-01:平台严格解码,键名按交付契约派生)
REJECT_FIELDS = cfg("REJECT_FIELDS", f"reason,{IDEM_FIELD}")
EXPORT_FIELDS = cfg("EXPORT_FIELDS", f"reason,{IDEM_FIELD}")
# 减免发起形态(adapted@m2-fieldservice-e3881bed55da-01):collection=审批对象上的集合级
# 动作(payload 以 F_WAIVER_TICKET 引用工单);默认=工单上的记录级动作
WAIVER_STYLE = cfg("WAIVER_STYLE", "")
F_WAIVER_TICKET = cfg("F_WAIVER_TICKET", f"{OBJ_REQ}_id")
# submit/dispatch/complete 契约字段键序列(额外必填字段按类型/键名通用填充)
SUBMIT_FIELDS = cfg("SUBMIT_FIELDS", "")
DISPATCH_FIELDS = cfg("DISPATCH_FIELDS", "")
COMPLETE_FIELDS = cfg("COMPLETE_FIELDS", "")
# 字段类型表(date/datetime 填充格式随交付契约变化)adapted@m2-fieldservice-e3881bed55da-01
FIELD_TYPES = json.loads(cfg("FIELD_TYPES", "{}") or "{}")
# Workforce/组织单元映射与 Business Profile 请求选择器。
WORKFORCE_BY_USER = json.loads(cfg("WORKFORCE_BY_USER", "{}") or "{}")
SITE_BY_USER = json.loads(cfg("SITE_BY_USER", "{}") or "{}")
PROFILE_BINDING_KEY = cfg("PROFILE_BINDING_KEY", "")
PROFILE_SURFACE_KEY = cfg("PROFILE_SURFACE_KEY", "")
TOKEN_PROFILES = {}


def date_value(key):
    if FIELD_TYPES.get(key) == "datetime":
        return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    return time.strftime("%Y-%m-%d")


def future_date_value(key):
    future = time.time() + 86400
    if FIELD_TYPES.get(key) == "datetime":
        return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime(future))
    return time.strftime("%Y-%m-%d", time.gmtime(future))

for _k in sorted(_CFG_SRC):
    _src, _val = _CFG_SRC[_k]
    print(f"[cfg] {_k}={_val!r} ({_src})")

PW_OVERRIDES = dict(kv.split(":", 1) for kv in os.environ.get("PROBE_PASSWORDS", "").split(",") if kv)


def http(method, path, token=None, body=None, idem=None):
    req = urllib.request.Request(BASE + path, method=method)
    req.add_header("Content-Type", "application/json")
    # adapted@m2-fieldservice-cfc514a2b129-01:交付 Runtime 全路由强制 X-Workspace-ID(F6)
    req.add_header("X-Workspace-ID", WORKSPACE_ID)
    if token:
        req.add_header("Authorization", "Bearer " + token)
        profile_id = TOKEN_PROFILES.get(token)
        if profile_id:
            req.add_header("X-Surface-Key", PROFILE_SURFACE_KEY)
            req.add_header("X-Business-Profile-Key", PROFILE_BINDING_KEY)
            req.add_header("X-Business-Profile-ID", profile_id)
    if idem:
        req.add_header("Idempotency-Key", idem)
    data = json.dumps(body).encode() if body is not None else None
    try:
        r = urllib.request.urlopen(req, data)
        raw = r.read()
        return r.status, (json.loads(raw) if raw else {}), dict(r.headers)
    except urllib.error.HTTPError as e:
        raw = e.read()
        try:
            return e.code, (json.loads(raw) if raw else {}), dict(e.headers)
        except json.JSONDecodeError:
            return e.code, {"raw": raw.decode(errors="replace")[:200]}, dict(e.headers)


WORKSPACE_ID = cfg("WORKSPACE_ID", "default")


def login(user, password):
    # adapted@m2-fieldservice-cfc514a2b129-01:交付 Runtime 强制 X-Workspace-ID 登录头(F6)
    req = urllib.request.Request(BASE + "/auth/login", method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("X-Workspace-ID", WORKSPACE_ID)
    data = json.dumps({"workspace_id": WORKSPACE_ID, "user_id": user, "password": password}).encode()
    try:
        r = urllib.request.urlopen(req, data)
        raw = r.read()
        return r.status, (json.loads(raw) if raw else {})
    except urllib.error.HTTPError as e:
        raw = e.read()
        try:
            return e.code, (json.loads(raw) if raw else {})
        except json.JSONDecodeError:
            return e.code, {"raw": raw.decode(errors="replace")[:200]}


def session(user):
    def register_profile(token):
        if user not in (CUST_A, CUST_B) or not (PROFILE_BINDING_KEY and PROFILE_SURFACE_KEY):
            return token
        rows = db("SELECT profile_id FROM identity_profile_bindings "
                  "WHERE workspace_id=? AND binding_key=? AND identity_user_id=? AND status='active'",
                  (WORKSPACE_ID, PROFILE_BINDING_KEY, user))
        assert len(rows) == 1, (f"active Business Profile binding missing/ambiguous for {user}: "
                                f"binding={PROFILE_BINDING_KEY} rows={rows}")
        TOKEN_PROFILES[token] = rows[0][0]
        return token

    if user in PW_OVERRIDES:
        st, body = login(user, PW_OVERRIDES[user])
        assert st == 200, f"override login failed for {user}: {st} {body}"
        return register_profile(body["access_token"])
    st, body = login(user, NEW_PW)
    if st == 200:
        return register_profile(body["access_token"])
    st, body = login(user, DEV_PW)
    assert st == 200, f"login failed for {user}: {st} {body}"
    tok = body["access_token"]
    st, body, _ = http("POST", "/auth/change-password", token=tok,
                       body={"current_password": DEV_PW, "new_password": NEW_PW}, idem=f"pw-{user}-{TAG}")
    if st == 200 and body.get("access_token"):
        return register_profile(body["access_token"])
    st, body = login(user, NEW_PW)
    assert st == 200, f"relogin failed for {user}: {st} {body}"
    return register_profile(body["access_token"])


def db(sql, args=(), write=False):
    conn = sqlite3.connect(DB_PATH, timeout=10)
    try:
        cur = conn.execute(sql, args)
        if write:
            conn.commit()
            return cur.rowcount
        return cur.fetchall()
    finally:
        conn.close()


def rows_of(body):
    v = body.get("items") or body.get("records") or body.get("data") or []
    return v if isinstance(v, list) else []


def rec_data(r):
    # adapted@m2-fieldservice-95bda9c73eaf-01:平台响应封套 {"id":..,"data":{..}},id 在 data 之外
    if not isinstance(r, dict):
        return {}
    d = dict(r["data"]) if isinstance(r.get("data"), dict) else dict(r)
    if d.get("id") is None and r.get("id") is not None:
        d["id"] = r["id"]
    return d


def act(token, action, payload, idem, rid=None, obj=OBJ_REQ):
    if action == ACT_SUBMIT:
        payload = submit_payload(payload, idem)
    path = f"/objects/{obj}/records/{rid}/actions/{action}" if rid else f"/objects/{obj}/actions/{action}/run"
    return http("POST", path, token=token, body={"data": payload}, idem=idem)


def action_rid(body):
    for ref in body.get("created_records") or []:
        if ref.get("record_id"):
            return ref["record_id"]
    out = body.get("output") or {}
    for v in out.values():
        if isinstance(v, str) and "_" in v:
            return v
    rec = body.get("record") or {}
    return (rec.get("data") or rec).get("id") if isinstance(rec, dict) else None


def submit_payload(payload, idem):
    """补齐 submit 契约的非场景字段;显式缺失 F_DEVICE 仍保持缺失以供 N05 断言。"""
    out = dict(payload)
    for k in [k for k in SUBMIT_FIELDS.split(",") if k]:
        if k in out or k == F_DEVICE:
            continue
        typ = FIELD_TYPES.get(k)
        if k == IDEM_FIELD or "request" in k:
            out[k] = idem
        elif typ in ("date", "datetime") or "date" in k or k.endswith("_at"):
            out[k] = future_date_value(k)
        elif typ == "currency":
            out[k] = "1.00"
        elif typ == "integer":
            out[k] = 1
        elif typ == "boolean":
            out[k] = True
        else:
            out[k] = f"probe-{idem}"
    return out


def disp_payload(assignee, idem, quote=QUOTE_MAIN):
    # adapted@m2-fieldservice-e3881bed55da-01:契约键序列已知时按键名通用填充
    # (technician_name 类展示名字段以受派人用户名填充)
    if DISPATCH_FIELDS:
        p = {}
        for k in [k for k in DISPATCH_FIELDS.split(",") if k]:
            if k == IDEM_FIELD or "request" in k:
                p[k] = idem
            elif k == F_ASSIGNEE:
                p[k] = assignee
            elif k == SITE_FIELD:
                p[k] = SITE_BY_USER.get(assignee) or SITE_EAST
            elif k == F_QUOTE or FIELD_TYPES.get(k) == "currency":
                p[k] = quote
            elif "workforce" in k:
                p[k] = WORKFORCE_BY_USER.get(assignee) or f"probe-{assignee}"
            elif "name" in k:
                p[k] = str(assignee)
            elif "date" in k or k.endswith("_at"):
                p[k] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
            else:
                p[k] = f"probe-{idem}"
        return p
    # adapted@m2-fieldservice-95bda9c73eaf-01:dispatch 契约必填 site_id
    p = {F_ASSIGNEE: assignee, IDEM_FIELD: idem}
    if SITE_FIELD and SITE_EAST:
        p[SITE_FIELD] = SITE_BY_USER.get(assignee) or SITE_EAST
    return p


def waiver_call(token, rid, amount, idem):
    """减免发起:collection 形态走审批对象集合级动作,payload 引用工单;
    默认走工单记录级动作。adapted@m2-fieldservice-e3881bed55da-01"""
    if WAIVER_STYLE == "collection":
        return act(token, ACT_WAIVER,
                   {F_WAIVER_TICKET: rid, F_WAIVER_AMT: amount, IDEM_FIELD: idem},
                   idem, obj=OBJ_WAIVER)
    return act(token, ACT_WAIVER, {F_WAIVER_AMT: amount, IDEM_FIELD: idem}, idem, rid=rid)


def parts_payload(lines):
    # adapted@m2-fieldservice-95bda9c73eaf-01:consumed_parts 为 long_text JSON 字符串(非数组)
    return json.dumps(lines) if PARTS_AS_JSON else lines


def parts_fields(lines):
    """配件明细 → payload 片段。slots 模式展开为 part_<n>_id/qty 字段,否则单键。
    adapted@m2-fieldservice-cfc514a2b129-01"""
    if PARTS_STYLE == "slots":
        out = {}
        for i, line in enumerate(lines, 1):
            out[PART_SLOT_ID_TPL.format(n=i)] = line[PART_ID_KEY]
            out[PART_SLOT_QTY_TPL.format(n=i)] = line[QTY_KEY]
        return out
    return {PARTS_KEY: parts_payload(lines)}


def complete_payload(lines, quote, idem):
    """按 complete 契约构造合法 payload;报价仅在该动作声明接收时提交。"""
    out = parts_fields(lines)
    for k in [k for k in COMPLETE_FIELDS.split(",") if k]:
        if k in out:
            continue
        typ = FIELD_TYPES.get(k)
        if k == IDEM_FIELD or "request" in k:
            out[k] = idem
        elif k == F_QUOTE or typ == "currency":
            out[k] = quote
        elif typ in ("date", "datetime") or "date" in k or k.endswith("_at"):
            out[k] = date_value(k)
        elif typ == "integer":
            out[k] = 1
        elif typ == "boolean":
            out[k] = True
        else:
            out[k] = f"probe-{idem}"
    # 未派生契约时保持遗留默认形态。
    if not COMPLETE_FIELDS:
        out[F_QUOTE] = quote
        out[IDEM_FIELD] = idem
    return out


def fill_fields(keys_csv, idem, text):
    """按键名通用填充动作 payload:request/幂等键→idem,report→EXPORT_REPORT_KEY,
    date→当日,reason/其余文本→text。adapted@m2-fieldservice-cfc514a2b129-01"""
    out = {}
    for k in [k for k in keys_csv.split(",") if k]:
        if k == IDEM_FIELD or "request" in k:
            out[k] = idem
        elif "report" in k:
            out[k] = EXPORT_REPORT_KEY
        elif "query" in k and FIELD_TYPES.get(k) in ("text", "long_text", "json"):
            out[k] = "{}"
        elif "date" in k or k.endswith("_at"):
            out[k] = date_value(k)
        else:
            out[k] = text
    return out


def list_all_ids(token):
    """全量翻页取 id 集(验收 runner 会把库刷到千级,单页截断会造成 N16 假失败)。
    adapted@m2-fieldservice-cfc514a2b129-01"""
    ids, page, total = set(), 1, None
    while page <= 50:
        st, b, _ = http("GET", f"/objects/{OBJ_REQ}/records?page={page}&page_size={LIST_PAGE}", token=token)
        if st != 200:
            return st, ids, total
        rows = rows_of(b)
        ids |= {rec_data(r).get("id") for r in rows}
        total = b.get("total", total)
        more = b["has_next"] if "has_next" in b else (len(rows) == LIST_PAGE and rows)
        if not more:
            break
        page += 1
    return 200, ids, total


def get_rec(token, rid, obj=OBJ_REQ):
    st, b, _ = http("GET", f"/objects/{obj}/records/{rid}", token=token)
    return st, rec_data(b.get("record") or b)


def money_sub(a, b):
    return f"{Decimal(a) - Decimal(b):.2f}"


def final_for_order(rid, record=None):
    """兼容工单反范式 final 字段与 append-only 费用台账两种合法形态。"""
    record = record or {}
    if F_FINAL and record.get(F_FINAL) is not None:
        return f"{Decimal(str(record[F_FINAL])):.2f}"
    if OBJ_LEDGER and LEDGER_ORDER_FIELD and LEDGER_AMOUNT_FIELD:
        rows = db(f'SELECT "{LEDGER_AMOUNT_FIELD}" FROM "{OBJ_LEDGER}" '
                  f'WHERE "{LEDGER_ORDER_FIELD}"=?', (rid,))
        if rows:
            return f"{sum((Decimal(str(row[0])) for row in rows), Decimal('0')):.2f}"
    return None


results = []


def record(fid, prio, ok, evidence, mech="probe"):
    results.append({"id": fid, "priority": prio, "status": "pass" if ok else "fail", "mechanism": mech, "evidence": str(evidence)[:400]})
    print(("PASS " if ok else "FAIL ") + fid + ": " + str(evidence)[:300])


tech_e = session(TECH_EAST)
tech_w = session(TECH_WEST)
manager = session(MANAGER)
cust_a = session(CUST_A)
cust_b = session(CUST_B)

# ---------- N23 身份/种子 ----------
st, body, _ = http("GET", f"/objects/{OBJ_REQ}/records?page_size={LIST_PAGE}", token=manager)
reqs = rows_of(body)
states = {rec_data(r).get(F_STATUS) for r in reqs}
st_p, bp, _ = http("GET", f"/objects/{OBJ_PART}/records?page_size=50", token=manager)
parts = rows_of(bp)
stocks = [(rec_data(p).get("id"), float(rec_data(p).get(F_STOCK) or 0)) for p in parts]
record("N23", "P0", st == 200 and len({s for s in states if s}) >= 3 and len(parts) >= 3,
       f"seeds reqs={len(reqs)} states={sorted(s for s in states if s)} parts={len(parts)} stocks={stocks[:4]}")

# ---------- N05 schema(金额 exact / 设备必填) ----------
cols = {r[1]: r[2] for r in db(f'PRAGMA table_info("{OBJ_REQ}")')}
amt_type = (cols.get(F_QUOTE) or "").upper()
st_bad, bb, _ = act(cust_a, ACT_SUBMIT, {F_DESC: f"缺设备-{TAG}", IDEM_FIELD: f"nodev-{TAG}"}, f"nodev-{TAG}")
record("N05", "P0", ("REAL" not in amt_type and "FLOAT" not in amt_type and F_QUOTE in cols) and st_bad >= 400,
       f"quote_type={amt_type or cols} missing-device http={st_bad} code={bb.get('code')}")

# ---------- N02+N03 客户身份绑定 + 门户幂等 ----------
st, bd, _ = http("GET", f"/objects/{OBJ_DEVICE}/records?page_size=20", token=cust_a)
devs_a = rows_of(bd)
dev_a = (rec_data(devs_a[0]).get("id") if devs_a else None)
st, bdb, _ = http("GET", f"/objects/{OBJ_DEVICE}/records?page_size=20", token=cust_b)
devs_b = rows_of(bdb)
dev_b = (rec_data(devs_b[0]).get("id") if devs_b else None)
idem1 = f"probe-sub-{TAG}-1"
st1, b1, _ = act(cust_a, ACT_SUBMIT, {F_DEVICE: dev_a, F_DESC: f"探针报修A-{TAG}", IDEM_FIELD: idem1}, idem1)
rid = action_rid(b1)
st_other, bo, _ = act(cust_a, ACT_SUBMIT, {F_DEVICE: dev_b, F_DESC: f"越权报修-{TAG}", IDEM_FIELD: f"x-{TAG}"}, f"x-{TAG}")
record("N02", "P0", st1 in (200, 201) and rid and st_other >= 400,
       f"own-device http={st1} rid={rid}; other-device http={st_other} code={bo.get('code')}")
st1r, b1r, hdr = act(cust_a, ACT_SUBMIT, {F_DEVICE: dev_a, F_DESC: f"探针报修A-{TAG}", IDEM_FIELD: idem1}, idem1)
rid_r = action_rid(b1r)
record("N03", "P0", st1r in (200, 201) and rid_r == rid, f"replay http={st1r} same_id={rid_r == rid} ({rid})")

# ---------- N04 客户行级隔离 ----------
st_bl, bbl, _ = http("GET", f"/objects/{OBJ_REQ}/records?page_size=50", token=cust_b)
rows_b = rows_of(bbl)
leak = any(rec_data(r).get("id") == rid for r in rows_b)
st_dir, _, _ = http("GET", f"/objects/{OBJ_REQ}/records/{rid}", token=cust_b)
record("N04", "P0", st_bl == 200 and not leak and st_dir in (403, 404),
       f"B list={len(rows_b)} leak={leak}; B direct http={st_dir}")

# ---------- N01 跨 Surface 凭据隔离 ----------
d1, bd1, _ = act(cust_a, ACT_DISPATCH, disp_payload(TECH_EAST, f"cd-{TAG}"), f"cd-{TAG}", rid=rid)
d2, _, _ = http("GET", f"/reports/{REPORT_THRU}/summary", token=cust_a)
# adapted@m2-fieldservice-95bda9c73eaf-01:complete 带合法形态 payload,确保命中权限拒绝而非入参校验
d3, bd3, _ = act(cust_a, ACT_COMPLETE,
                  complete_payload([], "1.00", f"cc-{TAG}"), f"cc-{TAG}", rid=rid)
record("N01", "P0", d1 in (401, 403) and d2 in (401, 403, 404) and d3 in (401, 403),
       f"customer dispatch={d1}({bd1.get('code')}) report={d2} complete={d3}")

# ---------- N07 经理分派 + 通知 ----------
st_disp, bdp, _ = act(manager, ACT_DISPATCH, disp_payload(TECH_EAST, f"disp-{TAG}"), f"disp-{TAG}", rid=rid)
time.sleep(0.5)
st_ib, ib, _ = http("GET", "/business/notifications", token=tech_e)
notif = any(("dispatch" in json.dumps(i)) or ("分派" in json.dumps(i, ensure_ascii=False)) or (str(rid) in json.dumps(i)) for i in rows_of(ib))
record("N07", "P0", st_disp == 200 and st_ib == 200 and notif, f"dispatch http={st_disp}; tech inbox notif={notif}")

# ---------- N08 仅被分派工程师可开始/完成 ----------
sw, bw, _ = act(tech_w, ACT_START, {IDEM_FIELD: f"sw-{TAG}"}, f"sw-{TAG}", rid=rid)
sm, bm, _ = act(manager, ACT_START, {IDEM_FIELD: f"sm-{TAG}"}, f"sm-{TAG}", rid=rid)
se, be, _ = act(tech_e, ACT_START, {IDEM_FIELD: f"se-{TAG}"}, f"se-{TAG}", rid=rid)
record("N08", "P0", sw in (401, 403, 404) and sm in (401, 403, 404) and se == 200,
       f"cross-site start={sw}({bw.get('code')}) manager start={sm} assignee start={se}")

# ---------- N06 状态机(completed 终态在 N11 后验证;此处验证非法跳转) ----------
idem2 = f"probe-sub-{TAG}-2"
st2, b2, _ = act(cust_a, ACT_SUBMIT, {F_DEVICE: dev_a, F_DESC: f"探针报修B-{TAG}", IDEM_FIELD: idem2}, idem2)
rid2 = action_rid(b2)
sk, bk, _ = act(tech_e, ACT_START, {IDEM_FIELD: f"skip-{TAG}"}, f"skip-{TAG}", rid=rid2)  # submitted 直接 start(未分派)
record("N06", "P0", sk >= 400, f"submitted->in_repair 未经分派被拒 http={sk} code={bk.get('code')}")

# ---------- N09+N10 事务性完成 + 库存 CAS ----------
part_rich = next(((pid, s) for pid, s in stocks if s >= 2), None)
part_poor = next(((pid, s) for pid, s in stocks if 0 <= s < 2), None)
ok9 = ok10 = False
ev9 = ev10 = "no suitable part in seeds"
if part_rich:
    pid, before = part_rich
    idc = f"comp-{TAG}"
    stc, bc, _ = act(tech_e, ACT_COMPLETE,
                     complete_payload([{PART_ID_KEY: pid, QTY_KEY: 1}], QUOTE_MAIN, idc),
                     idc, rid=rid)
    after = float(db(f'SELECT "{F_STOCK}" FROM "{OBJ_PART}" WHERE id=?', (pid,))[0][0])
    usage = db(f'SELECT COUNT(*) FROM "{OBJ_USAGE}"')[0][0] if db(f"SELECT name FROM sqlite_master WHERE name='{OBJ_USAGE}'") else -1
    stat = db(f'SELECT "{F_STATUS}" FROM "{OBJ_REQ}" WHERE id=?', (rid,))
    stat = stat[0][0] if stat else None
    ok9 = stc == 200 and after == before - 1 and usage >= 1 and stat == ST_COMPLETED
    ev9 = f"complete http={stc} stock {before}->{after} usage_rows={usage} status={stat}"
    # 幂等重放:同 idem 不再扣
    stc2, _, _ = act(tech_e, ACT_COMPLETE,
                     complete_payload([{PART_ID_KEY: pid, QTY_KEY: 1}], QUOTE_MAIN, idc),
                     idc, rid=rid)
    after2 = float(db(f'SELECT "{F_STOCK}" FROM "{OBJ_PART}" WHERE id=?', (pid,))[0][0])
    # 库存不足:rid2 分派->开始->超量完成
    act(manager, ACT_DISPATCH, disp_payload(TECH_EAST, f"d2-{TAG}", "1000.00"), f"d2-{TAG}", rid=rid2)
    act(tech_e, ACT_START, {IDEM_FIELD: f"s2-{TAG}"}, f"s2-{TAG}", rid=rid2)
    poor_id, poor_stock = part_poor if part_poor else (pid, after2)
    over = int(poor_stock) + 5
    sto, bo2, _ = act(tech_e, ACT_COMPLETE,
                      complete_payload([{PART_ID_KEY: poor_id, QTY_KEY: over}],
                                       "1000.00", f"over-{TAG}"),
                      f"over-{TAG}", rid=rid2)
    poor_after = float(db(f'SELECT "{F_STOCK}" FROM "{OBJ_PART}" WHERE id=?', (poor_id,))[0][0])
    stat2 = db(f'SELECT "{F_STATUS}" FROM "{OBJ_REQ}" WHERE id=?', (rid2,))
    stat2 = stat2[0][0] if stat2 else None
    ok10 = (after2 == after) and sto >= 400 and poor_after == poor_stock and stat2 != ST_COMPLETED
    ev10 = f"replay stock {after}->{after2}; over-consume http={sto} code={bo2.get('code')} stock {poor_stock}->{poor_after} status={stat2}"
record("N09", "P0", ok9, ev9)
record("N10", "P0", ok10, ev10)

# ---------- N11 完成后只读 + N06 终态补证 ----------
# adapted@m2-fieldservice-cfc514a2b129-01:record.update 平台要求 Idempotency-Key,
# 不带则 400 key_required 先于不可变判定命中,造成假失败
su, _, _ = http("PATCH", f"/objects/{OBJ_REQ}/records/{rid}", token=manager, body={"data": {F_DESC: "改"}}, idem=f"upd-{TAG}")
sd, _, _ = http("DELETE", f"/objects/{OBJ_REQ}/records/{rid}", token=manager)
sterm, bterm, _ = act(tech_e, ACT_START, {IDEM_FIELD: f"term-{TAG}"}, f"term-{TAG}", rid=rid)
record("N11", "P0", su in (401, 403, 404, 405) and sd in (401, 403, 404, 405) and sterm >= 400,
       f"completed update={su} delete={sd} restart={sterm}({bterm.get('code')})")

# ---------- N12/N13/N15 保修减免审批 ----------
okA = okR = okI = False
evA = evR = evI = "not executed"
if ACT_WAIVER:
    idw = f"waiv-{TAG}"
    stw, bw2, _ = waiver_call(tech_e, rid, "800.00", idw)
    stw_r, _, _ = waiver_call(tech_e, rid, "800.00", idw)
    okI = stw in (200, 201) and stw_r in (200, 201, 409)
    evI = f"waiver http={stw} replay={stw_r}"
    evA = evR = f"waiver submitted http={stw}; approve/reject driven separately (env ACT_APPROVE={ACT_APPROVE!r})"
    # adapted@m2-fieldservice-95bda9c73eaf-01:审批通过/拒绝按交付形态经环境参数驱动
    if ACT_APPROVE:
        wrow = db(f'SELECT id FROM "{OBJ_WAIVER}" WHERE "{F_WAIVER_TICKET}"=?', (rid,))
        wid = wrow[0][0] if wrow else None
        st_ap, bap, _ = act(manager, ACT_APPROVE, {IDEM_FIELD: f"appr-{TAG}"}, f"appr-{TAG}", rid=wid, obj=OBJ_WAIVER) if wid else (0, {}, {})
        st_g, g = get_rec(manager, rid)
        order_quote = g.get(F_QUOTE) or QUOTE_MAIN
        expect_final = money_sub(order_quote, "800.00")
        final_after = final_for_order(rid, g)
        # 小额(<阈值)直接生效:全自建订单(submit→dispatch→start→complete 300)后申请 100 减免。
        # adapted@m2-fieldservice-cfc514a2b129-01:种子单不可复用——需求 §15 同单重复减免
        # 被 waiver_exists 正确拒绝,首轮探针/验收 runner 已在种子单上用过减免
        ids4 = f"small-{TAG}"
        st_s1, bs1, _ = act(cust_a, ACT_SUBMIT, {F_DEVICE: dev_a, F_DESC: f"小额减免单-{TAG}", IDEM_FIELD: ids4}, ids4)
        rid4 = action_rid(bs1)
        act(manager, ACT_DISPATCH, disp_payload(TECH_EAST, f"d4-{TAG}", "300.00"), f"d4-{TAG}", rid=rid4)
        act(tech_e, ACT_START, {IDEM_FIELD: f"s4-{TAG}"}, f"s4-{TAG}", rid=rid4)
        st_c4, bc4, _ = act(tech_e, ACT_COMPLETE,
                            complete_payload([], "300.00", f"c4-{TAG}"),
                            f"c4-{TAG}", rid=rid4)
        st_sm, bsm, _ = waiver_call(tech_e, rid4, "100.00", f"smallw-{TAG}")
        st_gs, gs = get_rec(manager, rid4)
        small_final = final_for_order(rid4, gs)
        time.sleep(0.5)
        st_ib3, ib3, _ = http("GET", "/business/notifications", token=tech_e)
        notifA = any(("减免" in json.dumps(i, ensure_ascii=False)) or ("approved" in json.dumps(i)) for i in rows_of(ib3))
        okA = (st_ap == 200 and final_after == expect_final
               and st_c4 == 200 and st_sm in (200, 201) and small_final == "200.00" and notifA)
        evA = (f"approve http={st_ap} waiver_id={wid} final={final_after}(expect {expect_final}); "
               f"small-order complete={st_c4} waiver http={st_sm} final={small_final}(expect 200.00); "
               f"tech inbox approved-notif={notifA}")
    if ACT_REJECT:
        # adapted@m2-fieldservice-cfc514a2b129-01:拒绝链路全自建,不再依赖种子 fixture
        # (验收 runner 会把 pending fixture 审批掉)。rid2(N10 后仍 in_repair)正常完成
        # → 申请 800 减免(超阈值 pending)→ 经理按契约字段拒绝。
        n13_parts = [{PART_ID_KEY: part_rich[0], QTY_KEY: 1}] if part_rich else []
        stc3, bc3, _ = act(tech_e, ACT_COMPLETE,
                           complete_payload(n13_parts, "1000.00", f"comp2-{TAG}"),
                           f"comp2-{TAG}", rid=rid2)
        stw3, bw6, _ = waiver_call(tech_e, rid2, "800.00", f"waiv2-{TAG}")
        wrow2 = db(f'SELECT id FROM "{OBJ_WAIVER}" WHERE "{F_WAIVER_TICKET}"=? ORDER BY created_at DESC LIMIT 1', (rid2,))
        wid2 = wrow2[0][0] if wrow2 else None
        st_rj, brj, _ = (act(manager, ACT_REJECT, fill_fields(REJECT_FIELDS, f"rej-{TAG}", f"探针拒绝-{TAG}"), f"rej-{TAG}", rid=wid2, obj=OBJ_WAIVER)
                         if wid2 else (0, {}, {}))
        # 拒绝原因列名按 REJECT_FIELDS 派生(decision_reason/reject_reason 等交付各异)
        # adapted@m2-fieldservice-e3881bed55da-01
        reason_col = next((k for k in REJECT_FIELDS.split(",")
                           if k and k != IDEM_FIELD and "reason" in k), "decision_reason")
        wst = db(f'SELECT status, "{reason_col}" FROM "{OBJ_WAIVER}" WHERE id=?', (wid2,)) if wid2 else []
        w_status, w_reason = (wst[0] if wst else (None, None))
        st_gr, gr = get_rec(manager, rid2)
        reject_quote = f"{Decimal(str(gr.get(F_QUOTE) or '1000.00')):.2f}"
        final_keep = final_for_order(rid2, gr)
        time.sleep(0.5)
        st_ib4, ib4, _ = http("GET", "/business/notifications", token=tech_e)
        # 通知断言按本链路记录 id 定位,避免库存量拒绝通知造成假通过
        notifR = any((str(rid2) in json.dumps(i) or str(wid2) in json.dumps(i))
                     and (("拒绝" in json.dumps(i, ensure_ascii=False)) or ("rejected" in json.dumps(i)))
                     for i in rows_of(ib4))
        okR = (stc3 == 200 and stw3 in (200, 201) and st_rj == 200
               and w_status == "rejected" and bool(w_reason)
               and final_keep == reject_quote and notifR)
        evR = (f"complete2 http={stc3} waiver http={stw3} reject http={st_rj} waiver_status={w_status} "
               f"reason={str(w_reason)[:30]!r} order_final={final_keep}(expect {reject_quote} unchanged); "
               f"assignee inbox rejected-notif={notifR}")
record("N15", "P1", okI, evI)
record("N12", "P0", okA, evA)
record("N13", "P0", okR, evR)

# ---------- N16 站点级数据域 ----------
# adapted@m2-fieldservice-cfc514a2b129-01:全量翻页对比(验收 runner 把库刷到千级,
# 单页 200 截断导致 manager < east∪west 的假失败)
st_e, ids_e, _ = list_all_ids(tech_e)
st_w, ids_w, _ = list_all_ids(tech_w)
st_mr, ids_m, total_m = list_all_ids(manager)
record("N16", "P0", st_e == 200 and st_w == 200 and st_mr == 200
       and not (ids_e & ids_w) and (ids_e | ids_w) <= ids_m,
       f"east={len(ids_e)} west={len(ids_w)} overlap={len(ids_e & ids_w)} manager={len(ids_m)}(total={total_m})")

# ---------- N17 审计 ----------
audit = db("SELECT COUNT(*) FROM _audit_events")[0][0] if db("SELECT name FROM sqlite_master WHERE name='_audit_events'") else 0
record("N17", "P0", audit > 10, f"_audit_events={audit}")

# ---------- N18 定时提醒(DB 老化 fixture) ----------
# adapted@m2-fieldservice-cfc514a2b129-01:只老化探针自建单。验收 runner 同日已扫过存量单
# (per-order-per-day dedupe 键已占用),盲目老化全部 dispatched 会让扫描撞唯一键整体 400。
okS, evS = False, "ACT_REMIND not set"
if ACT_REMIND:
    # 先中和历史遗留的老化行,避免其混入本次扫描候选
    db(f"UPDATE \"{OBJ_REQ}\" SET \"{AGE_FIELD}\" = strftime('%Y-%m-%dT%H:%M:%SZ','now') "
       f"WHERE \"{F_STATUS}\"=? AND \"{AGE_FIELD}\" <= strftime('%Y-%m-%dT%H:%M:%SZ','now','-48 hours')",
       (ST_DISPATCHED,), write=True)
    ido = f"aged-{TAG}"
    sto3, bo5, _ = act(cust_a, ACT_SUBMIT, {F_DEVICE: dev_a, F_DESC: f"老化单-{TAG}", IDEM_FIELD: ido}, ido)
    rid3 = action_rid(bo5)
    act(manager, ACT_DISPATCH, disp_payload(TECH_EAST, f"d3-{TAG}"), f"d3-{TAG}", rid=rid3)
    aged = db(f"UPDATE \"{OBJ_REQ}\" SET \"{AGE_FIELD}\" = strftime('%Y-%m-%dT%H:%M:%SZ','now','-3 days') WHERE id=?", (rid3,), write=True)
    rem_payload = fill_fields(REMIND_FIELDS, f"rem-{TAG}", f"rem-{TAG}")
    std, bd4, _ = act(manager, ACT_REMIND, rem_payload, f"rem-{TAG}")
    time.sleep(0.5)

    def rid3_reminds():
        _, ibx, _ = http("GET", "/business/notifications", token=tech_e)
        return [i for i in rows_of(ibx)
                if str(rid3) in json.dumps(i)
                and any(k in json.dumps(i, ensure_ascii=False) for k in ("remind", "提醒", "超时", "overdue"))]

    n_first = len(rid3_reminds())
    # 同日去重:重扫不得产生第二条提醒(拒绝或静默跳过均可)
    std2, _, _ = act(manager, ACT_REMIND, fill_fields(REMIND_FIELDS, f"rem2-{TAG}", f"rem2-{TAG}"), f"rem2-{TAG}")
    time.sleep(0.5)
    n_second = len(rid3_reminds())
    okS = std == 200 and aged == 1 and n_first >= 1 and n_second == n_first
    evS = (f"aged={aged}(rid3 only) scan http={std} out={str(bd4.get('output'))[:60]} "
           f"rid3-remind={n_first}; rescan http={std2} rid3-remind={n_second}(same-day dedupe)")
record("N18", "P1", okS, evS)

# ---------- N19 报表 ----------
r1, _, _ = http("GET", f"/reports/{REPORT_THRU}/summary", token=manager)
r2, _, _ = http("GET", f"/reports/{REPORT_PARTS}/summary", token=manager)
r3, _, _ = http("GET", f"/reports/{REPORT_THRU}/summary", token=tech_e)
r4, _, _ = http("GET", f"/reports/{REPORT_THRU}/summary", token=cust_a)
record("N19", "P0", r1 == 200 and r2 == 200 and r3 in (401, 403, 404) and r4 in (401, 403, 404),
       f"manager thru={r1} parts={r2}; tech={r3} customer={r4}(应拒)")

# ---------- N20 受控导出 ----------
if ACT_EXPORT and OBJ_EXPORT:
    # adapted@m2-fieldservice-95bda9c73eaf-01:平台无 POST /objects/{obj}/records/export 通用路由
    # (404 route_not_found),走交付声明的受控导出动作(report_export_controls.export_action)
    # adapted@m2-fieldservice-cfc514a2b129-01:payload 按导出动作契约字段构造
    # (平台严格解码,契约外字段如 reason 直接 400 unknown_field)
    ex1, bx1, _ = act(manager, ACT_EXPORT, fill_fields(EXPORT_FIELDS, f"exp-{TAG}", f"golden-probe-{TAG}"), f"exp-{TAG}", obj=OBJ_EXPORT)
    ex2, bx2, _ = act(tech_e, ACT_EXPORT, fill_fields(EXPORT_FIELDS, f"exp2-{TAG}", f"golden-probe-{TAG}"), f"exp2-{TAG}", obj=OBJ_EXPORT)
    record("N20", "P1", ex1 in (200, 201, 202) and ex2 in (401, 403, 404),
           f"manager export(action)={ex1}({str(bx1.get('output'))[:80]}); tech export={ex2}({bx2.get('code')})")
else:
    ex1, bx1, _ = http("POST", f"/objects/{OBJ_REQ}/records/export", token=manager, body={"data": {"format": "csv"}}, idem=f"exp-{TAG}")
    ex2, _, _ = http("POST", f"/objects/{OBJ_REQ}/records/export", token=tech_e, body={"data": {"format": "csv"}}, idem=f"exp2-{TAG}")
    record("N20", "P1", ex1 in (200, 201, 202) and ex2 in (401, 403, 404), f"manager export={ex1}({str(bx1)[:80]}); tech export={ex2}")

# ---------- N21 有界分页(工作区+门户) ----------
p1, bpp, _ = http("GET", f"/objects/{OBJ_REQ}/records?page_size=2", token=manager)
p2, bpc, _ = http("GET", f"/objects/{OBJ_REQ}/records?page_size=1", token=cust_a)
record("N21", "P1", p1 == 200 and len(rows_of(bpp)) <= 2 and "page_size" in bpp and p2 == 200 and len(rows_of(bpc)) <= 1,
       f"workspace page2={len(rows_of(bpp))} keys={sorted(bpp.keys())[:5]}; portal page1={len(rows_of(bpc))}")

# ---------- N22 菜单差异化 ----------
m1, bm1, _ = http("GET", "/identity/effective-menus?surface=business_workspace", token=tech_e)
m2, bm2, _ = http("GET", "/identity/effective-menus?surface=business_workspace", token=manager)
def mids(b):
    lst = b if isinstance(b, list) else (b.get("menus") or b.get("items") or [])
    return sorted((m.get("id") or m.get("key") or "?") for m in lst)
record("N22", "P1", m1 == 200 and m2 == 200 and mids(bm1) != mids(bm2), f"tech={mids(bm1)} manager={mids(bm2)}")

# ---------- N14 门户可见最终费用(由 N12 驱动后补) ----------
stq, bq, _ = http("GET", f"/objects/{OBJ_REQ}/records/{rid}", token=cust_a)
portal_order = rec_data(bq.get("record") or bq)
fee = portal_order.get(F_QUOTE)
portal_final = final_for_order(rid, portal_order)
record("N14", "P1", stq == 200 and fee is not None,
       f"portal detail http={stq} fee={fee} final={portal_final}")

passed = sum(1 for r in results if r["status"] == "pass")
json.dump({"note": f"M2 golden-probe @ {BASE}, RUN_TAG={TAG}", "results": results},
          open(OUT, "w"), ensure_ascii=False, indent=1)
print(f"\n=== {passed}/{len(results)} golden probes passed → {OUT} ===")
