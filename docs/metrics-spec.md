# Builder Skill 评估指标规范 v1

本文档是评估体系的唯一指标权威。所有 scorecard 字段名以本文档为准。

## 设计原则

1. **机器可提取**:所有指标来自 CLI JSON 输出、`.domainry/` 回执、transcript token 记账、金标准验收脚本结果。禁止采用 agent 自述的成功声明。
2. **金标准独立**:覆盖度对照评估库预定义的 golden checklist 计算,不对照 agent 自己写的 PRD。
3. **失败必归因**:每个失败记录 owner 分类,只有 `skill_doc` 类失败是 Skill 优化的直接目标。
4. **分层跑**:L0/L1 每次改动都跑,L2 每优化批次跑,L3 每大版本跑。

## 北极星指标

**pass@1(一次成型合格率)**:无人工干预、单次尝试跑到 `done` 且金标准验收断言全部通过的比率。
辅助:**pass@3**(3 次重复中至少 1 次合格)与指标方差,度量稳定性。

pass@1 判定**只依据可测得的字段**:基础条件(done 声明、金标准全过、零人工干预)恒可测;
A 组漏斗条件仅纳入 `A_source` 非 `not_measurable` 的字段。漏斗字段全部 not_measurable 且
基础条件成立时,pass@1 输出 `null`(不可判)而不是 `false`——防止 agent-driven run
(无 cli/ 捕获工件)被机械性判负。

## A 组数据源与 `A_source`

A 组每个字段的取值来源记录在顶层 `A_source` 字段(`{A1..A5: source}`),枚举:

- `cli-capture`:runs/<dir>/cli/NNN-*.json 捕获工件(driver 驱动模式,首选);
- `receipts-derived`:agent-driven run 无对应 cli 工件时,从 run 的
  `project/.domainry/` 回执回退推导(A1 ← blueprint-validation.json 诊断数 +
  model-apply preflight;A2 ← model-apply.json state + model-sync journal;
  A3 ← receipts/verification.json checks,口径对齐 cli 漏斗的 project_verify,
  finalize 拒收轮不进 A3;A4 ← development/acceptance-evidence 验收结果 0 failed,
  declared_gap 不计失败)。注意回执多为"最后状态"文件,该口径是
  「成功回执存在且无失败回执」,与"首次调用即通过"非严格同义;
- `not_measurable`:两边都推不出,字段值为 `null`,不参与 pass@1 判定。
  A5(返工轮数)定义于 cli 工件序号,无捕获时恒 not_measurable。

## A. 准确率漏斗(定位错在哪一层)

| 字段 | 定义 | 数据源 |
|---|---|---|
| `A1_validate_first_pass` | 首次 `model validate` 是否 0 错误 | validate-001.json |
| `A1_validate_error_count` | 首次 validate 错误数 | 同上 |
| `A2_apply_first_pass` | 首次 `model apply` 是否成功 | apply-001.json |
| `A3_build_first_pass` | 首次编译+finalize+focused tests 是否通过 | verify/finalize 回执 |
| `A4_acceptance_first_pass_rate` | 第一轮验收 passed/total | acceptance results / golden probe |
| `A5_rework_rounds` | 各阶段 失败→修复→重试 的往返总数 | artifacts 序号 |
| `A6_false_done` | agent 声称 done 但金标准验收失败(布尔,最严重) | done 声明 vs golden 结果 |

## B. 覆盖度(对金标准)

| 字段 | 定义 |
|---|---|
| `B1_golden_hit_rate` | 金标准功能点命中率,P0 权重 2、P1 权重 1 |
| `B2_silent_downgrade_count` | 被跳过/降级且未在 TODO 声明的金标准功能点数 |
| `B3_platform_reuse_rate` | 用平台元数据能力实现的功能点 / 可复用功能点总数 |

## C. 时长与成本

| 字段 | 定义 |
|---|---|
| `C1_wall_clock_seconds` | 任务开始到 done 声明 |
| `C2_total_tokens` | 全程 token(input+output+cache) |
| `C3_reading_token_ratio` | 读 Skill 文档消耗 / 总消耗(度量文档冗余税)。需 transcript token 记账,当前 agent-driven 模式无数据源,暂不自动计算。 |
| `C4_cli_invocations` / `C4_cli_retries` | CLI 调用总数 / 其中重试数 |
| `C5_stage_seconds` | 各阶段耗时分布 {requirements, model, apply, implement, verify}。所有真实 Runtime 业务旅程验证均属于 verify，不单列新阶段。读取顺序:agent 实时产出的 `project/.domainry/development/stages.json`(各阶段 {started, ended} epoch,见 run-protocol「投放提示要求」)> run 目录 stages.json(driver 手工)> run 内回执/证据文件时间戳 best-effort 近似(受后期演化覆盖污染,仅兜底)。来源标注于 `C5_stage_seconds_source`("agent-stages.json" / "stages.json" / "mtime-approx"),拿不到的阶段为 null。 |

## D. 稳定性与干预

| 字段 | 定义 |
|---|---|
| `D1_repeat_pass_rate` | 同一 benchmark 重复 N 次的合格率 |
| `D2_human_interventions` | 人工干预次数(卡死解围、澄清、纠错) |

## 失败归因分类(每个失败一条记录)

- `skill_doc`:文档歧义、规范空洞、示例缺失、文档间矛盾 → Skill 优化目标
- `skill_tooling`:Skill 自带脚本/模板缺陷(gates.py、TODO 模板等)→ Skill 优化目标
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

`scorecards/<benchmark>-<skill-version>-<run-id>.json`,`skill-version` 取 Skill 包内容的短哈希,保证优化前后可比。
