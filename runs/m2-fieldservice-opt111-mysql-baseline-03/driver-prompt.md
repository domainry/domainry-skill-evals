Use the currently installed `domainry-builder-v1` Skill and its packaged CLI to build this fresh project from `requirements.md` through the Skill's terminal `done` state.

This is a new isolated evaluation. Treat `requirements.md` as the only business input. Do not inspect parent directories, the evaluation repository, benchmark goldens, previous runs, prompts, scorecards, checkpoints, or historical implementations.

Run with `gpt-5.6-sol` and high reasoning. Use the installed Skill and CLI without modifying or reinstalling them. Use the active Plane at `http://127.0.0.1:8283`.

Use the inherited `DATABASE_DRIVER=mysql` and secret `DATABASE_DSN`, which target a fresh empty MySQL schema. Do not print or persist credentials and do not use another database. Use `127.0.0.1:19122` for the managed Runtime and leave the final matching Runtime healthy for independent evaluation.

There is no delivered frontend. Implement only the backend/model and project-owned source and tests required by `requirements.md`. Follow the current Skill's own workflow, commands, TODO, verification rules, and stopping conditions exactly. Diagnose and repair ordinary failures within this session. Do not weaken requirements, tests, authorization, data scope, transactions, idempotency, or observable behavior, and do not add benchmark-specific logic.

At the end, report the actual terminal state, Runtime address, non-secret database identity, TODO path, verification results, and any unresolved blocker. Do not inspect or calculate outer evaluator metrics.
