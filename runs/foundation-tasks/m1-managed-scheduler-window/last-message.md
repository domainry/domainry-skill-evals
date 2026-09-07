已完成 Scheduler foundation 修复；未使用 builder skill，未创建 branch/worktree，也未修改其他 Domainry/CRM 仓库。

## 架构结果

Scheduler 继续拥有受控窗口，因为它已经是 `scheduled_for`、`window_key`、run identity、持久化、recurrence cursor 和 dispatch 的唯一 owner。

新增的是 fail-closed 的可选契约：

```http
POST /scheduler/definitions/{definitionID}/run
Idempotency-Key: <logical-command-key>
X-Operation-Reason: <auditable-reason>
```

普通调用仍无 body，由 Scheduler 使用真实 `time.Now().UTC()`。

受管验证调用使用：

```json
{
  "managed_verification": {
    "contract_version": "domainry-scheduler-managed-verification-run-window-v1",
    "scheduled_for": "2026-09-15T09:30:00Z",
    "authority_proof": "opaque-one-time-proof"
  }
}
```

核心安全策略：

- `scheduled_for` 严格按 RFC3339Nano 解析并规范成 UTC。
- 时间范围为真实当前时间前 5 分钟至未来 31 天。
- authority proof 最大 4096 bytes，不回显、不写入 run evidence。
- host grant 必须绑定 contract、runtime、Action、definition、idempotency key、reason 和 scheduled instant。
- grant 必须包含 authority/grant identity，且最多 5 分钟有效。
- 缺失 authority、无效/过期/mismatch/replay proof 均拒绝。
- 普通 `scheduler.definitions.run` 权限不能单独授权受控窗口。
- managed claim 使用正常 run 表、唯一 window、dispatch 和 downstream receipt，但不推进 recurrence cursor。
- 同 key、同规范请求由持久化 command receipt 重放；同 key 不同窗口返回 409。
- HTTP response 现在明确返回 `id`、`scheduled_for`、`window_key` 和结构化 `downstream_receipt`。

主要契约位于：

- [sdk.go](/Users/tiger/Projects/domainry-scheduler-sdk/sdk.go:187)
- [modulehost/host.go](/Users/tiger/Projects/domainry-scheduler-sdk/modulehost/host.go:60)
- [http_adapter.go](/Users/tiger/Projects/domainry-scheduler-sdk/http_adapter.go:84)

SaaS 使用相同契约，并新增 HMAC 签名 callback：

```text
POST /dispatch/scheduler/managed-verification/run-windows/authorize
```

定义见 [dispatchgateway/gateway.go](/Users/tiger/Projects/domainry-scheduler-sdk/dispatchgateway/gateway.go:20)。

## 修改文件

Scheduler SDK，共 11 个：

- `README.md`
- `sdk.go`, `sdk_test.go`
- `http_adapter.go`, `http_adapter_test.go`
- `modulehost/host.go`
- `saashost/factory.go`
- `saashost/httptransport/transport.go`
- `dispatchgateway/gateway.go`
- `dispatchgateway/remote.go`, `remote_test.go`

candidate8 的 `http_adapter.go`、`http_adapter_test.go` 原有改动已完整保留，并在其上增量实现。

Scheduler，共 15 个：

- `README.md`
- `internal/application/scheduler/service.go`, `service_test.go`
- `internal/infrastructure/persistence/database/scheduler/run_store.go`
- `internal/infrastructure/persistence/database/store_test.go`
- `internal/transport/http/module/adapter.go`, `adapter_test.go`
- `internal/transport/http/saas/server.go`, `server_test.go`
- `internal/assembly/saas/database_service.go`, `database_service_test.go`
- `internal/adapter/schedulersdk/downstream.go`, `downstream_test.go`
- `remote/factory.go`, `factory_test.go`

没有新增 migration；复用了现有 Scheduler-owned run metadata、window 和 receipt 列。

## 验证结果

全部通过：

```text
domainry-scheduler-sdk: go test ./...
domainry-scheduler:     go test ./...
domainry-scheduler-sdk: go vet ./...
domainry-scheduler:     go vet ./...
两个仓库:               git diff --check
```

另外强制非缓存重跑了 application、persistence、module HTTP、SaaS、remote、dispatch gateway 和 SDK contract 相关包，全部通过。

覆盖了：

- 普通空 body 与真实 UTC now
- authority 缺失/拒绝/过期/mismatch/replay
- 严格时间解析、UTC 等价请求规范化、上下界
- managed run 的真实 dispatch 与持久化读取
- command receipt 重放及不同窗口冲突
- recurrence cursor 不污染
- cohort/store 重开后的 run/window/metadata 读取
- Module、remote、SaaS transport 和签名 authority callback
- 13 route 数量及 Action/header metadata 不漂移

## 最终 git 状态

两个仓库都仍在 `main...origin/main`，没有 untracked 文件。

- `domainry-scheduler`：15 个 modified，diff 为 `631 insertions / 66 deletions`
- `domainry-scheduler-sdk`：11 个 modified，diff 为 `662 insertions / 14 deletions`，其中包含原 candidate8 未提交修改

未提交、未切分支。

## 后续 owner handoff

Runtime 只需：

- 升级到本次 SDK。
- Module host 实现 `modulehost.ManagedVerificationRunWindowAuthority`。
- proof 只从 managed-verification 生命周期签发，并以同一规范 idempotency identity 幂等返回原 grant；任何跨 command 使用必须拒绝并审计。
- SaaS 模式实现并注册上述签名 callback，复用同一 authority。
- definition-run facade 使用 `schedulersdk.RunDefinition` 传递 typed request；现有 downstream `scheduled_for → DueAt → EffectiveAt` 无需改协议。
- 不增加 Workflow/Action/human Role 权限。

Plane 只需：

- 保持现有 `scheduler.definitions.run;all` 投影。
- 仅在 managed verification orchestration 中从 Runtime trusted authority 获得 opaque proof。
- 调用同一个 definition-run route 并提供 managed body。
- 普通用户调用继续无 body；Plane 不签发、自验或用布尔 header 替代 authority。
- 以返回的 `run_id + scheduled_for + window_key + downstream_receipt` 收集证据。