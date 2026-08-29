本轮 semantic canary 已 fail closed，并按要求停止；没有重跑、修复、执行第二场景或 acceptance。

- Gate：`apply.one_highest_risk_semantic_canary_passed_against_.42ca52ce`
- 正式执行次数：1
- 结果：`failed`，exit 1；Gate 耗时 658.5 ms
- 阻塞点：Foundation-owned Workforce search 返回 HTTP 200，但声明的 active target support agent 查询结果 `total=0`
- Finding：`foundation.workforce_search_declared_target_empty`，状态 `open`
- 未执行：ticket query、deny、`ticket.assign`、ticket/Inbox read-back、audit、replay
- 未附加 `runtime_record` evidence；Gate 保持真实失败状态

| 阶段 | 调用数 | 耗时 |
|---|---:|---:|
| auth | 6 | 514.691 ms |
| principal-context | 3 | 11.966 ms |
| setup | 1 | 4.989 ms |
| action | 0 | 0 |
| read-back | 0 | 0 |
| deny | 0 | 0 |
| replay | 0 | 0 |

身份与证据：

- Source：`7734f14b…03e6e`
- Runtime cohort：`1b06b0a1…92779`
- Runtime manifest：`163be30b…c27fc`
- Gate receipt SHA：`e863869d…45147`
- Observation SHA：`467c9fa3…d8aa0`
- [Gate receipt](/Users/tiger/Projects/domainry-skill-evals/runs/s1-ticketing-opt36-mysql-generality-01/project/.domainry/builder/evidence/development-gates/01a02708-65d5-7403-9014-b8f6177ff24b/apply_one_highest_risk_semantic_canary_passed_ag-20260822T032311951200Z.json)
- [Typed observation](/Users/tiger/Projects/domainry-skill-evals/runs/s1-ticketing-opt36-mysql-generality-01/project/.domainry/development/s1-aj03-semantic-canary-observation.json)

`canary.started=1787368571`、`canary.ended=1787369001`，纯 active 430 秒。Runtime 仍在 `127.0.0.1:38285` running/healthy；MySQL 与 Runtime cohort 均 current。凭据仅经安全进程内/0600 store 流转，证据中无敏感值。Gate/CLI 正确 fail closed，未发现新的通用 Skill/CLI 问题。