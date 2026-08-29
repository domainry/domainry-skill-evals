Use the installed `domainry-builder-v1` Skill to continue the frozen M2 field-service delivery from its accepted implementation checkpoint through the focused-test node only.

This is a continuation evaluation. Requirements, domain truth, capability discovery, model authoring, validation, planning, apply, materialization, Handler implementation, static Action checking, and source finalization are completed and frozen upstream evidence. Do not redo those stages and do not modify `requirements.md`, `docs/backend-requirements-prd.md`, or `backend/model/*.json`.

Complete only this node:

1. resolve the installed Skill/CLI and current session TODO;
2. record `verify.started` immediately before the first test command while preserving the existing `implement` timestamps;
3. run the complete required focused Go test set for the finalized backend source;
4. collect the full first-pass failure inventory before repairing anything;
5. repair only project-owned source or test defects exposed by those tests, then rerun the invalidated focused tests; whenever source changes, rerun `project check --json --scope actions` and `project source finalize --json` before the final test pass;
6. stop as soon as the focused-test set passes or a precisely classified non-project-owned blocker is proved.

Do not run a semantic canary, `project verify`, `project package`, any Runtime process, acceptance prepare/run/check, evaluator probe, golden, or scorer command. Do not end the `verify` stage because later verification nodes have not run. Report the first-pass failures separately from the final state, plus test command count, repair rounds, and truthful blocker ownership.

Use the inherited fresh local MySQL environment for every command. Do not use or create SQLite. Do not print, rewrite, or persist the database DSN. The pinned local Domainry Plane is `http://127.0.0.1:8283`, but no Plane mutation is expected in this test-only node.

`requirements.md` and the accepted `docs/backend-requirements-prd.md` are the only business-requirement inputs. Do not inspect the parent evaluation repository, any `benchmarks`, `golden`, `scorer`, historical run, framework source checkout, or hidden assertion. Do not modify the driver prompt, evaluator assets, installed Skill, or CLI. Do not ask for human clarification.
