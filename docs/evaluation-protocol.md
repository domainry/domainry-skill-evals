# Skill evaluation protocol

This protocol belongs to the evaluator. It must not be packaged with, linked from, or returned by the candidate Skill.

## Cohorts and rotation

Use two case roles:

- `calibration`: public, repeatable regression material. It may explain failures and supply generic positive/negative examples. Once inspected, it is never described as blind, holdout, or first-pass evidence.
- `holdout`: a pool of two or three frozen cases with different business nouns, record shapes, and topology from calibration while covering the same capability axes. Select one untouched case for a measured run. After its first run, permanently reclassify it as calibration and replenish the pool before the next claimed holdout run.

The holdout pool and its golden assets live in evaluator-controlled storage outside the candidate Skill. During Skill development, the delivery agent and Skill authors must not inspect an unused holdout, its expected resource keys, fixtures, oracle implementation, or scorer branches.

## Freeze manifest and two denominators

Before revealing the selected holdout PRD to the delivery agent, persist one immutable freeze manifest containing hashes and versions for the PRD, public semantic IDs, driver prompt, benchmark denominator, golden/oracle, fixture generator, scorer and outcome schema, installed Skill tree, packaged CLI, declared external service target, Runtime contract, model, and material run settings. Do not resolve any candidate or platform identity from a source checkout.

Keep two denominators distinct:

- `benchmark_denominator`: the pre-run semantic requirement/case set owned by the evaluator. It cannot be derived from the candidate delivery. A missing declaration is recorded as `not_emitted`; deleting or renaming a resource never removes the expected case.
- `runtime_denominator`: the CLI-generated exact set for the delivered model and Runtime cohort. It proves the emitted implementation surface and may diagnose extra or malformed coverage, but it cannot shrink or replace the benchmark denominator.

Both hashes and their explicit case-set reconciliation belong in every result. A run is invalid when either frozen evaluator input changes after the delivery agent starts. Repairing an oracle or fixture after the start creates a new run against a new freeze manifest; it never retroactively produces pass-at-1.

## Measured run and lineage

Use a new standalone Git project, fresh Agent session, frozen installed candidate package, and zero human clarification or repair. Capture every command/event needed to measure the first `model plan`, `apply model`, `apply finalize`, `verify`, and evaluator acceptance attempts; a `not_measurable` first-pass funnel is not strict holdout evidence. Golden assertions must actually execute, not merely finish setup.

Write the first run once to an immutable run directory containing the freeze manifest, raw event stream, complete exact-set results, scorer output, token/time accounting, and every failure. Never overwrite it. Later repairs use a separate `convergence` run with `parent_run_id`, changed component hashes, changed-case inventory, and a reference to the preserved first run. Convergence is never named pass-at-1.

Every benchmark case has exactly one typed outcome such as `passed`, `product_gap`, `model_error`, `runner_gap`, `platform_blocked`, `benchmark_defect`, `not_emitted`, or `not_executed`. Raw Runtime Results v2 and any evaluator/business-harness reconciliation remain separately available; an aggregate count never replaces either exact set. Only a `needs_business_harness` row may be replaced by that harness, and the replacement retains lineage to the original row.

## Reporting and invariants

Report cohorts separately:

- Calibration: denominator size and hash, pass/not-passed disposition counts, wall time, tool calls/tokens when available, and regressions relative to the prior candidate.
- Clean holdout: freeze-manifest identity, pass-at-1, benchmark/runtime denominator reconciliation, first-failure inventory, typed outcome counts, wall time, and intervention count. One case is one observation, not a generalization rate. If no untouched external holdout is available, state that pass-at-1 was not measured.

Never delete or rename cases to reduce a denominator; weaken evidence validators; change a frozen case, golden rule, fixture, or scorer during a run; convert a product, runner, or platform failure into `needs_business_harness`; pre-seed expected business identifiers; or claim a repaired rerun as the original attempt. Generic platform fixes require behavior and mutation tests whose vocabulary is not tied to calibration or holdout cases.
