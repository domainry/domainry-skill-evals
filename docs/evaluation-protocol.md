# Skill evaluation protocol

This protocol belongs to the evaluator. It must not be packaged with, linked from, or returned by the candidate Skill.

## Cohorts and rotation

Use two case roles:

- `calibration`: public, repeatable regression material. It may explain failures and supply generic positive/negative examples. Once inspected, it is never described as blind, holdout, or first-pass evidence.
- `holdout`: a pool of two or three frozen cases with different business nouns, record shapes, and topology from calibration while covering the same capability axes. Select one untouched case for a measured run. After its first run, permanently reclassify it as calibration and replenish the pool before the next claimed holdout run.

The holdout pool and its golden assets live in evaluator-controlled storage outside the candidate Skill. During Skill development, the delivery agent and Skill authors must not inspect an unused holdout, its expected resource keys, fixtures, oracle implementation, or scorer branches.

## Freeze manifest and two denominators

Before revealing the selected holdout PRD to the delivery agent, persist one immutable freeze manifest containing hashes and versions for the PRD, public semantic IDs, driver prompt, benchmark denominator, golden/oracle, fixture generator, checker, scorer and outcome schema, installed Skill tree, packaged CLI, declared external service target, live Application Delivery manifest identity, Runtime module/version/closure, Runtime API and authoring contracts, project template/client/Skill-package identities, delivery trust identity, model, budgets, and material run settings. The service must be healthy before launch and the same public identity must be observed after the Agent exits. The manifest also records that the isolation root, project, isolated `CODEX_HOME`, Agent home, SQLite database, WAL and SHM did not exist before preparation. Do not resolve any candidate or platform identity from a source checkout.

Keep two denominators distinct:

- `benchmark_denominator`: the pre-run semantic requirement/case set owned by the evaluator. It cannot be derived from the candidate delivery. A missing declaration is recorded as `not_emitted`; deleting or renaming a resource never removes the expected case.
- `runtime_denominator`: the CLI-generated exact set for the delivered model and Runtime cohort. It proves the emitted implementation surface and may diagnose extra or malformed coverage, but it cannot shrink or replace the benchmark denominator.

Both hashes and their explicit case-set reconciliation belong in every result. A run is invalid when either frozen evaluator input changes after the delivery agent starts. Repairing an oracle or fixture after the start creates a new run against a new freeze manifest; it never retroactively produces pass-at-1.

## Measured run and lineage

Use a newly created standalone empty Git project, a new SQLite cohort and a fresh Agent session in an isolated `CODEX_HOME` containing only a byte-for-byte frozen candidate copy plus, while the Agent process is alive, one minimal `auth.json`. The driver never copies history, session/thread databases, memories, logs, state, queue, skills, or ordinary configuration from the caller. Authentication content, hashes and source paths are never persisted in evaluator artifacts, and the isolated credential is removed on every Agent exit path. The driver passes a minimal clean environment, never resumes or continues a prior session, and gives the Agent only requirements plus the driver-owned run policy. Golden/checker/scorer assets and historical runs are not passed through its prompt, command arguments, environment, or working directory. Capture every command/event needed to measure the first `model plan`, `apply model`, `apply finalize`, `verify`, and evaluator acceptance attempts; a `not_measurable` first-pass funnel is not strict holdout evidence. Golden assertions must actually execute, not merely finish setup.

Runtime business-flow evidence is extracted from the last captured verify result and archived before checker execution. A legacy external evidence file may fill a missing embedded result but cannot replace one; conflicting hashes invalidate the run. Missing or contract-invalid evidence remains a checker failure, and no driver layer may synthesize it.

The driver validates the installed candidate, isolated copy, and live service identity before launch and revalidates all three after exit. Any Skill tree, package identity, CLI, prompt, checker, scorer, candidate config, freeze-manifest, Application Delivery, or Runtime identity drift makes the run environment invalid and prevents checker execution. A baseline intentionally sealed at its first Agent command failure remains an environment-valid partial measurement only when those identities remain stable; it is not mislabeled as an isolation failure, though it is still ineligible for pass-at-1.

Write the first run once to an immutable run directory containing the freeze manifest, raw event stream, evaluator receive-time sidecar, event-derived stage timeline, complete exact-set results, scorer output, token/time accounting, and every failure. Never overwrite it. The stage timeline uses lifecycle and CLI event boundaries as primary evidence; project-reported stage timestamps are cross-validation only. Later repairs use a separate `convergence` run with `parent_run_id`, changed component hashes, changed-case inventory, and a reference to the preserved first run. An evaluator-owned checkpoint may restore project and `.domainry` project state only after its manifest, parent lineage, baseline ineligibility, and archive hash are frozen and verified. Git history, Agent state, and the Runtime database are never restored. Convergence is never named pass-at-1.

Capture `verify fixture` as a separate non-scoring diagnostic family. Its failures remain visible and attributable even when a later budget event determines the terminal state, but they never consume the final verify attempt, A4/C4 scoring counts, or retry budget. Record provider token usage as cumulative input plus output; cached input and reasoning output are reported subsets, not additional budget quantities.

The evaluator driver, not the delivery prompt, owns the measurement boundary. A
`baseline` stops immediately after the first Agent command exits non-zero, or
after a Domainry command reports an explicit failure state. This includes
auxiliary and read-only probes, not only the four scoring commands. It then seals the partial
event stream, completed CLI captures, checker attempt/result, scorecard and
failure facts. It must not let the same Agent repair that failure. Continuing
repairs requires an explicitly selected `convergence` run and a non-empty
`parent_run_id`.

Every run freezes positive wall-clock, total-token, CLI-invocation and CLI-retry
budgets when configured. The driver terminates the Agent process group when an
observable budget is exceeded, attempts evaluator acceptance, preserves all
available evidence, and records an explicit `budget_exhausted_*` terminal state.
Token enforcement consumes cumulative usage snapshots from the Agent event
stream; runners used with a token budget must stream those snapshots rather than
report usage only after an unbounded turn. An interrupted or budget-exhausted
run is incomplete evidence and is never eligible for pass-at-1.

Every benchmark case has exactly one typed outcome such as `passed`, `product_gap`, `model_error`, `runner_gap`, `platform_blocked`, `benchmark_defect`, `not_emitted`, or `not_executed`. Raw Runtime Results v2 and any evaluator/business-harness reconciliation remain separately available; an aggregate count never replaces either exact set. Only a `needs_business_harness` row may be replaced by that harness, and the replacement retains lineage to the original row.

## Reporting and invariants

Report cohorts separately:

- Calibration: denominator size and hash, pass/not-passed disposition counts, wall time, tool calls/tokens when available, and regressions relative to the prior candidate.
- Clean holdout: freeze-manifest identity, pass-at-1, benchmark/runtime denominator reconciliation, first-failure inventory, typed outcome counts, wall time, and intervention count. One case is one observation, not a generalization rate. If no untouched external holdout is available, state that pass-at-1 was not measured.

Never delete or rename cases to reduce a denominator; weaken evidence validators; change a frozen case, golden rule, fixture, or scorer during a run; convert a product, runner, or platform failure into `needs_business_harness`; pre-seed expected business identifiers; or claim a repaired rerun as the original attempt. Generic platform fixes require behavior and mutation tests whose vocabulary is not tied to calibration or holdout cases.
