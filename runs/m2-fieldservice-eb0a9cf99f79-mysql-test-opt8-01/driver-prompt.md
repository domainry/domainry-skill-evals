Use the installed `domainry-builder-v1` Skill to continue the frozen M2 field-service delivery from its compile-valid, pre-test checkpoint through the focused-test node only.

This is a continuation evaluation. Requirements, domain truth, capability discovery, model authoring, validation, planning, apply, materialization, Handler implementation, and Action compile repair are frozen upstream evidence. Do not redo those stages and do not modify `requirements.md`, `docs/backend-requirements-prd.md`, `backend/model/*.json`, or production Action source.

The installed Skill adds a stale Action test-scaffold invariant that the upstream checkpoint predates. Complete only this node:

1. resolve the installed Skill/CLI and current session TODO without rereading unrelated capability references;
2. before any test command, run `project check --json --scope actions`; collect its complete bounded stale-scaffold diagnostic inventory, repair all project-owned test findings as one batch, rerun the check to `state:"valid"`, and run `project source finalize --json`;
3. record `verify.started` immediately before the first actual Go test command while preserving the existing `implement` timestamps;
4. run the complete required focused Go test set for the finalized backend source;
5. collect the full first-pass test failure inventory before repairing anything;
6. repair only project-owned test defects exposed by those tests, then rerun only invalidated focused tests and refresh `project check` plus `project source finalize` after every test-source change;
7. stop as soon as the focused-test set passes or a precisely classified non-project-owned blocker is proved.

Do not run a semantic canary, `project verify`, `project package`, any Runtime process, acceptance prepare/run/check, evaluator probe, golden, or scorer command. Do not end the `verify` stage because later verification nodes have not run. Report the pre-test scaffold-gate findings separately from first-pass test failures and final state, plus test command count, repair rounds, and truthful blocker ownership.

Use the inherited fresh local MySQL environment for every command. Do not use or create SQLite. Do not print, rewrite, or persist the database DSN. The pinned local Domainry Plane is `http://127.0.0.1:8283`, but no Plane mutation is expected in this test-only node.

`requirements.md` and the accepted `docs/backend-requirements-prd.md` are the only business-requirement inputs. Do not inspect the parent evaluation repository, any `benchmarks`, `golden`, `scorer`, historical run, framework source checkout, or hidden assertion. Do not modify this driver prompt, evaluator assets, installed Skill, or CLI. Do not ask for human clarification.
