# M1 Opt94 checkpoint closure timing validation

Continue the existing M1 delivery session from its exact current post-acceptance checkpoint. This is a timing validation of the installed universal Opt94 workflow fixes, not a new implementation batch.

Frozen facts and boundaries:

- Use `gpt-5.6-sol` with high reasoning and the currently installed `domainry-builder-v1` Skill/CLI only.
- The installed CLI and Plane version is `v2.4.0-143d6a1b`; Plane is healthy at `http://127.0.0.1:8283`.
- Use only the inherited local MySQL cohort. Never use SQLite and never print, inspect, serialize, or persist its DSN or password.
- Reuse the current managed Runtime at `127.0.0.1:19111`, current package, current database cohort, current model/source, and the same project-visible TODO/Gate session `01a02e52-413b-70f3-a458-0f5dc74cefcc`.
- Three independently executed formal acceptance result files already pass 111/111: `full-standard-01.json`, `full-standard-02.json`, and `full-standard-03.json`. Do not rerun business acceptance merely to be safe.
- Do not change requirements, domain truth, backend model, business source, tests, package, Runtime binary, Skill, CLI, Plane, acceptance denominator, or acceptance harness.
- Do not mass-mark historical Gates `not_applicable`, weaken coverage, guess lineage from natural-language labels, fabricate `done`, or add a compatibility path.

Required sequence:

1. Load the current installed `SKILL.md` as required, resolve the current project once, and verify the installed CLI full version before any Builder command. Reuse the existing session rather than creating a new TODO.
2. Use the installed compact persisted Gate resume/status facility immediately. Read the packet path returned by its small stdout envelope; do not rediscover the project by rereading all upstream artifacts.
3. Reconcile the legacy repair rounds using only explicit, defensible lineage based on stage, protected machine metadata, and exact command receipt argv/cwd. Add stable `domainry:gate-key`, monotonic `domainry:generation`, and explicit `domainry:supersedes` to the current TODO where proven. Preserve history as `superseded`; never convert it to N/A.
4. Follow the CLI's bounded recovery plan. Reuse current authoritative checkpoints. Rerun only genuinely current invalidated commands, if any; do not reopen requirements/model/apply/implementation/verify/package/Runtime/acceptance when their current bound evidence remains valid.
5. Confirm all three existing acceptance results with the formal checker only if the recovery plan requires current closure evidence. Do not independently execute the full 111-case denominator again.
6. Reach exact terminal `done` only if the ledger, requirement/capability coverage, current Gate generations, TODO consistency, current Runtime cohort, and three acceptance results prove it. Otherwise report the remaining genuinely current blocker without hiding it.
7. Keep the managed Runtime running and healthy.

Efficiency and reporting:

- A recoverable failure is work to repair and continue in this same session; do not ask the caller to resume.
- Do not add hard workflow stops. Use the machine-generated earliest checkpoint and bounded next actions.
- Finish with current blocker counts before/after, superseded count, exact product commands rerun, terminal state, Runtime health, and concise paths to the resume packet and authoritative evidence.
