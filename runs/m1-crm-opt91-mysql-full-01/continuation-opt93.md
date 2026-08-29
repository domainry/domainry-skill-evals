# M1 Opt93 acceptance-only continuation

Continue the same M1 delivery session from its current acceptance checkpoint. The installed Domainry Skill/CLI and Plane now bind template commit `814533f979cdaddeb5befaed9944dd7dd0da2ab9`. This universal contract fix removes the inapp `notification_after_commit_once` case's inapplicable `worker_terminal` requirement while retaining `runtime_restart`, `durable_refetch`, HTTP, idempotency, persistence, and audit evidence. True durable-worker restart/resume cases remain strict.

Current facts:

- The managed M1 Runtime/package/database cohort is healthy and must be reused.
- `.domainry/development/acceptance-results/full-standard-01.json` currently has 111 passed rows, but its notification artifact was recorded against the previous denominator and contains a now-unrequired worker observation.
- Do not change requirements, backend model, business source, package, Runtime binary, template, Skill, or CLI.
- Do not rerun requirements/model/apply/implement/verify/package. This is an acceptance-contract-only continuation.
- Use only local MySQL from the inherited `DATABASE_DSN`; never SQLite.

Required sequence:

1. Verify the installed CLI full version and current managed Runtime/cohort.
2. Run one current-cohort `project acceptance prepare`, then `stale-report` for result 01.
3. Update the project-local business harness only as required to emit exactly the new notification evidence contract: retain real exact-package restart and post-restart durable refetch/once-only proof; do not emit `worker_terminal` for this case and do not fabricate resume facts.
4. Re-record only stale or `needs_business_harness` rows. Run the formal acceptance checker until result 01 passes exactly; use the packaged Recorder/ResultsFile and strict schemas.
5. Produce independent `full-standard-02.json` and `full-standard-03.json` samples from the same current Runtime cohort. For each: run the standard runner with parallelism 8, use the thin business harness only for typed `needs_business_harness` rows, and pass the formal checker. Do not copy result 01 rows or evidence hashes as a substitute for independent execution.
6. Keep the Runtime running and healthy. Close the acceptance stage and canonical TODO consistently only after all three formal checks pass. Finish with a concise factual terminal report containing counts, file paths, stage end time, installed version, package/runtime/database identities, and any declared gaps.

Efficiency constraints:

- Use the acceptance checkpoint; do not rediscover or reread whole upstream guides.
- Do not reopen model/source/package for an acceptance artifact issue.
- Do not add new hard blockers or broad compatibility paths.
- If a command wrapper fails before the product command runs, correct the wrapper and continue without treating it as a product failure.
