# m2-fieldservice model-stage optimization 02

This run evaluated template commit `8932b2e4e8cb3e0b752fa43fd38072083d3cbc0f` from the immutable `requirements-complete` checkpoint. It did not rerun requirements and stopped after a valid model plus plan. A fresh empty MySQL database was supplied; no SQLite persistence, apply, implementation, tests, Runtime, acceptance, probe, or scorer was used.

## Outcome

The strict nested-shape and bidirectional-ownership card removed every targeted class from opt-01's 30-diagnostic first batch: Identity menu/role-menu shapes and bindings, numeric `minimum`, object-valued report metrics, scheduler relation-target reads, export grant closure, unsupported export-control fields, and orphan export Action behavior ownership all disappeared.

The next contract layer surfaced instead:

1. Loader: one `model.report_sql_path_invalid` because Report values omitted their own `key`.
2. First aggregate Blueprint validation: six diagnostics sharing two Report roots—`join_cardinalities[]` uses `alias`, not `left_alias`/`right_alias`, and literal SQL `LIMIT` must be at most 10,000.
3. Batched repair: validation passed with zero diagnostics; plan passed with 30 creates and no updates/deletes.

Primary authoring validation therefore converged `1 loader → 6 aggregate → 0` in three calls. The evidence gate reran one valid validation and one valid plan, making the effective totals four validate and two plan calls.

## Timing audit

The Agent process began at epoch 1787285441, but the Agent intentionally read Skill/model contracts before starting `stages.json` at 1787285747. That excluded 306 seconds of real model-stage setup and violated the driver prompt's first step. The reported model time is 1093s; the comparable driver-observed process-start-to-model-end time is 1399s, versus opt-01's 1095s. This run therefore regressed 304s (27.8%) on the comparable boundary.

Future checkpoint runs use a driver outer timer from Agent process launch. Skill/TODO/contract reload is part of the resumed stage, and a delayed Agent timestamp cannot override it.

## Verdict

`rework`. The direction is strongly supported because the target diagnostic family is gone, but the numeric target (first full aggregate diagnostics ≤5) missed by one, effective validate calls rose from 3 to 4, and adjusted time regressed. The next single-hypothesis batch should publish the exact Report value-key, `join_cardinalities.alias`, and literal `LIMIT <= 10000` contract, then rerun independently from the same `requirements-complete` parent—not from this repaired model output.
