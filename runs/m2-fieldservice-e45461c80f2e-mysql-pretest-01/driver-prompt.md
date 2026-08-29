Continue the current Domainry Builder session from its existing `implement` stage without rereading the Skill or repeating completed discovery/model work.

The evaluator has narrowed this continuation to a pre-test checkpoint:

- Complete all ten generated project-owned Action Handlers with real capability-backed implementations.
- Run the mandatory static `project check --json --scope actions` and repair it until clean.
- Run `project source finalize --json` and repair source-finalization defects until the current source finalizes cleanly.
- Preserve the inherited `DATABASE_DRIVER=mysql` and `DATABASE_DSN`; do not create or use SQLite.
- Do not run Go tests, `project verify`, `project package`, any Runtime process, any acceptance command, or any golden/evaluator probe.
- End the `implement` entry in `.domainry/development/stages.json` when source finalization succeeds. Do not create or enter `verify` or `acceptance` stages.
- Stop immediately after the truthful pre-test source-finalization checkpoint and report implemented Handler count, static-check result, finalization result, and remaining unexecuted phases. Do not claim full delivery `done`.
