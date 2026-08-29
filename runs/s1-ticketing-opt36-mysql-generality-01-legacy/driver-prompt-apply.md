继续当前 S1 ticketing 评估，复用已经正式通过的 requirements/model Gate 和冻结的 `model-valid` 检查点。现在只执行 apply 节点：

- 先核对当前模型仍为 `state: valid`、Blueprint SHA 仍为 `16b07de77c4fc6bcead801516ffdafdf96dfc58fb5fb05c7b51cc7ce509c16af`；不得修改 requirements、PRD 或 `backend/model/*.json`。
- 在 `.domainry/development/stages.json` 实时开启 `apply.started`。
- 使用正式 `model apply`，固定 Plane `http://127.0.0.1:8283`、Product Surface `business_workspace`，选择稳定的 domain-qualified Go module path。
- 审查正式 apply receipt、delivery、materialization 和生成的 source gap/scaffold inventory；apply Gate 完整通过后写 `apply.ended`。
- 到 `post-apply` 检查点立即停止。不要实现 Handler，不要执行 project source prepare/check/finalize，不要运行 Go test、verify、package、Runtime 或 acceptance。

数据库约束保持不变：只允许后续使用本地 MySQL `domainry_s1_opt36_generality_01`，禁止 SQLite。最终只报告 apply 命令次数、结果身份、生成 inventory 和纯阶段耗时。
