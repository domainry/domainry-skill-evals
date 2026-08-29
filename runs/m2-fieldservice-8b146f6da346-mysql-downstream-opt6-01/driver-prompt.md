Use the installed `domainry-builder-v1` Skill to continue the frozen M2 field-service delivery from its accepted implementation checkpoint to its truthful downstream terminal state.

This is a continuation evaluation. Requirements, domain truth, capability discovery, model authoring, validation, planning, apply, materialization, Handler implementation, static Action checking, and source finalization are already completed and frozen upstream evidence. Do not redo those stages and do not modify `requirements.md`, `docs/backend-requirements-prd.md`, or `backend/model/*.json`.

Start from the current finalized source and complete only the downstream workflow:

1. start the `verify` stage timestamp immediately after resolving the installed Skill/CLI and the current session TODO;
2. run all required focused Go tests and repair any project-owned source or test defect they expose, re-running the static Action check and source finalization whenever source changes;
3. run the highest-risk semantic canary, then `project verify` and `project package` using the inherited MySQL environment;
4. start and keep the final managed Runtime healthy on a dedicated local port;
5. end `verify`, start `acceptance`, freeze the acceptance denominator, run the platform acceptance runner first, and add only the thin business assertions needed for runner-skipped cases using the installed `acceptance-harness-core.py`;
6. run acceptance check, close the exact denominator when possible, end `acceptance`, and report the truthful terminal state and every unresolved downstream defect.

If a downstream failure has a project-owned source/test/harness cause, repair it in this continuation and rerun only invalidated checks. Do not change the frozen model to make a failing test pass. If the blocker is Runtime/platform-owned or would require model evolution, stop with the precise failure classification and evidence instead of weakening an oracle or bypassing a gate.

Use the inherited fresh local MySQL environment for every test, package, Runtime, and acceptance command. Do not use or create SQLite. Do not print, rewrite, or persist the database DSN. The pinned local Domainry Plane is `http://127.0.0.1:8283`.

Maintain `.domainry/development/stages.json` in real time. Preserve the existing `implement` timestamps. Add epoch-second `started` and `ended` fields only for `verify` and `acceptance` when those stages are actually entered. Never reconstruct timestamps afterward.

Use fresh project-local identities/data and the formal Runtime Principal Context Resolver. Never construct Runtime-owned principal/profile/scope headers or query Runtime-owned identity tables. Keep the final managed Runtime running for independent post-delivery inspection.

`requirements.md` and the accepted `docs/backend-requirements-prd.md` are the only business-requirement inputs. Do not inspect the parent evaluation repository, any `benchmarks`, `golden`, `scorer`, historical run, framework source checkout, or hidden assertion. Do not modify the driver prompt, evaluator assets, installed Skill, or CLI. Do not ask for human clarification; preserve unresolved non-critical assumptions explicitly and stop on a truly critical unresolved decision.
