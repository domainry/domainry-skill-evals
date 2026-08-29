# M2 focused-test node baseline

This run continues the accepted Opt-06 implementation checkpoint and stops after focused Go tests. It uses the frozen `gpt-5.6-sol/high` Skill/CLI package in an isolated `CODEX_HOME` and a fresh local MySQL database. No SQLite, Runtime, semantic canary, `project verify`, package, acceptance, evaluator, golden, or scorer command ran.

The node passed only after two project-owned repair rounds. The first compile exposed 12 invalid status identifiers in six Handlers. Once compilation was repaired, all eight generated scaffold tests failed: six panicked on nil capabilities and all eight still asserted placeholder `*.not_implemented` errors. The final eight tests pass after nil-capability guards and expectation updates.

The green result is structurally weak: the eight tests only exercise zero-input fail-closed behavior. They do not exercise successful business behavior, mutations, transactions, authorization contrasts, idempotency, or MySQL persistence. This checkpoint is eligible as the latest focused-test process baseline, not as semantic acceptance evidence.

The largest measured efficiency issue is startup orchestration: 227 of 608 outer seconds elapsed before `verify.started`. Other avoidable work included repeated tests to recover suppressed/truncated diagnostics, eight isolated runs after package panics, two wrong-working-directory evidence attempts, and Gate reattachment after source identity changed.
