# m2-fieldservice MySQL pre-test baseline

This is the latest staged baseline for the installed `domainry-builder-v1` content hash `e45461c80f2e`, using `gpt-5.6-sol` with `high` reasoning and the user-provided local MySQL server. It is a scope-steered convergence continuation of `m2-fieldservice-e45461c80f2e-mysql-01`, not a clean pass-at-1 run and not a complete m2 delivery result.

## Test boundary

The checkpoint stops after a clean static Action check and successful source finalization. No Go test, project verification, packaging, managed Runtime, acceptance runner, business harness, golden probe, or scorer was run. MySQL remained at zero tables because Runtime was never started; SQLite was not used.

## Stage assessment

- Requirements/domain truth: 15/15 evidence gates passed, first pass.
- Model: terminally valid, but not first pass. The principal convergence sequence was 9 issues, 60 issues, a report SQL path shape error, 6, 2, 1, then 0. Subsequent evidence-gate changes caused regressions, bringing the total to 15 validate calls: 10 failed and 5 passed.
- Plan: 2/2 passed.
- Apply: the single apply materialized the backend and then failed closed on ten generated Handler placeholders. `project source prepare` passed, but full release convergence was intentionally not completed. The Skill evidence ledger therefore still has 23/23 apply gates pending.
- Implement: 10/10 Handler bodies implemented. Static Action check failed first on a forbidden raw `ObjectKey`, then passed after repair. Source finalization passed first attempt with source tree SHA `5ec25f7d49f2ab4df163d7184a940cb5a4bced272f7fa9ce8b81828aea5bf82c`.

## Baseline interpretation

The pre-test checkpoint is valid as a convergence/efficiency baseline. It does not support claims about compilation, tests, Runtime behavior, MySQL persistence, authorization, acceptance denominator closure, golden correctness, or full delivery completion.
