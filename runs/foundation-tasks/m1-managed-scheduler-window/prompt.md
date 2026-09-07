你是一次性的 Domainry Scheduler foundation 修复 task。请直接在当前 checkout 开发：

- 主工程：`/Users/tiger/Projects/domainry-scheduler`
- 同一 source-owner 契约工程：`/Users/tiger/Projects/domainry-scheduler-sdk`

这是底座修复，不是业务项目开发。严禁使用 `domainry-builder-v1` Skill；不要创建 branch、worktree 或新 checkout；不要 reset/checkout/覆盖用户已有改动。先读两个工程的当前代码、测试、`AGENTS.md` 和 git diff，再基于事实实施。Scheduler 当前 clean；SDK 的 `http_adapter.go`、`http_adapter_test.go` 已有 candidate8 的未提交 Scheduler definition-run route 改动，必须保留并在其上增量开发。不要修改 `domainry-plane`、`domainry-runtime`、`domainry-skill-evals` 或任何 CRM 业务源码。

## 已证实的问题

M1 的 BF06 必须在全新、短生命周期 managed Runtime 中证明：工作日由真实 Scheduler 运行、`contacted` 超过 7 天才提醒、同 lead/当地日期去重、通知、权限拒绝以及同一数据库 cohort 重启后持久。不能睡 7 天，也不能 backdate/bootstrap/直接改 DB。

当前 source contract 是：

- `POST /scheduler/definitions/{definitionID}/run`
- nil body；必需 `Idempotency-Key`、`X-Operation-Reason`
- `scheduler.definitions.run` permission（Plane 投影为 `;all`）
- module adapter 只调用 `TriggerNow(definitionID, reason)`
- Scheduler `Service.TriggerNow` 内部硬取 `time.Now().UTC()` 作为 `ScheduledFor`
- Scheduler run/command receipt 已持久化，Runtime 已能把 `Trigger.ScheduledFor -> DueAt -> EffectiveAt -> workflow payload["scheduled_at"]` 原样传播

因此短生命周期黑盒验证无法让“同一次真实 Scheduler run”带一个受控的工作日窗口。此前 evaluator agent 尝试在 CRM 中新增人类可调用 manual Workflow 并把它与一个空跑 Scheduler 拼成证据；该方案已被拒绝并保存干净 v5 Checkpoint。这里不能实现 CRM 特例，也不能把 `evaluation_time` 领域字段塞入 Scheduler。

## 你的职责

作为 Scheduler source owner，请仔细调研后设计并实现一个通用、最小、fail-closed 的 **managed verification run-window** 契约，并在 Scheduler SDK 精确发布它，供后续 Runtime 和 Plane task 消费。具体 wire shape（可选 request/body/header、host attestation callback/context 等）必须由当前架构推导；不要让 Plane/Runtime/业务代码猜接口。

硬约束：

1. 普通 production 调用完全兼容：nil body 的 definition-run 仍使用 Scheduler 自己的 real UTC now，现有 method/path/permission/idempotency/reason 语义不变。
2. 受控窗口只能在 host 明确、一次性、managed-verification authority 已通过时接受；缺失、无效、过期/重放、越界或 production 普通权限调用必须 fail closed。Scheduler/SDK 要发布 host 必须实现的稳定授权边界，不能信任一个普通客户端自称的布尔 header。
3. 受控值表达 Scheduler-owned `scheduled_for` / run window，不是 CRM/领域 `evaluation_time`，不是全局 clock override，不改数据库 fixture，不允许 human Role 获得内部 Action/Workflow 权限。
4. 这必须仍是同一个真实 Scheduler definition-run：Scheduler 持久化 run、生成 run/window identity、走真实 dispatch，Runtime 下游只接收现有 scheduled window。不能先空跑 Scheduler 再另走一条 workflow/action 路径。
5. 时间须严格解析、UTC 规范化并有明确 bounded policy；普通 recurrence cursor 不得因 managed verification 的 ad-hoc window 被推进或污染。
6. 同一个 HTTP Idempotency-Key + 同一规范请求重放返回同一 run/command receipt；同 key 不同窗口冲突。run response/持久化读取应能精确关联 `scheduled_for`、run_id、window_key 和 downstream receipt。
7. 保持 module/remote/SaaS 拓扑边界，`module` 与 `remote` 不互相依赖；公共包只保留稳定 host-facing contract。若当前架构要求 Scheduler SDK 新增 request/authority/option 类型，必须有明确 validation 和兼容路径。
8. 不要把 BF06、lead、工作日、7 天、notification 或任何 CRM 语义写入底座。

## 最低验收

- SDK OpenAPI/Action contract 精确描述普通 nil-body 与受管窗口请求、所有必需 headers/authority 前提、响应；现有 13 route 与 normalized Action metadata 不漂移（除本需求明确新增的受管 prerequisite）。
- Scheduler module HTTP adapter 和 application service 有正/负/重放/冲突/UTC/边界/cursor 不污染测试。
- 若 SaaS/remote 同一公共 contract 受影响，完成对应实现和测试，不能只修 embedded module。
- 未提供 host authority 时，无论调用者有普通 `scheduler.definitions.run` permission 与否，都不能指定窗口。
- full relevant tests、`go test ./...`、`go vet ./...`（若仓库既有 gate 支持）通过；不得通过削弱测试实现。
- 最终回复列出：选择的架构与为什么 owner 在 Scheduler；SDK 给 Runtime 的精确 API/wire/authority handoff；修改文件；测试命令与结果；两个 repo 的最终 git diff/status；后续 Runtime、Plane 各自只需做什么。若发现必须由另一个 owner 先改，停止写错层代码，给出逐文件证据和精确 handoff，不要用业务 workaround。

这是一次性 task：在上述范围内自行完成，不等待 root 确认。
