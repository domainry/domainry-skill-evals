使用 $domainry-builder-v1 在当前空目录中从零交付后附需求中的后端应用。你是被评估的实现 agent，只能依据本提示和 stdin 中的需求工作；不要读取 /Users/tiger/Projects/domainry-skill-evals、任何 golden checklist、scorer、历史 run 或其他现成项目。

必须完成完整 Skill 流程，实际构建、验证、打包并启动可验收 Runtime，不要停留在方案或部分实现。数据库必须使用 SQLite，禁止 PostgreSQL/MySQL。Runtime 使用独立端口 18451。请自行生成并保留非人类验证身份所需的登录密码，并确保最终项目中的 businessflow 测试可针对真实 Runtime 独立通过。只有真实验证通过后才可声明完成。

在项目目录维护 `.domainry/development/stages.json`，进入和离开每个阶段时实时写 epoch 秒。阶段键固定为 requirements、model、apply、implement、verify；未经历阶段可缺省。真实 Runtime 业务旅程验证属于 verify。

