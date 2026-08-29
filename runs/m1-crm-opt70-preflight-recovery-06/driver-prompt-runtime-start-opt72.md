Use the installed `domainry-builder-v1` Skill and its packaged CLI from exact Application Delivery `v0.18.0-opt72.d9d0874`, template commit `d9d0874496adbbd89e90f59a8582f7b3b88d3530`, and Plane `http://127.0.0.1:8283`. Use `gpt-5.6-sol` with high reasoning.

This is only the M1 fresh-local-MySQL managed-Runtime startup/status node. The previous package session `01a02b5e-364a-7fe1-8d8b-cbb7cc1bbbee` has definitively ended. Start a brand-new session-owned light-batch TODO and fresh Gates. Freeze every accepted requirement/model/source/delivery/finalization/verification/package identity and all project-owned files.

The accepted package checkpoint is:

- package receipt identity `3bd62d3f3f480030def3c584dfb19e89870647f01a62162e3f4fa3babd60fbd0`;
- package receipt file SHA `d897087bf553ae1e6fdca35580c4d537ab15609a8b34c191e6dad4849bd44076`;
- signed package/manifest identity `a464d36e8cf470946463f394577553fcfd9ec60b47b2c60321eebe8a0f8bd622`;
- project-relative bundle `.domainry/builder/artifacts/packages/a464d36e8cf470946463f394577553fcfd9ec60b47b2c60321eebe8a0f8bd622`;
- Runtime binary SHA `822456f794372ad3a006d7b56686deb6a635149eb84efe3cec358d45018d44da`;
- verification receipt identity `c2bdefe3ba97ea17ad2b10e051f185e1ca18067948502f58e57749ae2c50e081`, `10/10` passed, zero failed/skipped;
- live delivery `sha256:4d249113d044b08698c733db486ebda84b1fa93859823922ea0ed0eafedbee64` and finalized source tree `fa63fcbc059050e4967f8b6e2d6482a2e5fb3b0ab38aff4fa1c1a68ee18311e2`.

The process environment already provides the user-authorized secret `MYSQL_PWD`, `DATABASE_DRIVER=mysql`, and `DATABASE_DSN` for the exact fresh schema `domainry_m1_opt72_runtime_01` on local MySQL `127.0.0.1:3306`. Never print, enumerate, serialize, or persist secret environment values or the DSN. SQLite is forbidden. The dedicated Runtime address is `127.0.0.1:19091` and has been checked free.

Follow the installed Skill's required whole-project/light-batch workflow without redoing accepted stages. First create exactly that fresh MySQL schema once with the local `mysql` client (`CREATE DATABASE` with `utf8mb4`); it was independently verified absent immediately before this session, so do not use `IF NOT EXISTS`, drop, truncate, reuse, or inspect any unrelated schema. If creation fails, report and stop. Then run exactly one fresh Gate-owned:

`domainry-cli runtime-process start --project <project> --bundle .domainry/builder/artifacts/packages/a464d36e8cf470946463f394577553fcfd9ec60b47b2c60321eebe8a0f8bd622 --address 127.0.0.1:19091`

After it succeeds, run exactly one separate fresh Gate-owned:

`domainry-cli runtime-process status --project <project>`

Stop after the matching v3 managed-process receipt is running/current/HTTP-healthy. Leave the managed Runtime running. Do not edit project-owned or generated files. Do not run model/capability/source/finalize/Go test/verify/package commands, semantic canary, acceptance prepare/run/check, evaluator, scorer, or cleanup. Never pass removed `--skip-dependency-resolution`.

If start or status fails, preserve and report complete bounded structured diagnostics and stop without retry or repair. Report exact wall/active time and model usage; command counts/durations; schema/cohort non-secret identity; new session/Gate/process receipt identities; PID/address/health/currentness; frozen checkpoint verification; remaining bounded gaps; and the exact next semantic-canary node. Do not claim canary, acceptance, or completion.
