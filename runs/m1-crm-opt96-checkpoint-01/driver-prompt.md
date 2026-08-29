# M1 Opt96 cold legacy checkpoint validation

Continue the existing M1 delivery session from its exact saved post-acceptance legacy checkpoint. This is a timing and correctness validation of installed Opt96, not a new implementation batch.

Frozen boundaries:

- Use `gpt-5.6-sol` with high reasoning and the installed `domainry-builder-v1` Skill/CLI only.
- Installed version is `v2.4.0-55dabf78`; Plane is healthy at `http://127.0.0.1:8283`.
- Use only the inherited MySQL cohort. Never use SQLite and never print, inspect, persist, or serialize its DSN/password.
- Reuse managed Runtime `127.0.0.1:19111`, current package/database/model/source, and existing session `01a02e52-413b-70f3-a458-0f5dc74cefcc`.
- Existing `full-standard-01/02/03.json` were independently executed and formally pass 111/111. Do not rerun acceptance.
- Do not change requirements, model, source, tests, package, Runtime, Skill, CLI, Plane, denominator, harness, or business evidence.
- Do not inspect CLI source, read the full development guide, search TODO for commands, probe CLI help, write migration/projection scripts, issue per-Gate attach loops, guess labels, mass-mark N/A, or weaken coverage.

Required route:

1. Read the installed Skill authority and use its cold legacy compact continuation entry immediately. This saved checkpoint intentionally has no resume packet yet; invoke the single fixed CLI entry supplied by the Skill/resolver without filesystem discovery.
2. Read only the CLI-named compact packet and execute its exact fixed continuation commands. Let CLI reconstruct strict coverage and close the checkpoint from current verification/package/Runtime and all three formal acceptance result/check artifacts.
3. Product command replay and acceptance reruns must stay zero. If the CLI reports a genuinely missing authoritative input, report its exact structured diagnostic; do not reopen upstream stages.
4. Require terminal done, run the done-stage TODO checker, call read-only status twice, and prove those queries do not mutate ledger/TODO/closure bytes or mtime.
5. Keep Runtime 19111 running and healthy.

Report outer wall time, installed workflow CLI call count, shell command/failure count, product replay, before/after blocker and Gate counts, TODO checker counts, coverage counts, immutable-query proof, final state, Runtime status, and concise evidence paths.
