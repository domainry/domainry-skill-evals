未能到达目标检查点，已按 fail-closed 停止：

- Opt37 身份：`v0.18.0-opt37.8ded6af`，Plane 正确。
- Opt37 check：底层 exit `0`、stderr 为空；Gate 因实际 contract 不在 supported set 中失败，`proof={}`。
- Receipt：`.domainry/builder/evidence/development-gates/01a02708-65d5-7403-9014-b8f6177ff24b/apply_every_implemented_handler_s_generated_plac-20260822T020202433138Z.json`
- 未执行 static Gate、finalize 或 Go test；`implement.ended` 未写。
- 已记录历史轨迹、1 次 evaluator correction，以及暂停：
  - `1787363160..1787364081`：921 秒
  - 第二段暂停始于 `1787364162`
- 当前纯 implement active time：470 秒。

需修正 Opt37 runner/CLI 的 project-check contract 一致性后继续。