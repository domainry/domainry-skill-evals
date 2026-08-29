# M1 Opt95 checkpoint continuation validation

Continue the existing M1 delivery session from its exact saved post-acceptance checkpoint. This is a timing and correctness validation of the installed universal Opt95 workflow, not a new implementation batch.

Frozen facts and boundaries:

- Use `gpt-5.6-sol` with high reasoning and the currently installed `domainry-builder-v1` Skill/CLI only.
- Installed version is `v2.4.0-7164462b`; Plane is healthy at `http://127.0.0.1:8283`.
- Use only the inherited local MySQL cohort. Never use SQLite and never print, inspect, serialize, or persist its DSN or password.
- Reuse the current managed Runtime at `127.0.0.1:19111`, current package, current database cohort, current model/source, and project-visible TODO/Gate session `01a02e52-413b-70f3-a458-0f5dc74cefcc`.
- Three independently executed formal acceptance result files already pass 111/111: `full-standard-01.json`, `full-standard-02.json`, and `full-standard-03.json`. Do not rerun business acceptance.
- Do not change requirements, domain truth, backend model, business source, tests, package, Runtime binary, Skill, CLI, Plane, acceptance denominator, or acceptance harness.
- Do not guess lineage from natural-language labels, mass-mark Gates N/A, weaken coverage, fabricate done, write ad-hoc migration/projection scripts, or read Gate CLI source.

Required route:

1. Read the installed Skill authority, resolve this project/session once, and verify the installed CLI version.
2. Enter the installed compact whole-project continuation route immediately. Do not reread the full development guide or upstream project artifacts after the compact route is selected.
3. Read only the persisted resume packet named by the small CLI envelope. Execute its exact CLI-owned deterministic migration/closure/status actions; do not issue per-Gate attach loops.
4. Reuse all current authoritative verification, package, managed Runtime, coverage, and three formal acceptance artifacts. Product command replay must remain zero unless the bounded plan proves a genuinely invalidated owner.
5. Reach terminal done only if the CLI-owned ledger, supersession-aware TODO projection, current identities, and three acceptance results prove it. Run the TODO checker at done, and prove repeated read-only status does not mutate the terminal state.
6. Keep the managed Runtime running and healthy.

Report exact wall time, CLI call count, failed call count, product commands rerun, before/after blockers, terminal Gate counts, TODO checker counts, final state, Runtime status, and concise authoritative evidence paths.
