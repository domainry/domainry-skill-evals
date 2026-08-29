Managed Runtime start + identity/health 节点已完成，Runtime 保持运行；未执行 acceptance、数据库查询或 semantic canary。

- Active：118 秒（`1787366477..1787366595`）
- 正式 start：1 次，exit 0，4317.731 ms
- 状态：`running` / `current` / `healthy=true`
- PID/地址：`10665`，`127.0.0.1:38285`
- 数据库：driver `mysql`，cohort `current`；敏感配置仅保存身份哈希，未读取或输出明文
- `/ready`：HTTP 200
- `/health`：匿名访问 HTTP 401；CLI status 自身报告 `health_status=200`

关键身份：

- Blueprint：`16b07de77c4fc6bcead801516ffdafdf96dfc58fb5fb05c7b51cc7ce509c16af`
- Source Gate：`7734f14beb89576707511722ccb2135994701bba7e049c07aa1f203652203e6e`
- Project source tree：`bd04bff8d875f01d093b1587e52fa35535808385594f7626ee8af71cdf22ae24`
- Runtime manifest：`163be30bb481b862fe80226a7585e3ca1d30ffd24d6d7e4938e47dfbbc6c27fc`
- Package manifest：`395d73506b4cf5a78badef4a80830993dfecab3c619200d5f1e497e16f735d6e`
- Binary：`62848c88bdeaa7dd7fec26f3c32c05ac3d19c52fcf8c8e99da604f798b1457a7`
- Database cohort identity：`61ade345acc870bd2e2c5c32931e0e9d2da4c3ea65b05d25425eb8d2272decf9`

Receipts：

- [Managed Runtime receipt](/Users/tiger/Projects/domainry-skill-evals/runs/s1-ticketing-opt36-mysql-generality-01/project/.domainry/builder/runtime/runtime-process.json)，文件 SHA `7ff5b4f0591a7e1282983f8f39b92e95fa4f57153c90c312a64932b4675e693d`
- [Start Gate receipt](/Users/tiger/Projects/domainry-skill-evals/runs/s1-ticketing-opt36-mysql-generality-01/project/.domainry/builder/evidence/development-gates/01a02708-65d5-7403-9014-b8f6177ff24b/verify_managed_runtime_starts_once_at_127_0_0_1_-20260822T024142577721Z.json)，SHA `9e1aa802d39dab7f3a82c38d64492aaa28c37d2222a2be0831a10945ea9c1eb1`

新增 start Gate 已 passed；更宽的 `Matching managed Runtime ... identities/sessions/data ready` Gate 仍为 pending。

发现一项通用 Gate 证据问题：Runtime start 被按 generic command 处理，Gate receipt 的 `proof` 为空，仅验证 exit code；MySQL、package、cohort 与 health 身份需从 managed receipt/status 另行核对，尚未形成 Gate 内结构化 bounded proof。