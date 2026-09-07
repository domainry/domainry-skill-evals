你是一次性 Domainry Runtime foundation 修复 task。请直接在当前 checkout 开发：

- 主工程：`/Users/tiger/Projects/domainry-runtime`
- 需要只读消费当前 source contract：`/Users/tiger/Projects/domainry-scheduler-sdk`
- 可只读核对 Scheduler 实现：`/Users/tiger/Projects/domainry-scheduler`

这是 Runtime 底座修复，不是业务项目开发。严禁使用 `domainry-builder-v1` Skill；不得创建 branch/worktree/new checkout；不得 reset/checkout/覆盖用户已有改动。先完整读取 Runtime `AGENTS.md`、当前代码、测试和 git diff。Runtime 工作树有大量既有改动，都是用户/其他 foundation task 的资产，必须保留；尤其 `startup.go`、`service_assembly.go`、Workflow 相关文件只能最小合并。不得修改 Scheduler/SDK、Plane、eval 或 CRM 源码。

## 问题与 owner 边界

Scheduler/SDK 已新增 managed-verification run-window 契约：

- `domainry-scheduler-sdk/sdk.go`：`DefinitionRunRequest`、`ManagedVerificationRunWindowRequest`、`ManagedVerificationRunWindowAuthorizationRequest`、`ManagedVerificationRunWindowGrant`。
- `modulehost.ManagedVerificationRunWindowAuthority`：Module 模式的可选 host authority，缺席必须 fail closed。
- `dispatchgateway.ManagedVerificationRunWindowAuthorizePath`：SaaS Scheduler 通过 HMAC 调 Runtime 同一 authority，固定路径 `/dispatch/scheduler/managed-verification/run-windows/authorize`。
- SDK remote 使用 Scheduler `Idempotency-Key` 作为 HMAC identity。

Runtime 现有时间链已经正确，不是本次缺陷，严禁改成业务特例：

`Scheduler Trigger.ScheduledFor -> Runtime DueAt -> Workflow EffectiveAt -> payload.scheduled_at -> $workflow.scheduled_at`

不得在 Runtime 引入 `evaluation_time`、lead、7-day、weekend、CRM、manual Workflow、backdate、DB 回填或全局 clock override。Runtime 只负责可信进程宿主 authority、Module/SaaS 共用装配、SaaS HMAC callback，以及已有 `scheduled_for` 事实透传。Scheduler 仍独占 run/window/cursor/persistence；Plane managed verifier 后续负责生成评估专用密钥与签发 proof。

## 必须实现的 proof/trust 契约

1. 每次 managed evaluation 使用独立 Ed25519 keypair。Runtime 只接收 `authority_id + public_key + trust_expiry` 的可信、进程启动私密输入；私钥永不进 Runtime。
2. 不得新增任何领取/签发 proof 的 Runtime HTTP API。后续 Plane 用 inherited FD 将 trust 注入 Runtime，私钥留在 Plane 进程，并在 Scheduler 请求前 just-in-time 签发 compact proof。
3. 在 Runtime 提供一个稳定、窄的公共包（例如 `pkg/runtimeverification`，但请按当前架构命名），集中定义 claims、canonical token、Ed25519 issue/verify 和 trust/source 契约，供 Plane 复用；Plane 不应复制解析/签名规则。
4. proof claims 精确绑定：contract version、proof/grant ID、authority ID、runtime ID、固定 Action `scheduler.definitions.run`、definition key、idempotency key、reason、UTC `scheduled_for`、issued/expiry。严格 canonicalize，TTL 不超过 SDK 5 分钟，trust 也必须未过期。
5. Runtime authority 验签、再逐字段比对 SDK authorization request，用 mutex/等价原子机制消费 proof ID。完全相同 canonical request 的重试可返回同一 grant；同 proof 改任一字段必须 fail closed；并发首次使用只能有一个逻辑 grant。
6. allow/deny 都必须通过有 error 返回的 Runtime Audit append 边界持久审计；审计写失败则授权失败。审计只记 authority/grant/proof ID、绑定摘要和 allow/deny outcome，不得记 raw proof、private key、public key 或 proof hash。任何 response/error/log 也不得包含密钥/proof。
7. 没有 trust/authority 时，ordinary Scheduler 仍正常；managed window 必须显式 Required/Denied，不能退化到 `TriggerNow`。

## 精确实现面（以当前代码调研后的最小设计为准）

- `pkg/runtimehost/options.go`：新增窄的 trusted managed-verification startup source/trust Option；不能放入普通 `config.Config`、manifest、project config 或用户可配置字段。
- `pkg/runtimehost/host.go`：加载 source 并将非私钥 trust 传入 `bootstrap.ProjectStartupOptions`；加载/验证失败必须启动失败，不打印 key material。
- `runtime/bootstrap/runtime/business_seed_references.go` 与 `runtime/bootstrap/bootstrap.go`：增加并透传 trust。
- 新增窄的 Runtime authority 实现（建议在 `runtime/bootstrap/composition/`），使用 Runtime Audit application 和 installation-scoped system principal。
- `runtime/bootstrap/runtime/startup.go`：在 records/audit 已装配后只构造一个 authority 实例，注入 Scheduler Module host 和 HTTP assembly。
- `runtime/bootstrap/composition/scheduler_sdk_module_host_wiring.go`：增加不破坏旧调用者的 authorized constructor/wrapper；authority 为 nil 时 dynamic host 不应谎称提供可选 interface。
- 经 `runtime/bootstrap/runtime/construction.go`、`runtime.go`、`http_server.go`、`runtime/bootstrap/transport/http_server_assembly.go`、`http_record_process_handler_wiring.go` 将同一 authority pointer 透传到 dispatch handler，不新建业务 service。
- `runtime/transport/http/dispatch/`：注册 SDK 固定 callback path；小 body limit；严格 JSON/unknown/trailing 校验；校验 `X-Domainry-Runtime-ID`；按 wire 的 idempotency key 验证现有 Scheduler HMAC；调同一 authority；再次 `grant.Validate`后编码 SDK wire grant。401=签名/runtime 错，400=wire malformed，403=authority 缺席/拒绝，500=持久审计失败。
- 同步 `http_router_middleware.go`的 bearer-auth 精确例外（仍必须 Scheduler HMAC）、endpoint route policy、OpenAPI 和对应 inventory tests。Runtime 不得 republish `/scheduler/...` source-owned routes。
- 现有 Workflow 核心文件无需修改；只增加独立整链/契约测试，锁定 `scheduled_for == $workflow.scheduled_at`。

## 必须测试

- proof：好签名；错 key/签名/版本；每个绑定字段单独篡改；过期/未来过长/oversize/unknown/trailing；秘密不泄漏。
- authority：首次 allow + durable audit；完全相同 retry 同 grant；同 proof 改任一字段 deny；并发消费；allow/deny 审计；审计写失败 fail closed；nil trust 时可选 interface 缺席。
- Module：真实 Scheduler module `RunDefinition` 经 host authority 把签名 `scheduled_for` 送到 downstream `DueAt`；无 authority 返回 Required；ordinary 仍是 real UTC。
- SaaS callback：正确 HMAC；missing/tampered/stale/wrong runtime/wrong idempotency identity/malformed/oversize/nil authority 拒绝；返回 grant 逐字段一致；Module/SaaS 使用同一 authority。
- 整链：`Scheduler scheduled_for -> DueAt -> EffectiveAt -> $workflow.scheduled_at` 精确相等；代码/manifest 不存在 `evaluation_time` 特例。
- 全量 `go test ./...`、`go vet ./...`、`git diff --check`。使用当前 workspace/local source 验证 Scheduler/SDK；不得留下 `replace`。

注意：Runtime `go.mod` 当前仍锁旧 Scheduler/SDK 版本。当前修复先使用工作区本地 source 编译/测试；最终交接必须列明发布/锁版依赖，不能伪称旧版本已包含新 API。

最终输出必须列出：架构决定与 owner 理由；精确公共 API/FD handoff；修改文件；与既有 dirty worktree 的合并情况；测试命令/结果；git status/diff；给 Plane 的精确后续交接。自行完成，不等 root 确认。
