你正在全新、隔离的 Git 项目中执行 Domainry M1 baseline。显式使用 `$domainry-builder-v1`；评测对象仅为当前隔离 CODEX_HOME 中安装的这个 Skill。

请从零完成一个 Delivery Batch，严格执行 Skill 的 `requirements → model → apply → verify → done`，完整交付下方全部产品需求，不得降级或延后。

运行约束：

- 只使用 Skill 自带的 `bin/domainry-cli`，不要安装、升级或修改 Skill，也不要启动、停止或修改 Domainry Plane。
- `apply model` 使用 Go module path `example.com/domainry-m1-crm/backend`，并显式追加 `--service http://127.0.0.1:8283`。
- `verify` 使用独占地址 `127.0.0.1:19286`，并使用 `$DOMAINRY_EVAL_SQLITE_PATH` 作为唯一数据库路径。
- 每一条 Domainry CLI 命令必须单独作为一次 shell 命令执行，不要把多条 CLI 调用合并在同一个 shell command 中。
- 实时维护 `.domainry/development/stages.json`，只包含 requirements、model、apply、verify 四个阶段的 started/ended epoch 秒；源码实现和 `apply finalize` 都计入 apply。
- 只有 `verify` 返回 `state=verified_and_stopped`、两阶段业务流证据全部通过且 TODO 进入 done 后，才可声明完成。

最终回复简明报告 batch、delivery、测试和 Runtime 结果，并以单独一行 `EVAL_RESULT={"state":"done"}` 结束。若没有真正完成，必须如实使用 `EVAL_RESULT={"state":"not_done"}`。

# M1 Benchmark：销售线索 CRM 需求规格

本文档是 benchmark 的唯一产品需求输入。

## 业务背景

一家 B2B 公司的销售团队管理线索（lead）到成交客户（customer）的全流程：销售录入并跟进线索，大额转化需销售总监审批，团队按部门划分数据边界，管理层看漏斗报表并导出。

## 组织与角色

- 销售分属**部门**（至少两个部门：华东区、华北区），存在汇报线。
- **sales_rep（销售）**：录入/跟进自己名下的线索；可见范围=本部门线索；发起转化。
- **sales_director（销售总监）**：全部门可见；审批大额转化；查看/导出漏斗报表。

## 功能需求

### 线索管理

1. 线索字段：公司名（必填）、联系人、联系电话、预计金额（精确金额，两位小数）、来源（select：官网/展会/转介绍/外呼）、状态、负责人（销售）、部门、创建/更新时间。
2. 线索状态机：`new → contacted → qualified → converted / lost`；`qualified` 可标记 `lost`；`converted`、`lost` 为终态，不可再转换。
3. 销售创建线索（初始 new，负责人=本人，部门=本人部门）；可更新自己名下线索的联系人/电话/预计金额/来源。
4. 跟进（contacted）与合格判定（qualified）由负责人执行；状态只能沿定义的转换变化。
5. 线索创建幂等（相同幂等键重复提交只建一条）。

### 转化与审批（核心业务）

6. 负责人对 `qualified` 线索发起**转化**：预计金额 < 100000 时直接转化；≥ 100000 时必须进入**审批流**，由 sales_director 审批。
7. 审批通过：线索进入 `converted`，并在**同一事务**中创建 `customer` 客户记录（承接公司名/联系人/金额/来源线索引用）；审批拒绝：线索回到 `qualified` 并记录拒绝原因。
8. 转化必须幂等：同一线索重复发起转化不产生第二个客户。
9. 审批结果（通过/拒绝）以站内通知发给发起的销售。
10. 客户记录只读（任何角色不可更新/删除客户；修正走新流程，本期不做）。

### 数据边界

11. 销售的线索可见范围 = **本部门**（同部门同事的线索可见，跨部门不可见）；更新/状态操作仅限**自己名下**。
12. 总监全量可见。
13. 所有状态变化与转化审批留审计。

### 跟进提醒（到期续接）

14. 线索进入 `contacted` 时必须持久化独立的 `status_changed_at` 与 `next_followup_at`；业务 Handler 根据部署时区和工作日日历，把 `next_followup_at` 计算为距该次状态变化超过 7 天后的首个工作日早晨。Workflow 监听 `next_followup_at` 的字段变化；其合法 Graph V2 必须以非空唯一 node/edge ID 和有效端点连接 `trigger → contract.condition{type=field_equals,field=status,value=contacted}` 的 `true` 分支 → one-shot timer → Action，`false` 分支不得到达 timer。timer 用 `source_field=next_followup_at` 消费这个已经算好的精确时间，不得在 timer 内再次用 offset/business calendar 重算。Runtime 全局持久化 `record_timer` worker 到期后恢复流程；业务 Action 重读当前状态并幂等写提醒，若仍为 `contacted`，再由 Handler 把 `next_followup_at` 推进到下一工作日早晨，从而触发新的 one-shot timer。进入/离开 `contacted` 的业务 Action 分别设置/清空 `next_followup_at`；旧 timer 在状态退出后到点必须无副作用。提醒对象必须用显式 composite unique `(lead, local reminder date)` 保证每条线索每个本地日期最多一条，任意无关 unique 字段或把 recipient 加入该唯一键均不能替代。不得生成指向本 follow-up Workflow/Action 的租户 Scheduler definition；即使没有 Scheduler definition，任何指向 lead/本提醒 Action 的 scheduled Workflow 全表扫描也直接失败。所有生产 Action 和 Workflow 均不得出现 `evaluation_time`，也不得用通用 `updated_at` 代替 `status_changed_at`；无关业务 Scheduler 仍可存在。

### 报表与导出

15. 总监可见**漏斗报表**：按状态统计线索数与预计金额合计；销售无权查看。
16. 总监可**导出线索明细 CSV**（带当前权限过滤）；导出必须走受控导出通道（有界、审计、requester 专属）。
17. 线索列表服务端有界分页。

### 导航与验收

18. 两角色登录 Business Workspace 后菜单与权限一致（销售：我的线索；总监：全部线索、报表）。
19. 提供两个部门 × 各 1 名销售 + 1 名总监的非人类验收身份，以及覆盖所有状态、两个部门、含 ≥100000 与 <100000 金额的种子线索（≥6 条），保证每条需求可在真实 Runtime 验证。

## 范围限定

仅 Business Workspace；无 Consumer Portal、无外部连接器；金额计算只做求和，不涉及分成/结算。

## 公开业务旅程追踪 ID

`docs/backend-requirements-prd.md` 必须建立需求 → flow ID → 测试名/路径追踪；`backend/tests/businessflow/` 下对应的顶层 Go 测试名必须以 `TestBFxx` 开头。同一 ID 可以拆成多个测试，但每个分支都要验证持久化终态和失败后的状态不变性。

- `BF01`：销售创建线索、创建幂等、本人更新、负责人状态推进，以及同部门非负责人写入拒绝。
- `BF02`：小额线索从 qualified 直接转化、只创建一个只读客户，并验证重放幂等。
- `BF03`：大额线索发起审批并由总监通过；线索转化与客户创建同事务，发起人收到通知。
- `BF04`：大额审批拒绝；线索回到 qualified、拒绝原因与通知可读，且不创建客户。
- `BF05`：两个部门销售的同部门可见/跨部门不可见、总监全量可见、有界分页和角色菜单差异。
- `BF06`：工作日 one-shot 到期续接提醒；验证 `status_changed_at`/`next_followup_at` 持久化、到点前不执行、Runtime 在精确 due 后恢复并推进下一工作日 due、重放与同日本地日期去重、Runtime 重启恢复，以及状态退出后旧 timer 无副作用。
- `BF07`：总监漏斗报表的状态计数与金额合计正确，销售访问被拒绝。
- `BF08`：总监受控 CSV 导出完成、审计、requester 专属可见与下载；销售发起导出被拒绝。

`BF06` 采用公开的组合验收合同：业务流通过普通 `lead.advance` 黑盒证明进入 contacted 后两个时间字段真实持久化、`next_followup_at` 严格晚于 7 天且为下一工作日早晨、没有立即提醒，并在 restart 阶段读取同一 lead/时间字段。`backend/actions/crm` 必须提供并通过 `TestM1Req14DueCalculation`、`TestM1Req14EnterContactedPersistsDue`、`TestM1Req14ExitContactedClearsDue`、`TestM1Req14DueActionIdempotentContinuation`、`TestM1Req14ExitedStateNoop`；evaluator 要求这些测试产生非零项目 Handler 覆盖，空测试不能通过。这些项目 Handler 测试可注入 clock，但生产输入不得包含 `evaluation_time`。`backend/tests/recordtimer` 必须提供并通过 `TestM1Req14RuntimeRecordTimerExactDue` 与 `TestM1Req14RuntimeRecordTimerRestartRecovery`，直接执行实际 Domainry Runtime record-timer 代码，以真实 now+短 duration 独立证明持久 due、到点前 no-op、全局 worker 自动 resume 和到期前重启恢复。evaluator 使用 project delivery 优先、local module download cache 后备的 file-only hermetic `GOPROXY`、`GOFLAGS=-mod=readonly` 和必要 SDK build tag，执行 `go list -m -json github.com/domainry/domainry-runtime`，拒绝 Main module、任何 Replace 或落入 project tree 的本地冒充，并要求解析版本/校验和与 delivery binding 一致以及 Runtime record-timer 非零覆盖；空测试或 blank import 不构成证书。不得为此新增 CRM rearm/snooze/短延时 Action，也不得在业务流自报内部 timer ID。

evaluator 还会临时注入并独立哈希自己的 Go probe，直接调用外部 Runtime 的公开 record-timer policy，断言 `next_followup_at` source field 在零 offset 下保留精确 due，且默认全局 worker 已启用；项目不能提供或替换该 probe。

BF06 结构证据在 initial 使用 `lead.contacted.due.persisted`、`lead.contacted.no_immediate_reminder`、`handler.followup_due.focused_tests`、`runtime.record_timer.integration_tests`，restart 使用 `lead.contacted.due.restart_durable` 及相同两个 test-suite operation；两阶段的 lead ID 与两个时间字段必须相同。test-suite observation 只声明公开 suite ID/required cases 并要求 evaluator certificate，实际测试由 evaluator 独立执行和哈希，不由业务流伪造结果。

其中 persisted observation 包含 `record_id,status,status_changed_at_persisted,next_followup_at_persisted,status_changed_at,next_followup_at,local_next_followup_at,calculation_owner=project_handler,business_calendar_key`；no-immediate 包含 `record_id,next_followup_at,observed_at,reminder_count_before=0,reminder_count_after=0`；restart-durable 包含 `record_id,status,status_changed_at,next_followup_at,read_after_restart=true,reminder_count=0`。这三条还必须声明 `real_clock=true,evaluation_time_supplied=false,direct_database_write=false,scheduler_invoked=false`。Handler/timer suite ID 分别为 `m1_req14_handler`/`m1_req14_runtime_record_timer`，并携带完整 `required_cases` 与 `evaluator_certificate_required=true`。
