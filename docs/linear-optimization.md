# 线性优化与回滚协议 v1

优化历史必须保持**线性、单假设、可单点回滚**。禁止把多个互不相关的改动混进一个批次——否则劣化时无法定位是哪个改动造成的。

## 规则

1. **单假设批次**:每个优化批次只验证一个假设(如「为 8 种 kind 补 payload schema → A1 首过率上升」)。一个批次可以改多个文件,但必须服务同一假设。
2. **一批次一提交**:Skill 改动落在 plane 仓库 `main` 分支上(2026-08-18 起单分支工作流,skill-opt/platform-fixes 已合入并删除;历史 commit 哈希不变),一个批次恰好一个 commit,commit message 格式:

   ```
   skill-opt(<批次号>): <假设一句话>

   Hypothesis: <预期哪个指标从多少到多少>
   Evals: <本批次要跑的评估层级/任务>
   ```

3. **禁止 rebase/squash 已评估过的提交**:scorecard 通过 commit hash 关联版本,历史改写会使关联失效。
4. **评估后裁决**:每个批次评估完,在本仓库 `OPTIMIZATION_LOG.md` 追加一行,verdict 只有三种:
   - `keep`:目标指标改善且无其他指标显著劣化;
   - `rollback`:目标指标未改善,或任何北极星/漏斗指标劣化 → 立即 `git revert <该批次 commit>`(revert 本身也是一个 commit,历史仍线性);
   - `rework`:方向对但实现有缺陷 → 新批次修正,不覆盖旧提交。
5. **劣化判定基线**:与上一个 `keep` 版本的 scorecard 对比,而不是与最初 baseline 对比。
6. **版本双标识**:scorecard 的 `skill_version` 记内容哈希,`meta.json` 同时记 plane 仓库 commit hash;两者必须能互相对上。

## 分阶段检查点复评

耗时评估允许复用已验证的上游阶段，但必须保证因果边界清晰：

1. 每个优化批次在运行前声明**最早受影响阶段**：`requirements`、`model`、`apply`、`implement`、`verify`。
2. 从该阶段之前、由上一个 `keep` 版本产出的只读父检查点恢复；该阶段及其全部下游阶段必须重新运行。
3. 阶段检查点至少保存：父检查点 ID、template commit、Skill 内容哈希、CLI 哈希、需求哈希、数据库引擎、阶段输出哈希和阶段耗时。恢复后使用新的项目目录与新的 MySQL database，禁止共用可变运行态。
4. 同一阶段的 A/B 批次必须从同一个父检查点分别派生；禁止把 A 的修复后输出作为 B 的输入，否则指标不可归因。
5. 上游规则变更会使所有下游检查点失效。例如修改 model authoring/validation 规则时，只能复用 `requirements` 检查点；修改 Handler 实现规则时可复用 `post-apply` 检查点。
6. 定期从零执行全链回归，验证分段复评没有隐藏跨阶段劣化；分段结果不得替代最终全链裁决。
7. 检查点恢复 run 的 driver 在 Agent 进程启动时同时记录外层阶段起点；Skill/TODO/契约重载属于被测阶段成本。若 Agent 的 `stages.json` 延迟开始、提前结束或与外层边界相差超过 5 秒，效率比较使用 driver 外层耗时，并把计时违约单列为测量缺陷。

| 最早受影响阶段 | 可复用的父检查点 | 必须重跑 |
|---|---|---|
| requirements | fresh requirements input | requirements 及以后全部阶段 |
| model | requirements-complete | model 及以后全部阶段 |
| apply | model-valid | apply 及以后全部阶段 |
| implement | post-apply/materialized | implement 及以后全部阶段 |
| verify | source-finalized | verify |

## OPTIMIZATION_LOG.md 行格式

| 批次 | commit | 假设 | 跑过的评估 | 关键指标变化 | verdict |
|---|---|---|---|---|---|
