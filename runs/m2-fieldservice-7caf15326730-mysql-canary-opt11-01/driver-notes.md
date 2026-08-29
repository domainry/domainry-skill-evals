# M2 Opt-11 downstream semantic-canary attempt

This run continued from the Opt-11 focused-test checkpoint and intentionally stopped before full acceptance. Its target was exactly one highest-risk semantic journey, J06 repair completion, using `gpt-5.6-sol/high` and a fresh local MySQL database.

The first turn spent 398 seconds and 3,014,544 input tokens before `project verify` reported one formatting check failure across four production Action files. No business behavior had failed. After one evaluator authorization, the same Agent session applied only `gofmt` to those four files and did not reload the resolver or development guide. Actions check, source finalize, focused Go test, project verify, and package then each passed once.

The single managed Runtime start failed during clean MySQL manifest provisioning. The composite index `idx_audit_event_record_cursor` exceeded MySQL's 3072-byte maximum key length (`Error 1071`, SQLSTATE `42000`). Runtime ended stopped and unhealthy. J06 was never invoked; authentication, setup, action, read-back, replay, conflict, restart, and acceptance commands are all absent. The failed bootstrap left 125 tables in the isolated database but did not create the target index. No project SQLite database exists.

Across both active turns, wall time was 824 seconds and input was 10,249,620 tokens, while all product commands together consumed only 20.859 seconds. This sample therefore exposes substantial downstream continuation-context overhead, but it is not timing-comparable as a baseline because it required an evaluator intervention and never reached the canary.

The immediate blocker is a Runtime/Foundation MySQL schema compatibility defect, not M2 business semantics. Fix it in `verdent-template`, republish or rebind the Runtime dependency if required, clear the isolated MySQL database, and resume from the package/Runtime node. Do not rerun requirements, model authoring, apply, implementation, or focused tests unless the repaired Runtime artifact changes those frozen inputs.

A precise scan for the actual DSN form found no credential leakage in the run artifacts. A prior broad scan for the literal password was a false positive caused by the loaded Skill reference text describing forbidden hard-coded credentials.
