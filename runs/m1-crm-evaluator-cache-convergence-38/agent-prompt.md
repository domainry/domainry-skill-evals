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

### 跟进提醒（定时）

14. 每天早上（工作日）由**定时任务**扫描：`contacted` 状态超过 7 天未变化的线索，给负责人发站内提醒（每条线索每天最多提醒一次）。

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
- `BF06`：工作日逾期跟进提醒，包含单日去重及重启后结果保持。
- `BF07`：总监漏斗报表的状态计数与金额合计正确，销售访问被拒绝。
- `BF08`：总监受控 CSV 导出完成、审计、requester 专属可见与下载；销售发起导出被拒绝。

## Evaluator-owned isolation and checkpoint policy

Work only in the current Git project and use only the candidate Skill installed in the provided isolated CODEX_HOME. The evaluator restored this project from the immutable checkpoint named by the convergence lineage, but created a new Agent session and a fresh Runtime SQLite cohort. Continue from the existing packet-ready project state; do not repeat completed requirements, model planning, or model application work unless the current candidate requires a compatibility migration. This later policy overrides any base-prompt wording that says to start from zero or assumes an empty project. Do not resume or import any prior Agent session, database, external project, TODO, or other checkpoint. Do not search parent or external directories for evaluator assets, golden checks, scorers, or historical runs. This convergence run can never be pass@1 evidence.

### Authoritative checkpoint resume boundary

The evaluator checkpoint manifest is authoritative over restored project-local stage reports, TODOs, finalization receipts, and verification receipts. Those files describe the state at capture time and can be stale under the current candidate. Follow the resume boundary below before any verify command. If it requires a compatibility migration, redo only the affected plan/apply/finalize closure; do not repeat unrelated completed work and do not reuse a stale signed Runtime package. The prohibited repairs are hard semantic constraints.

```json
{"prohibited_repairs": ["do not change Plane, Runtime, Identity, or the installed Builder candidate for this evaluator-only defect", "do not grant the Agent broad filesystem access", "do not remove the project-owned Handler or move CRM orchestration into Runtime", "do not increase store quota or recreate a CRM department registry", "do not restore Git history, Agent sessions, Runtime databases, locks, or stale receipts"], "resume_boundary": {"next_node": "after the evaluator supplies a writable explicit DOMAINRY_CACHE_DIR under checkpoint-excluded project-managed Runtime state, restore this project and rerun apply model under the same installed candidate, then preserve the typed provision_department Handler and continue with focused tests, BF01-BF08 completion, apply finalize, full tree, and managed verify", "prior_delivery_id": "sha256:a1a7aed4a3ddc21d59f2cedb8250e159c76db90261e3e0584f2f963634d7e937", "rule": "Do not repeat accepted requirements or unrelated model work; do not modify foundation code for this evaluator-only error; do not restore Git history, Agent sessions, managed Runtime state, SQLite, locks, or stale verification/finalization evidence.", "stage": "apply"}}
```


## Evaluator-owned measured-run policy

This is an explicitly selected convergence run. Repairs and retries are allowed within the recorded budgets. This run is never pass@1 evidence.
