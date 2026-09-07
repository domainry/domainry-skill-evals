你是一次性 Domainry Scheduler foundation 修复 task。请直接在当前 checkout 修正刚完成的 managed-verification run-window patch：

- 主工程：`/Users/tiger/Projects/domainry-scheduler`
- 同一 source-owner 契约工程：`/Users/tiger/Projects/domainry-scheduler-sdk`

这是底座修复，不是业务项目开发。严禁使用 `domainry-builder-v1` Skill；不得创建 branch/worktree/new checkout；不得 reset/checkout/覆盖用户已有改动。先完整读取两库 `AGENTS.md`、当前代码、测试和 git diff。保留 candidate8 以及第一次 run-window task 的所有正确增量。不得修改 Runtime、Plane、eval 或 CRM 业务源码。

独立代码审查已经确认下面 3 类 foundation 问题。测试全绿不代表可以忽略；你必须修正语义并增加能防回归的精确测试。

## P1-1：普通 production `TriggerNow` 返回语义被意外改变

HEAD 中 `Service.TriggerNow` 在 claim + dispatch 后返回当时的 claimed `leased` run；现在它委托 `RunDefinition`，而新方法 dispatch 后再 `runs.Get`，使 direct SDK/API 普通调用变成返回 `succeeded + receipt`。证据：

- `internal/application/scheduler/service.go` 当前约 191-250
- `internal/assembly/saas/database_service_test.go` 原有 `leased` 断言被改为 `succeeded`

修复要求：

- 普通 `TriggerNow` / ordinary direct binding 保持原有返回契约。
- managed `RunDefinition` 可为黑盒证据返回 terminal run + downstream receipt；外部 HTTP adapter 也可通过 run read 返回 terminal projection，但不能藉此改变旧 Binding API。
- 恢复并锁死普通调用的旧断言，同时保留 managed terminal receipt 断言。

## P1-2：普通 run 的 `window_key` wire 兼容被改变

当前 patch 把所有 run 的 `window_key` 从原来 `UTC().Format(time.RFC3339)` 改成 RFC3339Nano。`window_key` 会进入 direct HTTP 的 `X-Domainry-Schedule-Window` 且参与 HMAC，因此普通 fractional timestamp 会改变下游幂等/signature wire。证据：

- `internal/infrastructure/persistence/database/scheduler/run_store.go` 当前约 208-241
- `internal/adapter/http/executor.go` 约 82、92

修复要求：

- ordinary due 继续生成原 RFC3339 秒精度 window key/wire。
- managed-verification due 保留已发布的规范 UTC RFC3339Nano 精确时间，不丢精度。
- 增加 ordinary fractional ScheduledFor 的 run/window/header/HMAC 回归测试，并保留 managed nanosecond 精度测试。

## P1/P2：拓扑契约与 reason validation

审查证据：

- SDK contract 宣称 `/scheduler/...` 由 Scheduler 在 Module/SaaS 拓扑拥有（SDK `http_adapter.go` 约 51-54）。
- source-owned 13-route adapter 当前只在 Module 装配（Scheduler `internal/assembly/module/open.go` 约 95-103）。
- `remote.binding` 只实现 Binding/DefinitionRunner，不实现 `modulehttp.Provider`；Runtime 也只挂实现 Provider 的 binding。私有 `/v1/applications/{runtime}/triggers` 并不等价于 public Action route parity。

请先根据当前架构判定正确 source-owned 方案，并完成之前一次 task 明确要求的 Module/remote/SaaS parity；不得让 Runtime republish Scheduler-owned routes。若真的需要另一个 owner 先建能力，则停在精确的 owner handoff，不能通过改 Runtime 或弱化契约来伪造 parity。

另外，`Service.RunDefinition` 现在只验证 managed idempotency key，没有在 Scheduler source boundary 强制非空 reason；SaaS callback wire 会拒绝空 reason，Module host 却可能被过宽 authority grant 放行。必须在 Scheduler source boundary 使 Module/SaaS 一致 fail closed，加 direct SDK negative test。这是 P2，不得把 `reason` 变成业务字段。

## 必须保留的正面性质

- 普通 nil/empty body 仍使用 Scheduler real UTC now；方法/path/permission/idempotency/reason 约束不漂移。
- proof 不回显、不进 run metadata/日志/持久 evidence；authority grant 绑定 runtime/action/definition/key/reason/time/TTL。
- same key + UTC-equivalent request receipt replay；different window 为 409。
- managed 新 claim 不推进 recurrence cursor，但仍走真实 claim/dispatch/persistence。
- 13 route Action contract 数量和权限不漂移。
- 不得引入 `evaluation_time`、CRM、lead、7-day、weekend、notification 等业务语义。

## 验收与输出

运行两库的 focused tests、`go test ./...`、`go vet ./...`、`git diff --check`。不得通过削弱测试或更改旧期望来过关。最终说明：每个审查问题怎么修正；SaaS public route owner/parity 的事实结论；修改文件；测试命令/结果；两库 git status/diff。自行完成，不等 root 确认。
