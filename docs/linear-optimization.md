# 线性优化与回滚协议 v2

优化历史必须保持**线性、单假设、可单点回滚**。本仓库只评估已经安装好的
`domainry-builder-v1` 候选，不读取、修改或构建 Skill / Domainry Plane 源码仓库。
Skill 的开发、提交与安装发生在 evaluator 之外；安装完成后才冻结候选并开始测量。

## 规则

1. **单假设批次**：每个优化批次只验证一个假设。一个候选可以包含多个文件变化，但必须服务同一假设。
2. **候选不可变**：Agent 启动前由 `harness/eval_config.py` 校验当前安装目录，冻结 package version、
   `skill_tree_sha256`、`cli_binary_sha256` 和 Runtime contract。运行中或运行后任一身份漂移都会使 run 无效。
3. **不以源码 commit 作为候选身份**：源码仓库位置、分支和 commit 不进入 evaluator 配置，也不能替代安装包闭环哈希。
4. **评估后裁决**：每个批次评估完，在 `OPTIMIZATION_LOG.md` 追加一行，verdict 只有三种：

   - `keep`：目标指标改善且无其他指标显著劣化；
   - `rollback`：目标指标未改善，或任何北极星/漏斗指标劣化；在 Skill 自己的开发流程中回退并重新安装，evaluator 不代为改源码；
   - `rework`：方向成立但候选仍有缺陷；生成并安装新候选后创建新 run，不覆盖旧 run。

5. **劣化判定基线**：与上一个 `keep` 候选的同口径 scorecard 对比，不与任意历史 run 拼接结论。
6. **新基线必须全新运行**：baseline 不复用项目目录、Agent 会话、数据库 cohort、上游检查点或以前的结论。

## 分阶段检查点复评

分阶段复评只用于已建立 baseline 后的单假设定位，不能产生或替代 baseline / pass@1。
每个优化批次先声明最早受影响阶段：`requirements`、`model`、`apply`、`verify`。
当前 Skill 的阶段只有 `requirements → model → apply → verify → done`；实现与
`apply finalize` 属于 apply，done 是终态，不存在 implement 阶段。

1. 只能从上一个 `keep` 候选产生的只读父检查点恢复；受影响阶段及全部下游必须重跑。
2. 检查点至少保存父检查点 ID、候选身份闭环、需求哈希、外部服务目标、Runtime contract、
   数据库引擎、阶段输出哈希和阶段耗时。
3. 恢复后必须使用新项目副本与新 SQLite cohort，不共用可变运行态。
4. 同一阶段的 A/B 候选必须从同一父检查点分别派生，不能把 A 的修复输出作为 B 的输入。
5. 定期从零执行全链回归，验证分段复评没有隐藏跨阶段劣化。
6. driver 同时记录外层阶段边界。若 Agent 的 `stages.json` 与外层边界相差超过 5 秒，
   效率比较使用 driver 外层耗时，并把差异记为测量缺陷。

| 最早受影响阶段 | 可复用的父检查点 | 必须重跑 |
|---|---|---|
| requirements | 无（全新需求输入） | requirements 及以后全部阶段 |
| model | requirements-complete | model 及以后全部阶段 |
| apply | model-planned | apply 及以后全部阶段 |
| verify | apply-finalized | verify |

## OPTIMIZATION_LOG.md 行格式

| 批次 | candidate_id | 假设 | 跑过的评估 | 关键指标变化 | verdict |
|---|---|---|---|---|---|
