Use the installed `domainry-builder-v1` Skill and exact packaged CLI `v0.18.0-opt72.d9d0874` with `gpt-5.6-sol` / high. This is a compact recovery from the immediately preceding pre-execution Gate error, not a whole-project restart.

Previous session `01a02b66-07d2-7330-94e2-2dba95d68266` ended. Its start Gate was rejected before `domainry-cli` ran because the Agent omitted `--bind source`; actual Runtime start/status counts were `0/0`, no process receipt exists, and `127.0.0.1:19091` is free. The one authorized schema `domainry_m1_opt72_runtime_01` exists and was independently verified to contain exactly zero tables. It remains the fresh, unconsumed cohort for this recovery. Do not create, drop, truncate, recreate, or inspect any database/schema/table. The process environment already provides secret `DATABASE_DRIVER=mysql` and `DATABASE_DSN`; never print/enumerate/persist them. SQLite is forbidden.

Start one new session-owned light-batch TODO with exactly two fresh verify Gates. Freeze all upstream files and these identities:

- package receipt identity `3bd62d3f3f480030def3c584dfb19e89870647f01a62162e3f4fa3babd60fbd0`;
- package/manifest identity `a464d36e8cf470946463f394577553fcfd9ec60b47b2c60321eebe8a0f8bd622`;
- bundle `.domainry/builder/artifacts/packages/a464d36e8cf470946463f394577553fcfd9ec60b47b2c60321eebe8a0f8bd622`;
- Runtime binary `822456f794372ad3a006d7b56686deb6a635149eb84efe3cec358d45018d44da`;
- verification receipt `c2bdefe3ba97ea17ad2b10e051f185e1ca18067948502f58e57749ae2c50e081` (`10/10`);
- delivery `sha256:4d249113d044b08698c733db486ebda84b1fa93859823922ea0ed0eafedbee64`;
- finalized source tree `fa63fcbc059050e4967f8b6e2d6482a2e5fb3b0ab38aff4fa1c1a68ee18311e2`.

The exact recovery recipe is already supplied; do not inspect `domainry-development-gates.py` source or search historical TODOs to rediscover it. Resolve the session once, create/sync/list the minimal TODO, and invoke exactly:

1. `domainry-development-gates.py --project <project> --session-id <new-session> run --gate-id <new-start-gate> --bind source -- domainry-cli runtime-process start --project <project> --bundle .domainry/builder/artifacts/packages/a464d36e8cf470946463f394577553fcfd9ec60b47b2c60321eebe8a0f8bd622 --address 127.0.0.1:19091`
2. If start passes, `domainry-development-gates.py --project <project> --session-id <new-session> run --gate-id <new-status-gate> --bind source -- domainry-cli runtime-process status --project <project>`

Each product command must execute exactly once, with no retry. Stop after the matching v3 managed-process receipt is running/current/HTTP-healthy and leave Runtime running. Do not run model/capability/source/finalize/test/verify/package, semantic canary, acceptance, evaluator, scorer, or cleanup. Never pass removed `--skip-dependency-resolution`.

Report exact outer/active time and model usage; command counts/durations; non-secret cohort identity; new session/Gate/process receipt identities; PID/address/health/currentness; frozen checkpoint proof; remaining gaps; and exact next semantic-canary node. If either Gate fails, preserve bounded diagnostics and stop.
