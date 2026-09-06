# Builder Skill 评估指标规范 v3

本文档是评估体系的唯一指标权威。所有 scorecard 字段名以本文档为准。

## 设计原则

1. **机器可提取**:所有指标来自 CLI JSON 输出、`.domainry/` 回执、transcript token 记账、金标准验收脚本结果。禁止采用 agent 自述的成功声明。
2. **金标准独立**:覆盖度对照评估库预定义的 golden checklist 计算,不对照 agent 自己写的 PRD。
3. **失败必归因**:每个失败记录 owner 分类,只有 `skill_doc` 类失败是 Skill 优化的直接目标。
4. **分层跑**:L0/L1 每次改动都跑,L2 每优化批次跑,L3 每大版本跑。

## 北极星指标

**pass@1(一次成型合格率)**:无人工干预、单次尝试跑到 `done` 且金标准验收断言全部通过的比率。
辅助:**pass@3**(3 次重复中至少 1 次合格)与指标方差,度量稳定性。

pass@1 的基础条件是 done 声明、金标准全过、零人工干预。除此之外，严格首轮证据必须
包含当前 `model_plan`、`apply_model`、`apply_finalize`、`verify` 四个 CLI family 的首次捕获；
最终回执只能用于定位，不能反推第一次调用。基础条件失败时输出 `false`；基础条件成立但
缺少任一严格首轮捕获时输出 `null`(不可判)，不会把 agent-driven 最终成功冒充 pass@1。

## A 组数据源与 `A_source`

A 组每个字段的取值来源记录在顶层 `A_source` 字段(`{A1..A6: source}`),枚举:

- `cli-capture`:runs/<dir>/cli/NNN-*.json 捕获工件(driver 驱动模式,首选);
- `receipts-derived`:agent-driven run 无对应 cli 工件时,从 run 的
  `project/.domainry/` 回执回退推导(A1 ← `blueprint-validation.json` 诊断数 +
  `model-apply.json` preflight;A2 ← `model-apply.json` state + model-sync journal;
  A3 ← `receipts/finalization.json`;A4 ← `receipts/verification.json`、
  `receipts/package.json` 与最终 stopped/current Runtime 证据)。注意回执多为"最后状态"文件,该口径是
  「成功回执存在且无失败回执」,与"首次调用即通过"非严格同义;
- `not_measurable`:两边都推不出,字段值为 `null`,不参与 pass@1 判定。
  A6(返工轮数)定义于 cli 工件序号,无捕获时恒 not_measurable。`receipts-derived`
  字段可用于诊断，但不满足严格 pass@1 的首轮证据要求。

## A. 准确率漏斗(定位错在哪一层)

| 字段 | 定义 | 数据源 |
|---|---|---|
| `A1_plan_first_pass` | 首次 `model plan` 是否成功且无显式失败诊断 | `model_plan` 捕获工件 / 建模诊断回执 |
| `A1_plan_error_count` | 首次 plan 的显式错误数 | 同上 |
| `A2_apply_first_pass` | 首次 `apply model` 是否成功 | `apply_model` 捕获工件 / apply 回执 |
| `A3_finalize_first_pass` | 首次 `apply finalize` 是否成功 | `apply_finalize` 捕获工件 / finalization 回执 |
| `A4_verify_first_pass` | 首次 `verify` 是否完整通过且最终 stopped | `verify` 捕获工件 / verification、package、Runtime 回执 |
| `A5_acceptance_first_pass` | evaluator 独立金标准验收是否首轮全过；baseline 在 verify 前首败封存、checker 未执行时为 `null`，来源为 `not_measurable` | `acceptance_check` 捕获工件 / checklist result |
| `A6_rework_rounds` | 同一 CLI family 失败后再次调用的往返总数 | 捕获工件序号 |
| `A7_false_done` | Agent 声称 done，且 oracle/done 不一致并非纯 benchmark/platform 缺陷 | done、golden 与 failure owner |

同时保留两个审计字段：`A7_oracle_done_mismatch` 原样记录“done 与冻结 oracle 不一致”；
`A7_false_done_classification` 区分 `no_oracle_done_mismatch`、
`benchmark_or_platform_mismatch`、`agent_false_done`、`unattributed_mismatch`。因此冻结
checker 有错或纯 CLI/Runtime platform 缺陷不会再被描述为 Agent 虚假完成；旧 scorecard 的
原 A7 值不回写，仍按当时 schema 保留审计。

## B. 覆盖度(对金标准)

| 字段 | 定义 |
|---|---|
| `B1_golden_hit_rate` | 金标准功能点命中率,P0 权重 2、P1 权重 1 |
| `B2_silent_downgrade_count` | 被跳过/降级且未在 TODO 声明的金标准功能点数 |
| `B3_platform_reuse_rate` | 用平台元数据能力实现的功能点 / 可复用功能点总数 |

新 checklist 每项显式输出 `reuse_eligible`、`mechanism` 与 `mechanism_detail.evidence_sources`。
B3 分母只含 `reuse_eligible=true`，分子只含其中状态通过且由 Runtime/manifest 真实证据分类为
`reuse` 的项；必须由项目事务 Handler 完成的项不进入分母。缺少 `reuse_eligible` 的旧结果
继续使用旧的 `reuse|custom` 分母口径，保证可读但不与新口径静默混算。
兼容字段 `mechanism` 仍为 `reuse|custom`；`mechanism_detail.classification` 可进一步标成
`hybrid`，并列出实际参与的 manifest、Runtime operation 与 `project_handler` 来源。

## C. 时长与成本

| 字段 | 定义 |
|---|---|
| `C1_wall_clock_seconds` | 任务开始到 done 声明 |
| `C2_total_tokens` | 兼容字段，等于供应方累计 `input_tokens + output_tokens`。cached input 已包含于 input、reasoning output 已包含于 output，均不重复相加；事件流没有完整 input/output snapshot 时保持 `null`，不得估算。 |
| `C2_usage_breakdown` | `{input_tokens, cached_input_tokens, non_cached_input_tokens, output_tokens, reasoning_output_tokens, budget_tokens}` 及包含关系/可观测状态。可选明细按事件 fail closed，缺失为 null；预算使用 `budget_tokens=input+output`。 |
| `C3_reading_token_ratio` | 读 Skill 文档消耗 / 总消耗(度量文档冗余税)。需 transcript token 记账,当前 agent-driven 模式无数据源,暂不自动计算。 |
| `C4_cli_invocations` / `C4_cli_retries` | 评分通道 CLI 调用总数 / 其中重试数；不含 `verify_fixture`。 |
| `C4_diagnostic_cli` | 独立非计分 diagnostic 通道的调用、失败和首次失败；不进入 A4、C4 主计数或 retry budget。 |
| `C5_stage_seconds` | 兼容四段汇总 `{requirements, model, apply, verify}`，由 evaluator 观察的五段关键路径折叠得到：requirements=discovery、model=plan、apply=apply+finalize、verify=verify。主来源是 `stage-timing.json`；无该工件的旧 run 才回退到 driver `stages.json` 或 mtime 近似。缺边界的阶段为 null，整体标 `partial`/`unavailable`，不得估算。 |
| `C5_stage_timing` | evaluator 观察的 `{discovery, plan, apply, finalize, verify}` 区间、每个端点 provenance、已观察关键路径总时长、unknown 阶段和热点。Agent 在阶段 CLI 后终止且下一阶段未开始时，最后一次当前阶段 CLI completed 是优先结束边界；仅未配对 started 可回退到严格关联的 `agent_ended_epoch`。后续阶段不补 0。固定边界见 run-protocol。 |
| `C5_project_stage_report` | Agent `.domainry/development/stages.json` 的独立校验与同口径差值。它只能交叉验证，坏数据不会覆盖或清空 evaluator 时间线。 |

## D. 稳定性与干预

| 字段 | 定义 |
|---|---|
| `D1_repeat_pass_rate` | 同一 benchmark 重复 N 次的合格率 |
| `D2_human_interventions` | 人工干预次数(卡死解围、澄清、纠错) |

## 运行资格字段

新 scorecard 额外输出 `run_kind`、`parent_run_id`、`terminal_state`、
`measurement_complete`、`pass_at_1_eligible` 和 `run_outcome_pass`。convergence 的
`pass_at_1=null`；预算截断、baseline 首败截断或其他不完整终态的 `pass_at_1=false`，即使
目录里碰巧存在最终成功回执也不能冒充首轮完成证据。

`environment_valid=false` 的 session/candidate/freeze/service 隔离失败无条件排除 pass@1 与 run outcome；
按设计在首个评分失败处封存的 baseline 则保持 `environment_valid=true`，仅因首败边界而不能通过。
这些语义属于 `scorer_schema=domainry-builder-eval-v3`。已归档 v2 scorecard 原样保留；读取
旧 run 输入做诊断时必须写到新路径，禁止覆盖其历史 scorecard。

## 失败归因分类(每个失败一条记录)

- `skill_doc`:文档歧义、规范空洞、示例缺失、文档间矛盾 → Skill 优化目标
- `skill_tooling`:Skill 自带 CLI、脚本或模板缺陷 → Skill 优化目标
- `cli_platform`:CLI/Plane/Runtime 缺陷或缺失能力 → 上报框架,不计入 Skill 分
- `model_capability`:文档正确、示例充分但 agent 仍然做错 → 换模型/加 few-shot
- `benchmark_defect`:金标准本身有错 → 修 benchmark,该项作废重跑

## 评估层级

| 层级 | 内容 | 成本 | 触发 |
|---|---|---|---|
| L0 | 诊断触发(预埋缺陷 → 期望诊断码) | 分钟 | 每次改动 |
| L1 | 单阶段微评估(建模一次成型、诊断修复) | 分钟~小时 | 每次改动 |
| L2 | 单模块 model→apply→handler→check | 小时 | 每优化批次 |
| L3 | 全量 benchmark 到 done + 金标准验收 | 半天 | 每大版本 |

## Scorecard 命名

`scorecards/<benchmark>-<skill-version>-<run-id>.json`。候选主标识使用安装包版本与
Skill 树哈希前缀；完整 `skill_tree_sha256` 和 `cli_binary_sha256` 必须保存在 run freeze manifest，
保证优化前后可比且不依赖任何源码仓库 commit。
