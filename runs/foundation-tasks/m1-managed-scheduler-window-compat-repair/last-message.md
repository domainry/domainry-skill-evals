修复已完成，未创建 branch/worktree/checkout，未使用 `domainry-builder-v1`，也未修改 Runtime、Plane、eval 或 CRM 源码。

### 审查问题修复

- P1-1：恢复普通 `TriggerNow` 契约
  - [service.go](/Users/tiger/Projects/domainry-scheduler/internal/application/scheduler/service.go:191) 普通调用重新返回 claim 时的 `leased` run，不回读 terminal 状态。
  - managed `RunDefinition` 仍在真实 claim/dispatch/persistence 后回读 terminal run 与 receipt。
  - SaaS `DatabaseService.TriggerNow` 同样恢复普通 Binding 行为。
  - 恢复并加强了 `leased + no receipt` 断言，同时保留 managed `succeeded + receipt` 断言。

- P1-2：恢复 ordinary window wire 兼容
  - [run_store.go](/Users/tiger/Projects/domainry-scheduler/internal/infrastructure/persistence/database/scheduler/run_store.go:208)：
    - ordinary：`UTC().Format(time.RFC3339)`，保持秒精度 header/HMAC wire。
    - managed：`UTC().Format(time.RFC3339Nano)`，保留纳秒精度。
  - 新增 fractional ordinary run 的持久化、window header 和精确 HMAC 回归测试。
  - managed 纳秒精度及 recurrence cursor 不推进测试继续保留。

- P2：reason fail-closed
  - [sdk.go](/Users/tiger/Projects/domainry-scheduler-sdk/sdk.go:206) 新增 managed command source-boundary validation。
  - managed request 在 authority/claim/dispatch 前强制非空 reason 和合法 idempotency key。
  - SDK helper 与 Scheduler Service 两层均 fail closed；ordinary `TriggerNow` 不受影响。
  - 增加 direct SDK 和 direct Service negative tests。

### SaaS route owner/parity 结论

正确 owner 是 Scheduler：

- Module 与 Scheduler SaaS 由同一 assembly 构造同一份 13-route adapter 和 Scheduler-owned command-receipt store：[open.go](/Users/tiger/Projects/domainry-scheduler/internal/assembly/module/open.go:39)。
- Scheduler SaaS server 在自身进程挂载 `/scheduler/...`，通过 `X-Domainry-Runtime-ID` 选择应用：[server.go](/Users/tiger/Projects/domainry-scheduler/internal/transport/http/saas/server.go:78)。
- `remote.binding` 明确保留为非 `modulehttp.Provider`，Runtime 不会 republish Scheduler routes。
- `/v1/applications/{runtime}/...` 仍只是 Runtime→Scheduler 私有协议，不再被视为 public Action parity。
- 测试验证 SaaS adapter 的 13 个 Action、权限和 route 定义与 SDK source contract 完全一致。

### 验收结果

全部通过：

- 两库 focused tests，`-count=1`
- 两库 `go test ./...`
- 两库 `go vet ./...`
- 两库 `git diff --check`

### 当前 diff/status

`domainry-scheduler`：

- `main...origin/main`
- 17 个已修改文件，`+920/-86`
- 无 staged/untracked 文件

涉及：

```text
README.md
internal/adapter/http/executor_test.go
internal/adapter/schedulersdk/{downstream.go,downstream_test.go}
internal/application/scheduler/{service.go,service_test.go}
internal/assembly/module/open.go
internal/assembly/saas/{database_service.go,database_service_test.go}
internal/infrastructure/persistence/database/{store_test.go,scheduler/run_store.go}
internal/transport/http/module/{adapter.go,adapter_test.go}
internal/transport/http/saas/{server.go,server_test.go}
remote/{factory.go,factory_test.go}
```

`domainry-scheduler-sdk`：

- `main...origin/main`
- 11 个已修改文件，`+719/-14`
- 无 staged/untracked 文件

涉及：

```text
README.md
dispatchgateway/{gateway.go,remote.go,remote_test.go}
http_adapter.go
http_adapter_test.go
modulehost/host.go
saashost/factory.go
saashost/httptransport/transport.go
sdk.go
sdk_test.go
```

上述统计包含保留的 candidate8 与第一次 run-window task 正确增量。