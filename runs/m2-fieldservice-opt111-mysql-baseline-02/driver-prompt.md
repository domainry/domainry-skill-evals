Use the freshly installed `domainry-builder-v1` Skill and its packaged CLI to complete this fresh M2 field-service backend project end to end, from the sole business input `requirements.md` through the Skill's terminal `done` state.

Use the current Skill exactly as installed. Follow its actual five-stage workflow and project-visible TODO. Work continuously through ordinary diagnostics: diagnose and repair the named owner, rerun only invalidated checks, and continue until correctness and `done`. Do not introduce historical workflow stages, acceptance denominators, parallel ledgers, continuation routes, or commands that the current Skill does not define.

Environment and scope:

- Evaluation model is `gpt-5.6-sol` with high reasoning.
- Confirm the installed CLI and Plane version are `v0.0.111-local.20260824-business-flow-cases`; do not modify or reinstall the Skill, CLI, Plane, or Runtime framework.
- Use the inherited local MySQL connection only: `DATABASE_DRIVER=mysql`, with `DATABASE_DSN` targeting fresh empty schema `domainry_m2_opt111_baseline_02`. Never print or persist credentials and never fall back to SQLite.
- Use `127.0.0.1:19121` for the managed Runtime and leave the final matching Runtime healthy for independent evaluation.
- This project has no frontend source. Build the source-owned backend/model and project-owned Actions/tests required by `requirements.md`; do not create frontend code.
- `requirements.md` is the only business requirement input. Do not inspect the evaluation repository, benchmark golden material, scorer, old runs, scorecards, or historical solutions.
- Preserve the full required semantics: portal/business isolation, authorization and data scope, transactions, inventory concurrency/idempotency, workflow, scheduler, notifications, reporting/export, audit, pagination, and MySQL behavior.
- Do not add bypasses, weaker tests, broad administrative grants, project-specific hacks, compatibility layers, or reduced business coverage.

Run the current Skill's normal requirements, model, apply, source implementation/testing, verification, packaging, managed Runtime, and project-owned business-flow test workflow. Reach terminal `done` only when the TODO and current Skill checks prove it.

Finish with a concise factual report: version, Runtime address/PID, non-secret database identity, model/apply/source/test/verify/package outcomes, repairs, TODO path/state, and any remaining blocker. Do not calculate outer evaluator metrics.
