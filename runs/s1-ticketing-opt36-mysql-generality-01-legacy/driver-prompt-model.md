你已安装并必须使用当前 `domainry-builder-v1` Skill。请在当前独立 Git 项目中，根据 `requirements.md` 完成 S1 ticketing 项目的前两个节点：

1. requirements：完成需求澄清、领域决策与项目可见 development TODO；
2. model：完整 author `backend/model/*.json`，执行正式 model validate，直到模型状态为 valid。

到 `model-valid` 检查点立即停止。不要执行 model apply，不要实现源码，不要运行测试、package、Runtime 或 acceptance。

评估约束：

- 使用已安装 Skill 的正式 resolver、CLI 和契约；不得绕过 Skill 流程。
- Plane 固定为 `http://127.0.0.1:8283`，不得启动或替换 Plane。
- 数据库只允许本地 MySQL；后续 Runtime DSN 固定为 `root:123456@tcp(127.0.0.1:3306)/domainry_s1_opt36_generality_01?multiStatements=true&parseTime=true`，禁止 SQLite。
- 不得查看父目录、评估仓库、其他 benchmark、golden、scorer 或历史 run；`requirements.md` 是唯一业务需求输入。
- 不得修改 `requirements.md`。
- 从第一步开始实时维护 `.domainry/development/stages.json`。进入 requirements/model 时写 epoch `started`，离开时立即写 `ended`；只能记录实际经历的阶段。
- 保存所有正式 receipt/audit。模型一旦 valid 即冻结，不做无关重构。
- 最终只报告本节点结果、正式 validate 轨迹、检查点身份和阶段耗时，不声称后续节点已经完成。
