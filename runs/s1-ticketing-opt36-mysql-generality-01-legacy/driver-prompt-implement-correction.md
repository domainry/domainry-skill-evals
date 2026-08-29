继续 implementation 节点。上一轮由 Driver 中止，因为正式 Gate runner 对失败子命令只保存 stdout/stderr 的 bytes/hash，不保存可读诊断，Agent 已连续三次无法获得真实错误并开始猜修；这属于 template tooling 证据缺陷，本 run 记录 1 次 evaluator correction，不归因业务实现。

Driver 对同一当前 source 做了只读 `project check --json --scope actions`，完整唯一诊断如下：

```json
{
  "state": "invalid",
  "issue_count": 1,
  "diagnostics": [
    {
      "code": "project.action_notification_variable_required",
      "message": "Action ticket.assign Dispatch for notification event ticket.assigned must include required Variables key ticket_title",
      "path": "backend/actions/ticketing/ticket_assign.go",
      "line": 67,
      "action": "ticket.assign",
      "event": "ticket.assigned",
      "variable": "ticket_title"
    }
  ]
}
```

请只修复这个完整诊断批：在 `AssignNotificationIntent` 中用 generated typed `AssignNotificationVariable` 传入 `ticket_title=locked.Title`（或等价的当前 ticket 标题）。保留已做的 capability receipt 校验；同步更新 canonical test 对通知变量的断言。随后通过同一个 Gate 重跑正式 check，继续 source finalize、conditional-mutation 静态检查与 focused Go test，最终仍停在 `source-finalized + focused-test-passed`，不要进入 verify/Runtime/acceptance。记录 check 轨迹和这次 evaluator correction。
