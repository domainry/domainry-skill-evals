# 平台侧缺陷清单(cli_platform 归因,交框架团队)

来源:S1 benchmark 的 baseline→opt-07 全部评估 run,每条均有 run 工件与复现路径(见 `runs/*/failures.json`)。这些缺陷不受 Skill 文档优化影响,封顶任何 agent 的 pass@1 上限。

> **修复状态 2026-08-18**:P0-#1/#2/#3、P1-#7(菜单首建死结)、P1-#8(fake 不强制 CAS 谓词)已在框架仓库 worktree `/home/ubuntu/framework-platform-fixes` 分支 `platform-fixes` 修复(commit 216abbe/1bc3ee5/08aff68/9e535b1/9fd4a18,一缺陷一提交,各带修前必挂回归测试;根因与细节见提交信息)。**已于 2026-08-18 15:30Z 部署**:`platform-fixes` 已快进合入本地 `main`(42e2988→9fd4a18,未推远端);评估库 CLI 已替换为修复版构建(旧版备份 `bin/domainry-cli-v2.pre-platform-fixes`);Plane 重启为 v0.0.2-platform-fixes(从修复源码构建,状态目录/信任根在 worktree `.codex-run` 下全新生成,旧 Plane 状态保留于框架主检出 `.codex-run` 可回滚)。冒烟:新 CLI↔新 Plane SDK 物化+能力披露全链通过。行为级回归(#1 transition fail-closed、#7 菜单首建)由下一个 benchmark run 在真实交付上覆盖;修复自带的 fail-before/pass-after 回归测试已全绿。#8 附注:上轮 run 的 fake 是 agent 手写而非平台生成——平台缺口在于密封的 mutation 类型使忠实 fake 不可能写出,修复导出了共享谓词校验。遗留:定义删除后再重加不会自动 re-enable(与 action 修剪器同语义,待产品决策);#4/#5/#6、P2 组、acceptance runner 建议仍开放。

## P0(破坏正确性/静默错误)

1. **transition Action 不带状态 payload 时静默假成功**。调用 `POST .../actions/<transition>` 且 `data` 缺状态字段:返回 200、写下 "Executed action" 审计事件,但状态不变(no-op)。应 fail-closed 报缺参。复现:任一 transition_state Action 空 payload 调用后读回记录。危害:审计与真实状态矛盾,上层以 200 判成功。
2. **模型删除的 automation 规则在既有 Runtime 库不收敛**。model 删除规则 → evolution apply → 重新打包部署后,`automation_rule_definitions` 中的旧定义仍存在并继续执行;只有删库重建 cohort 才生效。危害:演进部署后行为与模型不一致。
3. **校验器互斥:create-only Handler 无合法空读集写法**。结构层要求 behavior 元组 `read_set` 非空(`ledger.business_handler_gap_required` 文案),组合层要求 `read_set` 精确等于 `handler.data_access` 派生集(`ledger.business_handler_effect_set_mismatch`)。data_access 仅 create 时两规则无交集,必须人为添加一条 read 声明才能通过。

## P1(能力缺口/正确路径不可达)

4. **生成的类型化 SDK 丢弃记录版本**。`runtimeext.Record` 携带 `Version`/`UpdatedAt`,但 `decode<Object>` 丢弃;而 `NotificationIntent.Valid()` 强制 `SubjectVersion` 非空 → 正规类型化通道无法满足,finalize/check 均不拦,运行时才失败。需在生成 schema 暴露版本或放宽 Valid。
5. **action context coding 投影缺 `capabilities.Principal` 类型定义**,测试 fake 无法仅凭 context 写出。
6. **`model validate` 不校验 automation instruction config 形状**。错误的 config(如 `{reference: ...}`)通过 validate/apply/finalize/check 全链,首次暴露在运行时(所有创建被拒)。校验器应装载 instruction schema。
7. **Identity 菜单首建死结:业务菜单在正规 authoring 通道不可创建**(fullflow-053ab2d91ecb-01 itg-02)。`PUT /identity/menus/{id}` 强制非空 `Expected-Schema-Hash`,但不存在菜单的实际资源 hash 为空,必检直接拒绝;又无 `POST` 集合创建路由 → 角色差异化菜单(S1 R15)整类需求不可交付,终态只能记 acceptance_failed。需允许首建时空 hash(或提供集合创建路由)。
8. **生成的 handler 测试替身不强制 ConditionalUpdate 谓词**(fullflow-053ab2d91ecb-01 itg-01)。fake `ConditionalUpdate` 接受无条件 mutation,而真实数据层拒绝(`backend.generated.conditional_mutation_required`)→ 缺 CAS 条件的 handler 单测全绿、五层静态检查放行,首次暴露在运行时。测试替身应与数据层同规则校验 mutation。

## P2(体验/耗时)

7. **acceptance prepare 相对 `--project` 路径误报** `managed Runtime database identity escapes the current project`(`filepath.Rel` 对相对根失败);绝对路径正常。应先归一化。
8. **validate 分阶段渐进披露**(结构 fail-fast → schema/compose 清单 → runtime_manifest 编译)放大返工轮数;且 exit code 0 时 state 可能为 `repair_required`,脚本消费者易误判。
9. **`project source finalize` 静默依赖 PATH 上的 go**,失败信息 `exec: "go": executable file not found` 无指引。
10. **Skill 自带 CLI 二进制仅 macOS arm64**,Linux 环境不可执行且无平台变体/降级提示(评估环境自行从源码编译解决)。

> **第二批修复 2026-08-19 已部署**(main 0d4a928..2993469,7 commit + 1 test-fix,CLI/Plane 已重建为 v0.0.4-main):#11 双层授权统一+validate 拦截不可满足键、#12 锁到期自动解除、F-V5 冲突错误码契约对齐、F-V4/V3 分页契约(接受 Runtime 原生 offset 分页与完整单页证明)、F-V6 嵌套 .gitignore、**声明性能力缺口=accepted limitation(acceptance check 不再因环境缺口硬失败)**。全部带修前必挂回归测试,12 个受影响包测试全绿。行为级复验由 M2 run 覆盖。仍开放:#4/#5/#6、P2 组、F-V1 PG-RLS(环境)、F-V2(基准分母)。

> **第三批修复 2026-08-19 已部署**(main 3ea791a..2786111 共 11 commit + 3 对齐 commit,CLI/Plane 已重建为 **v0.0.5-main**,冒烟通过:validate=valid、SDK 物化 25 文件确定性一致、能力披露 61 类):#4 SDK 暴露记录版本(decode 回填 UpdatedAt,NotificationIntent 类型化通道自洽)、#5 coding 投影含 capabilities.Principal、#6 validate 按闭合契约校验 automation instruction config、#13 dev 模式 runtime start 一次性披露引导凭据(生产不受影响,8 个 prod 变体测试拒披露)、**#17 隔离验收改为库无关行为证明(security_posture 的 RLS 要求彻底移除,F-V1 根因清除)**、**F-V2+frontend_intent_trace:backend-only 交付(机器判定 frontend/src 无常规文件)的分母不再要求任何前端型证据,原子性用 http_exchange+transaction_trace+persistence_snapshot+audit_correlation 证明**、P2-7 相对路径归一化、P2-8 validate repair_required 非零退出+两层发现合并披露、P2-9 缺 go 工具链明确报错、P2-10 skill 安装器异平台 CLI 警告+源码构建指引。全部带修前必挂回归测试。行为级复验由 m2-fieldservice-7d3799dded4c-01 run 覆盖。**仍开放:acceptance runner 自动执行器(P0 建议)**;另records:projectmaterializer 的 TestV6SourceFinalizerFailsClosedOnConcurrentDirectSourceChange 预存红灯(早于本批,待查)、frontendcomponentcontract 2 例缺前端契约物料(环境)。

## 新增(m2-fieldservice run,2026-08-19)—— ⚠️ 定性已更正

**根本缺陷是验收检查器,不是框架隔离能力。** 框架的租户隔离 = **workspace 应用层**(每表带 `workspace_id`、查询按 workspace 过滤,见 `internal/runtime/infrastructure/persistence/database/workspace_scope_migration.go`)+ 声明式业务数据域(部门/站点 + owner/assignee)。**PostgreSQL RLS 是可选纵深防御**,SQLite cohort 完全跳过(`workspace_rls.go:37` 短路:非 postgres 或 RLS 未开即不启用),绝非隔离生效的必要条件。

**⚠️ 架构原则(用户 2026-08-19 明示):框架禁用任何数据库特有能力,将来要多库切换。** 隔离必须走数据库无关的 workspace 应用层,不得依赖 RLS 等 PG 专有特性。这条原则统辖以下条目。

17. **P0(检查器缺陷,opt-16 靶点):acceptance denominator/checker 把租户隔离用例(F-V1,22 例)的通过证据硬绑成"必须证明 PostgreSQL `rls_enabled+rls_forced` security_posture"**。双重错误:①测错机制(框架在 workspace/应用层强制隔离,检查器却要 DB 层 RLS 证明);②**违反多库可移植原则**(要求一个把系统焊死在 PG 上的机制)。**正确修法:改成数据库无关的隔离证明——跨 workspace/跨站点不可见、非 owner/assignee 写拒、门户 identity 绑定行级(普通 SQL 即可验);彻底移除对 `rls_*`/`set_config`/security_posture 的要求,不保留为"可选加分"。** F-V1 的真正根因。

18-20(归档,不修):M2 agent 误入 PG-RLS 歧途时(为迁就 #17 错误标准自起 PostgreSQL)发现的三处 RLS 路径启动 bug(`BEGIN READ ONLY` 包裹噎死能力探针;非属主重发 `CREATE INDEX`/`ALTER TABLE`)。**按多库可移植原则,PG-RLS 纵深防御路径本就不应启用,故归档不修;** wire 代理(`docs/harness/pg_proxy.py`)与 PG 进程已全部拆除清理。

## 新增(fullflow-5287d3b722c2-01,2026-08-18)

11. **P0:多段权限键两层授权解释不一致,validate 放行运行时必拒**。action 的 `requires_permission` 用三段式键(如 `ticket.transition.start`)时:`ActionAllowed` 的 3 段兼容分支(`parts[1]==objectKey`)放行,但 `ActionAuthorization.Validate` 的二次校验以 `(action.ObjectKey, 末段)` 重算成 `ticket.start` 必拒 → 合法执行者一律 403 `backend.permission.denied`,且 `model validate` 不拒绝该键形。源码:`internal/runtime/domain/identity/contract/identity_authorization_contract.go`(IdentityRoleAllows)vs `internal/runtime/application/action/action_application_service.go` + `internal/runtime/domain/action/policy/action_pipeline_policy.go`(ActionSplitPermission 取末两段)。本轮金标准 F05/F06/F07 全部因此失败;权限键命名方差可翻转行为验收。修复方向:统一两层解释或 validate 拒绝/规范化多段键。
12. **P1(疑似):账号锁定 `locked_until` 到期不自动解锁**。agent_wang 锁定至 15:11,15:17+ 登录仍 403 `auth.account_locked`;须 admin `POST /identity/users/{id}/unlock` 才恢复。若为设计需文档化。
13. **P1:托管 dev Runtime 无合规的验收凭据引导路径**。身份种子密码来自部署侧 `AUTH_DEFAULT_PASSWORD`,skill 明文"无文档化共享默认密码"、dev headers 关闭、guest 不可用、Identity API 供给自身需 admin 会话 → 全新 agent 无任何不伪造的会话路径(本轮 F-ACCEPT-01,终态 verification_blocked)。driver 实测内置开发默认值 `Domainry@2026` 实际可用——应在 dev 模式提供合规披露/引导(或 CLI 在 runtime start 时输出一次性引导凭据),并配套 run 协议的部署方凭据交接。

## 建议的验证方式

修复后用评估库回归:`runs/e2e-*` 与 `runs/l1-model-ed940eb45f92-01`(strict pass@1)可整链重放;金标准探针 `benchmarks/s1-ticketing/golden-probe.py` 对 1/2/4 有直接断言价值。

## P0 建议(新增):`project acceptance run` 标准用例自动执行器

评估已实测 121 用例分母的 typed-artifact 契约(15 种 kind,幂等指纹/unit_of_work/进程重启/SSE 恢复/worker lease 均需运行时内部事实)。这些事实只有 Runtime/CLI 自身能权威产出;要求每个项目 agent 手写 harness 是当前流程最大的耗时项且引入伪造风险。建议 CLI 提供 `project acceptance run --cases standard`,对分母中机械可执行的用例族(http/幂等三连/权限正反/RLS/分页/审计关联/重启)自动执行并写 typed artifact;agent 仅补业务特定用例。A4 指标在该命令存在前记为 not_measurable(工具缺失),不计入 Skill 分。

## 新增(m2-fieldservice-cfc514a2b129-01,2026-08-19)—— runner v1 实战暴露

21. **P0(F8,平台批 5 已修):acceptance runner 登录不带 `X-Workspace-ID`,强制头交付下 192 用例全 skip**。`runner/local.go doOnce` 只在持 token 时设置该头,/auth/login 恒无 token → 交付侧生成的全路由 workspace 强制中间件 403 → runner 一个用例都执行不了,runner-first 收益归零。修复:头改为 override > session > 默认 workspace 三级回退,与 token 解耦(含修前必挂回归 TestLocalRuntimeSendsWorkspaceHeaderWithoutToken)。遗留:runner 仍只实现 action/report/runtime 三族(注入/并发/worker/SSE/restart 等族显式 skip,v2 已机械化 concurrency_conflict)。
22. **P1(F9):scheduler 手动运行缺幂等键报 `operations.idempotency_contract_required` 而非 `backend.idempotency.key_required`**,且指纹=f(definition, caller key),异指纹键重用冲突不可达 → 分母的 scheduler 幂等两用例在真实平台上永不可证,只能 declared_gap。错误码/指纹契约需与分母生成器对齐。
23. **P1(F10):scheduled workflow 被禁手动运行(`manual_run_disabled`),而 scheduler 只接受 scheduled workflow 目标** → workflow 正向用例(6 例)无可运行业务面,只能经 scheduled-jobs 生命周期等价证明。分母生成器或平台需给 workflow 正向用例一条可达路径。
24. **P2(F11):导出 dedupe 是排除 audit_id/Idempotency-Key 的规范指纹**(键重用冲突不可达)、导出审计单次使用、customer prepare 拒绝为隐匿式 404 —— 三处与分母期望错误码/形态不一致,均落 declared_gap。
25. **P2(F12,环境):托管 SQLite Runtime `SetMaxOpenConns(1)` 全串行化,乐观 version_conflict 不可达**(12/12 竞争均输给领域状态错误)→ concurrency_conflict 族 7 例在 SQLite cohort 永为 declared_gap;runner v2 的 CAS 机械探针同受此限。多库语境下属已知取舍,分母应按 dialect 标注可达性。
26. **P2(F13):job_run 停在 `retrying` 不会脱离 schedule 自动续跑**;恢复端点 `/operations/scheduler/runs/{id}/retry` 为 admin-only 且需 reason+confirmation 头。设计如此则需文档化到 skill/分母。
27. **P2(F14):`.gitignore` 属受保护物化文件**(编辑→finalize protected_materialization drift;mode 须 0644),验收证据只能经 `.git/info/exclude` 排除出源身份。skill 已按此路径走通(树哈希双态一致证明),平台可考虑放开受控追加或文档化。

> **第 4+5 批修复 2026-08-19 已部署**(main 565985f..6da528b + bd9cc32/6b25bd4,CLI/Plane 已原子重建为 **v0.0.8-main**,冒烟通过:validate=valid、Plane 物化正常、发布管线 CLI 契约探针内置全过):批 4=契约左移 ×5(IF-1/2/3+EX-A/EX-C)、runner v2 concurrency_conflict 机械化、增量证据失效(artifact_manifest+carry-forward+`project acceptance stale-report`);批 5=#21/F8(runner 全请求带 X-Workspace-ID)+ 发布 fixture ORDER BY 对齐(IF-3 左移曾使 release build 必挂)。行为级复验由 m2-fieldservice-e3881bed55da-01 run 覆盖。仍开放:#22-27(F9-F14,多为契约/分母对齐类)、runner 未机械化族。

## 新增(m2-fieldservice-e3881bed55da-01,2026-08-19)—— v0.0.8-main 实战

F8 修复实战确认(runner 77 例 0 失败);runner v2 使 concurrency_conflict 全可证。新条目(详见该 run 项目内 integration-findings.json):

28. **P1(F-01):identity authoring 通道对幂等键的要求与文档/错误提示不一致**,agent 需试错发现。
29. **P1(F-02):workflow 定义的 `$run.` 绑定前缀在交付运行时不可解析**,验证期无提示,运行时才失败。
30. **P2(F-03):角色菜单语法与命名门户路由的组合约束未文档化**(menu grammar vs named portal routes)。
31. **P1(F-04):export prepare 在缺 scope 对象时返回 500**(应为 4xx 契约错误)。
32. **P2(F-05):菜单软删除后 id 不可复用且无提示**(重建同名菜单被阻塞)。
33. **P1(F-08):异步导出 job 投影不暴露可用 download_token(值 `<nil>`)**,下载只能经 artifact 签发的 governed token;投影字段与实际能力不符。
- F-06(scheduled workflow 禁手动运行)= 既有 #23;F-07(拒绝的 404 隐匿)≈ 既有 #24 —— 两条在新交付上复现,维持开放。
- **runner 覆盖缺口(平台批 6 P0 候选)**:本 run runner skip 100/177(workflow/scheduler/export/SSE/restart 族及带业务 payload 的 action 变体),自建断言仍占 91 例——验收段最大剩余杠杆。配套候选:分母机制级去重(纯信封族按机制证一次)、重启分批执行。

> **F14 结构性修复 2026-08-19 已合入 main(d18002e)**:源快照按契约内置排除 `backend/tests/evidence/**`(验收观测子树,终结后写入属设计),不再需要任何 ignore 条目;保留子树内被强制跟踪的文件也不入源身份(契约收紧,git tracked-overrides-ignore 语义在其余路径不变)。修前必挂回归 TestSnapshotExcludesAcceptanceEvidenceWithoutIgnoreEntries;受影响包(projectsource/sourcefinalizer/backendacceptance 全家)测试全绿。部署随下一次换版(与 runner 批 6 一起)。清单 #34(F14)关闭。
