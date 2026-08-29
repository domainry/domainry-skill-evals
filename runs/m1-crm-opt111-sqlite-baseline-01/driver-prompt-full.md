Use the freshly installed `domainry-builder-v1` Skill and its packaged CLI to complete this fresh M1 CRM backend project end to end, from the sole business input `requirements.md` through exact terminal `done`.

This is the formal full-flow baseline for the frozen current candidate. Work continuously in one Agent session and one project-visible development TODO. Do not create subagents, pause for stage confirmation, or stop on an ordinary recoverable diagnostic. Diagnose and repair the named owner, rerun only invalidated checks, and continue.

Frozen environment and boundaries:

- Evaluation model is `gpt-5.6-sol` with high reasoning.
- Use the installed Skill/CLI and active Plane at `http://127.0.0.1:8283`. Record their exact versions before work. Do not modify or reinstall the Skill, CLI, Plane, evaluator, or Runtime framework.
- Use SQLite only. The process inherits `DATABASE_DRIVER=sqlite` and a project-local `DATABASE_DSN`. Never switch to MySQL/PostgreSQL or another database.
- Reserve `127.0.0.1:19120` for the managed Runtime. Leave the final matching Runtime running and healthy for independent verification.
- This project has no frontend. Build only the source-owned backend/model and project-owned Action/tests required by `requirements.md`; record frontend mutation scope as `backend_only`.
- Do not inspect the parent evaluation repository, benchmarks, golden files, scorer, evaluator harness, other runs, scorecards, or prior M1/M2/S1 solutions. `requirements.md` is the only business input.
- Do not add compatibility layers, bypasses, weaker oracles, broad administrative grants, reduced business-flow coverage, or project/case-specific framework logic.

Follow the installed Skill's exact five-stage workflow and its single TODO. Maintain real-time stage timing in `.domainry/development/stages.json` for `requirements`, `model`, `apply`, `verify`, and `done`; write boundaries as they happen, never backfill guesses. Complete requirements/domain truth, model, apply/source/focused tests, structural verification, package, managed Runtime, highest-risk canary, and all project-owned business-flow cases required by the accepted PRD. Do not invent the retired generic acceptance denominator/evidence workflow.

Finish with a concise factual report containing Skill/CLI/Plane identity, Runtime address/PID and non-secret SQLite identity, model/apply/source/verify/package/canary outcomes, complete business-flow pass counts, repair inventory, TODO path and exact terminal state, and measured stage timings. Do not inspect evaluation files or calculate outer metrics. Do not claim success unless the installed Skill consistency check proves terminal `done` and the final Runtime cohort is healthy/current.
