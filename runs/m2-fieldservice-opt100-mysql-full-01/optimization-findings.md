# Opt100 M2 whole-flow optimization findings

This run is invalid as a timing baseline because the shared Skill/CLI/Plane changed from Opt100 to Opt104 while the Agent was running. Its pre-drift and command-lineage evidence remains useful for generic optimization.

## Measured orchestration symptoms

- Before invalidation the single Agent produced 44 command exits with code 2, including 23 `run`, 6 `attach`, 2 `resume`, 2 `init-post-apply-continuation`, and repeated profile/finalization attempts.
- The broad source-finalization TODO label also contained `project check`. `command_kind()` tested the generic project-check substring before `is_source_finalization_gate()`, so a legitimate `project source finalize` command was rejected until the Agent invented an unambiguous duplicate label.
- `validate_gate_dependencies()` selected the first active source-finalization Gate with `next(...)`. After normal source repair/evolution generations, that first Gate was superseded while a later finalization Gate was current and passed. Cross-module tests were rejected repeatedly until the Agent rebound the old lineage.
- The Agent repeatedly attempted generic apply Gates before discovering the packaged post-apply profile. The normal resolver/resume packet did not provide one directly runnable canonical `next_argv` that initialized and executed the authoritative post-apply actions-check/finalize/focused-test chain.
- The machine profile should own the verified `domainry_domain_sdk_<hash>` build tag. A bare `go test ./...` predictably hit the generated composition build guard; the Agent had to discover the build target manually.
- Opt101 added atomic stage transitions, but Opt100 required several close/open command pairs and produced unallocated timing gaps. Future reruns must use the current atomic stage-transition contract.

## Required generic fixes

1. Prefer declared `gate.kind` and exact source-finalization recognition before substring-based `project check` routing. Add a regression where one finalization label mentions a preceding project check and the only accepted command is `project source finalize`.
2. For backend compile/test dependencies, accept the current passed finalization generation selected by effective status and source identity; never choose the first insertion-order candidate. Add old-passed→superseded plus new-current-passed and stale-new-generation negative tests.
3. Make resolver/reconcile return one executable canonical continuation command for fresh post-apply source preparation and every invalidated repair generation. No Agent-authored duplicate Gate labels or manual ledger rebinding should be necessary.
4. Make the post-apply focused/full-module profile derive the current generated composition build tag itself and emit the exact bounded Go test argv.
5. Run anonymous vocabulary regressions and the complete Builder release gate. Do not encode M2 nouns or paths.

## Deployment boundary

Implement in the saved `verdent-template` project only after the active Opt105 task finishes. The same independent task must remove/reinstall the Skill and restart exactly one Plane instance on `127.0.0.1:8283`. Do not deploy while a frozen evaluator run is active.
