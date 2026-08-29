Continue the frozen S1 ticketing evaluation from the existing project and session. Use the installed domainry-builder-v1 Skill and its Opt44 CLI. This is one bounded source-repair node only.

Hard boundaries:
- The active Plane must be exactly v0.18.0-opt44.d988302 at http://127.0.0.1:8283. Confirm it with `domainry-cli version --json` before mutation.
- Keep the local MySQL database and managed Runtime intact. Do not stop/restart Runtime, do not run the semantic canary, acceptance prepare/run/check, project verify, or project package in this node.
- Do not modify requirements, PRD, backend/model, generated source, Skill, golden, scorer, frontend, Runtime data, or evaluation harness outside this project.
- Do not add the two extra variables to the notification model. The authored event contract is frozen and only declares `ticket_title`.
- Preserve all existing business behavior and tests. Do not broaden the repair.

Procedure:
1. Record `.domainry/development/stages.json` stage `source_repair_opt44` with epoch seconds and the existing exact field shape.
2. Run the Opt44 `project check --json --scope actions` exactly once before repair and persist its bounded JSON result under `.domainry/development/`. It must report exactly two `project.action_notification_variable_undeclared` diagnostics for `ticket.assign` / `ticket.assigned`: `assigned_by_user_id` and `assignee_id`, both at `backend/actions/ticketing/ticket_assign.go`. If the diagnostic set differs, record one exact finding and stop.
3. Repair only `backend/actions/ticketing/ticket_assign.go` by removing the two undeclared notification variables. Keep the declared required `ticket_title`, recipients, subject identity/version, dedupe, group, alert, occurrence time, action mutation, and all other semantics unchanged. Update the project-owned focused test only if it explicitly asserts the invalid three-variable shape; prefer no test change when unnecessary.
4. Run `gofmt` on modified Go files, the focused `go test ./actions/ticketing`, and exactly one post-repair `project check --json --scope actions`. Require state `valid` and zero diagnostics.
5. Run source finalize exactly once through the current project development Gate runner, binding the correct identities and preserving the existing session. Do not manually forge a receipt. Confirm the new source-finalization receipt and source SHA are current.
6. Resolve `project.ticket_assign_notification_variables_not_declared` with evidence from the pre-repair diagnostic, post-repair valid check, focused test, and new source-finalization receipt. Do not resolve the two older canary findings yet.
7. End the stage, keep the managed Runtime running and healthy even though its cohort is expected to become stale relative to the new source, and stop before verify/package/runtime restart.

Report active seconds, excluded tool-wait seconds if any, exact commands/counts, changed paths, pre/post check results, test result, new source SHA, source-finalization receipt SHA, Gate/finding status, and Runtime health/cohort state. Do not claim the canary or acceptance passed.
