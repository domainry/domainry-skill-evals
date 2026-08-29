继续当前 S1 ticketing 评估，复用同一会话和已保存的 post-materialization 检查点。

Driver 对阶段边界的定义：前一轮正式 `model apply` 已完成发布与物化，并只因新生成的 `ticket.assign` fail-closed placeholder 在内置 source finalization 处停止；这是预期的 source implementation handoff，不是模型/物化失败。请保留失败 receipt 和 Gate 事实，不把 pipeline 伪造为成功；但可将 `.domainry/development/stages.json` 的 `apply.ended` 记为上一轮真实 stop epoch `1787362643`，随后实时开启 `implement.started`。

本轮仅完成 implementation/focused-test 节点：

1. 使用正式 `project source prepare` 一次生成并原子持久化完整 implementation packet；只使用该 packet 和 generated typed capabilities，不逐 Action 反复查询大 context。
2. 实现唯一 project-owned Handler `ticket.assign` 及其 canonical focused test：主管分派任一客服；原子更新 assignee；带真实 conditional mutation；同一事务发布/dispatch `ticket.assigned` Inbox；幂等与稳定冲突/拒绝行为符合冻结 PRD/model。
3. 在任何 Go test 前先跑正式 `project check --scope actions`，修复完整诊断批；再运行正式 `project source finalize`。
4. source finalized 后，通过 Gate 首次执行精确 focused Go test；同时运行适用的 conditional-mutation 静态检查。若源码因修复变化，重新 check/finalize 后再测试。
5. 所有 implementation/focused-test Gate 通过后写 `implement.ended`，停在 `source-finalized + focused-test-passed` 检查点。

禁止修改 requirements、PRD、`backend/model/*.json`、generated source、Runtime manifest 或 receipt；禁止 verify、package、启动 Runtime、访问数据库或 acceptance。Plane 与 MySQL 约束保持不变。最终报告 packet 调用/大小、check/finalize/test 轨迹、源码身份和纯 implement 耗时。
