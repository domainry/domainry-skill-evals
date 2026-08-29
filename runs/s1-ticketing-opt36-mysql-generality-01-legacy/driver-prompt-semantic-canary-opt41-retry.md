Continue the existing S1 evaluation from the failed highest-risk semantic-canary node only. Use the newly installed `domainry-builder-v1` v0.18.0-opt41.731c603 from this CODEX_HOME and its exact CLI. The managed Runtime at `127.0.0.1:38285` must remain running; the database is the current MySQL cohort.

The prior single formal Gate run failed before any business mutation. Root cause is now proven and fixed generically in the published typed Runtime client at verdent-template commit `731c6031f46eb4a2fae0892381eaacd4649405f3`: `searchWorkforce` is the raw profile search (`worker_no`, `identity_user_id`, `organization_id`, formal search_fields/filters/sort), while `listWorkforce` is the application projection that supports account email/name, work_status and returns roles. The existing canary incorrectly used `searchWorkforce({search: declared.agentB.email, workStatus:'active'})`.

Do exactly this bounded repair/retry:

1. Record `canary_retry_opt41.started` in `.domainry/development/stages.json` with epoch seconds.
2. Run the installed CLI `version --json`, then materialize the Opt41 Runtime client into this project exactly once with the formal `project materialize runtime-client` command against `http://127.0.0.1:8283`. Do not run model/apply/source finalize/verify/package/runtime start or acceptance commands.
3. Confirm the materialized client exposes corrected raw-search types and still exposes application `listWorkforce`.
4. Modify only `.domainry/development/s1-aj03-semantic-canary.mjs`: replace the target-agent lookup with `listWorkforce({search: declared.agentB.email, workStatus:'active', page:1, pageSize:20})`. Preserve every other AJ03/R05 assertion, formal principal-context binding, bounded observation, secret handling, deny/action/read-back/audit/Inbox/replay checks. Do not weaken or skip any proof.
5. Run only no-side-effect syntax/import/static checks. Then execute the formal Gate `apply.one_highest_risk_semantic_canary_passed_against_.42ca52ce` exactly once through the Opt41 Gate runner, bound to current source and runtime cohort. This is retry attempt 2, not a new scenario.
6. If it passes, resolve finding `foundation.workforce_search_declared_target_empty` with the current observation and Gate receipt evidence. If it fails, preserve the exact failed Gate/observation, record one precise owner-classified finding and stop; do not repair or retry again in this turn.
7. Record `canary_retry_opt41.ended` in stages.json. Keep Runtime running and healthy. Do not run full acceptance or any later node.

Report active seconds for this continuation, formal Gate command duration, phase call counts/durations, Gate/observation SHA-256 identities, whether business mutation occurred, Runtime health/MySQL cohort state, and the exact next blocker or pass result. Never print credentials/tokens/DSN.
