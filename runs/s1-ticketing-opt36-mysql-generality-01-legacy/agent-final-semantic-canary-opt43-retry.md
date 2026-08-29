Attempt 3 已 fail closed；没有重试或进入后续节点。

- Continuation active：59 秒（`1787371048..1787371107`）
- Opt43 materialization：1 次，receipt identity `4c097e01…ef163`
- Formal Gate：1 次，`failed`，耗时 355.287 ms
- Gate receipt SHA：`2f32e4a6…15b9e`
- Observation SHA：`8d112879…71d48`

| 阶段 | 调用数 | 耗时 |
|---|---:|---:|
| auth | 3 | 177.459 ms |
| principal-context | 3 | 14.159 ms |
| setup | 2 | 14.654 ms |
| deny | 5 | 20.083 ms |
| action | 1 | 9.020 ms |
| read-back | 4 | 17.637 ms |
| replay | 0 | 0 |

Opt43 durable snapshot 生效：denied 前后 ticket durable digest 完全相同，403 和所有 Inbox unchanged oracle 均通过。Workforce application lookup 也再次成功。

精确阻塞项为 project owner：

- 允许态 `ticket.assign` 被调用一次，但返回 HTTP 400 `backend.notification.action_intent_invalid`。
- Runtime manifest 仅声明通知变量 `ticket_title`；项目 Handler 还发送了未声明的 `assignee_id` 和 `assigned_by_user_id`。
- Finding：`project.ticket_assign_notification_variables_not_declared`，状态 `open`。
- 没有成功的 durable mutation 证据；未到达 action 后 read-back、audit、Inbox delivery 或 replay。

Runtime 保持 running/healthy；MySQL 与 Runtime cohort 均为 current。两个旧 finding 因整体 Gate 未通过，按指令未标记 resolved。

[Gate receipt](/Users/tiger/Projects/domainry-skill-evals/runs/s1-ticketing-opt36-mysql-generality-01/project/.domainry/builder/evidence/development-gates/01a02708-65d5-7403-9014-b8f6177ff24b/apply_one_highest_risk_semantic_canary_passed_ag-20260822T035819004672Z.json) · [Typed observation](/Users/tiger/Projects/domainry-skill-evals/runs/s1-ticketing-opt36-mysql-generality-01/project/.domainry/development/s1-aj03-semantic-canary-observation.json)