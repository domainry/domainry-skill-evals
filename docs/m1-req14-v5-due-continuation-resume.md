# M1 Req14 v5 due-continuation resume

## Authority and boundary

This is a convergence resume note, not baseline evidence. Use the derived v7 manifest
`runs/m1-crm-scheduler-run-route-resume-convergence-41-checkpoint-req14-due-continuation-v7/checkpoint.json`
(SHA-256 `f3d3e8c9d403a0d405a54937f30d15ee0baf4dbf85ba736eb0d76a8dc6eafd67`) with the original
v5 archive
`runs/m1-crm-scheduler-run-route-resume-convergence-41-checkpoint-managed-elapsed-time-verification-seam-gap-v5/checkpoint-project.tar.gz`.
Its frozen archive SHA-256 is
`4aec796c2809fddc88d9d18172029bc4e991140277b4cbcc23c76522cc17ecd9`; the companion
`checkpoint.json` SHA-256 is
`c1492f0104781818649209dce2ffcf5506fd795e950b8fb31adc45f320d46bcb`.
Do not edit either v5 artifact and do not restore the rejected item-28 tail. The v7 manifest is
an evaluator-only resume-boundary overlay; it reuses the v5 archive byte-for-byte and is
authoritative over the restored v5 Scheduler resume text. Its direct parent is the unchanged v6
manifest (SHA-256 `491d4c69cfbd0a4a2b4edb74507ea10cebefa2fb7a3a9b424d1d5a39dbafc41f`).

The v6 sentence "Do not run convergence42 or a from-zero M1 baseline" carried forward a pause
instruction from preparation of the checkpoint boundary. It was an evaluator orchestration
restriction, not a Req14 product requirement. Because the driver injects the resume rule into
the measured Agent's prompt unchanged, v7 makes the scope explicit: continue the current
convergence that the evaluator has started; the Agent must not launch nested evaluation runs
or a from-zero baseline itself. Every Req14 acceptance and prohibited-repair boundary is
preserved, and neither the v5 artifacts nor v6 manifest is modified.

The resume is limited to the logical Feature40 slice, its project-owned Handler code and
BF06. Preserve Features 00/10/20/30/50 and BF01-BF05/BF07-BF08 except for the smallest
generated or shared lead-field delta forced by the reviewed Feature40 model. If the active
authoring contract cannot attach the two Feature40-owned lead fields without broadening that
boundary, stop with the exact model diagnostic instead of changing unrelated features.

The v5 files being superseded start at these identities:

| Path | v5 SHA-256 | Disposition |
| --- | --- | --- |
| `backend/model/40-followup-reminder.json` | `287f9e286dd8472671832cc7d73db154a2c7e43914f28700c30715bee3ceced8` | replace scheduled scan with record due continuation |
| `backend/actions/crm/lead_scan_stale_contacted.go` | `64eebdfb33ae23c73d20c78764057fab4c80048da4b472e8f0ab96093cc079fe` | remove bulk scan/evaluation-time behavior; replace with per-record due Action |
| `backend/actions/crm/lead_advance.go` | `7607cfb822091fed6dfc07b8c4d565c72803e4207f63ae61bd3a698c17670c2b` | only add status timestamp and due set/clear semantics |
| `backend/actions/crm/lead_scan_stale_contacted_test.go` | `fd55faf89081c2b07d0b2f200730d5988cf2c19c244dfe021e52d6cca8ca5c1c` | replace scan tests with due calculation/idempotency/no-op tests |
| `backend/tests/businessflow/bf06_test.go` | `d4dddaddacb4c0026f9e92076d7902c474828fc251ce61f7ab029850aafab563` | replace blocked Scheduler test with ordinary record-timer journey |

Generated files are regenerated consequences, never hand-edited replacement scope.

## Feature40 model replacement

1. Add independent datetime fields `status_changed_at` and `next_followup_at` to lead. Do
   not use Runtime `updated_at` as the business clock.
2. Entering `contacted` writes `status_changed_at=now` and a Handler-calculated
   `next_followup_at`: the first deployment-timezone workday morning strictly more than seven
   elapsed days later. Leaving `contacted` clears `next_followup_at`.
3. Publish an enabled Workflow whose field-change/update trigger targets lead field
   `next_followup_at`. Its legal Graph V2 has non-empty unique node/edge IDs, valid edge
   endpoints, and connects `trigger → contract.condition{type=field_equals,field=status,
   value=contacted}` through the condition's `true` branch to `timer → action`. A false branch
   must not reach the timer, so clearing the due field on exit does not arm another timer.
4. Use the actual timer contract: `node.type="timer"`; a nested `node.contract.timer`
   containing non-empty `timer_key` and `purpose`,
   `source_field="next_followup_at"`, and `timezone="Asia/Shanghai"`.
   `next_followup_at` is already the exact instant, so
   do not add timer offset or business-calendar recalculation.
5. The action node invokes one internal per-record due Action. Delete the scheduled Workflow,
   Scheduler definition, bulk scan Action and every `evaluation_time` production input/grant.
   A standalone scheduled lead/follow-up Workflow is forbidden even when no Scheduler definition
   points at it; `evaluation_time` is forbidden across all production Actions and Workflows.
6. Keep the reminder record append-only with a lead relation, recipient and local reminder date.
   Declare an explicit composite unique over exactly `(lead relation, local reminder date)`;
   unrelated unique fields or `(lead, date, recipient)` do not enforce the required invariant.

## Handler replacement

The status-transition Handler owns business-calendar calculation. It atomically writes the
new status, `status_changed_at`, `next_followup_at` and audit on entry, and atomically clears
the due field with the exit transition and audit.

The due Action is record-scoped and bounded: lock/reload that lead; compare the timer's due
identity or generation with the current `next_followup_at`; no-op if it is stale or the current
status is not `contacted`; otherwise create the daily-deduped reminder and notification intent,
calculate the next workday morning, and conditionally update `next_followup_at`. The field
update is what triggers the next one-shot Workflow instance. Replay, racing timers and a
unique-key conflict must converge on the same reminder and next due rather than duplicate an
effect.

Unit tests cover Friday/weekend rollover, a seven-day boundary that requires the following
workday morning, deployment timezone, entry set, exit clear, stale due identity, state-exit
no-op, replay and local-date uniqueness. They use injected clocks only inside project Handler
unit tests; production inputs and BF06 never accept `evaluation_time`.

## BF06 combined acceptance

Use A/B/C/D evidence exactly as defined in `docs/run-protocol.md`:

- A: ordinary `lead.advance` black-box execution enters contacted, then record reads prove the
  persisted `status_changed_at`, the Handler-calculated strictly-greater-than-seven-days next
  workday-morning `next_followup_at`, no immediate reminder, and the same due fields/no reminder
  after managed restart.
- B: evaluator-executed `./actions/crm` focused tests named
  `TestM1Req14DueCalculation`, `TestM1Req14EnterContactedPersistsDue`,
  `TestM1Req14ExitContactedClearsDue`,
  `TestM1Req14DueActionIdempotentContinuation`, and `TestM1Req14ExitedStateNoop` prove the
  project-owned business semantics. Evaluator-owned coverage requires these cases to execute
  non-zero project Handler statements, so empty tests fail. Handler unit tests may inject a clock;
  production contracts may not expose `evaluation_time`.
- C: evaluator-executed `./tests/recordtimer` tests named
  `TestM1Req14RuntimeRecordTimerExactDue` and
  `TestM1Req14RuntimeRecordTimerRestartRecovery` use the actual Domainry Runtime/Workflow package
  with real now+short duration. The evaluator uses a file-only hermetic GOPROXY chain with the
  project delivery first and the host's read-only module download cache as fallback, plus
  `GOFLAGS=-mod=readonly` and the necessary SDK build tag; runs
  `go list -m -json github.com/domainry/domainry-runtime`; rejects Main, Replace, a module path
  inside the project tree, or missing version/checksums; matches the resolved version and proxy
  artifacts to `application-delivery-binding.json`; and requires non-zero coverage in the external
  Runtime record-timer packages. It also injects, runs and hashes an evaluator-owned Go probe that
  calls the external Runtime's public record-timer policy and asserts exact zero-offset source-field
  due preservation plus an enabled default global worker. Candidate source cannot replace that
  probe. Empty tests and blank imports therefore do not certify C. The
  tests prove persisted due, pre-due no-op, automatic global-worker resume and pre-due restart
  recovery. They are independent Runtime integration tests, not a shortened CRM workflow and not
  a CRM-only test Action.
- D: the manifest checker binds the production field-change/contacted-condition/timer/action
  graph to the A/B/C evidence.

The checker itself runs B/C, hashes their source and output, validates the exact case set, and
records project Handler coverage plus the Runtime dependency list, external module identity,
delivery binding, hermetic Go environment, Runtime record-timer coverage and evaluator-owned probe in
`bf06-evaluator-certificates.json`. Managed BF06 evidence
must not invent or echo internal timer IDs. Never mutate SQLite, backdate a live record, override
the global clock, manually resume a timer, or call Scheduler.

## Resume and measurement order

Restore the v5 archive through the v7 manifest, freeze a successor candidate, and run only the compatibility model plan/review and
Feature40 apply needed to regenerate the replacement packet. Then run focused Handler tests,
BF06 compile/tests, the project checker and the managed initial/restart verify required by that
successor convergence. Continue this evaluator-started convergence within the restored project;
the Agent must not launch another evaluation run or replay M1 from the beginning. Do not label
the resumed checkpoint result a baseline.

A formal baseline remains blocked until the relevant Plane/Runtime candidate is converged. It
must later start from zero in a new isolated run, finish with zero command/checker/business-flow
errors, and satisfy the full frozen M01-M19 denominator in one clean run.

## Evaluator-side verification recorded for this change

- v7 overlay: `python3 -m pytest -q tests/test_m1_resume_checkpoint.py` → `3 passed`;
  the tests pin the v5/v6/v7 identities, verify byte-for-byte archive reuse, preserve all v6
  Req14 semantics, and inspect the actual injected prompt for the active continuation rule.
- `python3 -m pytest -q tests/test_run_m1_baseline.py tests/test_output_schemas.py` →
  `38 passed`.
- `python3 -m pytest -q` → `141 passed`.
- `python3 -m py_compile harness/run_m1_baseline.py benchmarks/m1-crm/golden-probe.py` →
  passed.
- v5 archive and checkpoint hashes were re-read after the evaluator edits and remained equal
  to the frozen values above.
