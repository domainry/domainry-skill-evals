Continue the same S1 evaluation from the failed semantic-canary node only. Use the newly installed `domainry-builder-v1` v0.18.0-opt43.3ba8e34 from this CODEX_HOME and its exact CLI. Keep the managed Runtime at `127.0.0.1:38285` running against the current MySQL cohort.

Attempt 2 proved the Workforce/application lookup fix, reached the exact ticket, and received the exact unauthorized `403 backend.action.permission_denied`; all Inbox projections remained unchanged. The apparent ticket change was a tooling false positive: MySQL durable data and `updated_at` remained unchanged, while RuntimeClient intentionally injects a fresh top-level transport `request_id` from `X-Request-ID` into each successful JSON response. The prior harness hashed the complete HTTP payload.

Opt43 includes generic template commits `cef10527644b9edd0844a92a3786916753321577` and `3ba8e3429e815d4059655e4cbda4046806cb9c61`. The materialized Runtime client now exports generic `runtimeRecordDurableSnapshot(record)`, which projects only durable record fields and preserves business `data.request_id` while excluding top-level transport metadata.

Do exactly this bounded attempt 3:

1. Record `canary_retry_opt43.started` in `.domainry/development/stages.json` using epoch seconds.
2. Run the installed CLI `version --json`, then run `project materialize runtime-client` exactly once against `http://127.0.0.1:8283`. Do not run model/apply/source finalize/verify/package/runtime start/acceptance.
3. Confirm the materialized client exports and tests the generic durable snapshot helper.
4. Modify only `.domainry/development/s1-aj03-semantic-canary.mjs`: import `runtimeRecordDurableSnapshot` from the materialized client and make `ticketDigest(record)` hash `runtimeRecordDurableSnapshot(record)`. Preserve the Opt41 `listWorkforce` lookup and every existing deny, allowed Action, durable read-back, audit, target Inbox, non-recipient Inbox and replay assertion. Do not weaken any oracle or hard-code S1 fields into a new generic helper.
5. Run only no-side-effect syntax/import/static checks. Then execute Gate `apply.one_highest_risk_semantic_canary_passed_against_.42ca52ce` exactly once through the Opt43 Gate runner, bound to current source and runtime cohort.
6. If it passes, resolve both prior findings with the current passing observation and Gate receipt: `foundation.workforce_search_declared_target_empty` (fixed by typed application projection) and `runtime.denied_action_ticket_state_digest_changed` (reclassify as tooling false positive caused by hashing transport request_id; durable MySQL state did not change). If it fails, preserve the exact receipt/observation, add one precise owner-classified finding, and stop without another repair/retry.
7. Record `canary_retry_opt43.ended`. Keep Runtime running and healthy. Do not run full acceptance or any later node.

Report continuation active seconds, formal Gate duration, phase call counts/durations, Gate/observation SHA-256, whether the allowed business mutation and replay executed, Runtime health/MySQL cohort state, and pass or exact blocker. Never print credentials, tokens, DSN, or raw secret material.
