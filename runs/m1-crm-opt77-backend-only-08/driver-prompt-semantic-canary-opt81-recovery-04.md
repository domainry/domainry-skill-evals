This is a staged cross-case evaluation of the installed `domainry-builder-v1` Skill using `gpt-5.6-sol/high`.

Use the installed Skill faithfully and read its `SKILL.md` completely before acting. Work only inside the current M1 project. Do not inspect the parent evaluation repository, benchmarks, golden files, scorer, evaluator harness, other runs, or unrelated historical sessions.

The accepted requirements/model, backend-only source, finalization, verification, package, and current managed Runtime are frozen. The Runtime is healthy at `127.0.0.1:19095` on the current fresh local MySQL cohort. SQLite is forbidden. Do not start, stop, restart, or status the Runtime. Never print or persist the DSN/password outside canonical Runtime-bound secret mechanisms.

Opt81 is now the installed baseline. It fixes the generic plumbing blocker by making MySQL `AcceptanceDatabase.from_runtime_state(PROJECT_ROOT, state)` consume the Runtime's strict Go-style MySQL DSN through the core-owned lazy PyMySQL adapter; no connector callback or Agent-authored DSN parser is allowed.

Only the immediately preceding recovery session `m1-opt80-semantic-canary-03`, its result, and the installed Opt81 canonical core are permitted recovery inputs. Recovery-03 failed at database binding before any HTTP/session/business mutation solely because its project-local custom connector parsed the Go-style DSN as a URL. The accepted authorization/evidence ownership correction in that script remains valid: director HTTP reads approval/lead, requester is used only for denied Action and Inbox, customer persistence is captured through the canonical cohort-verified read-only database path.

Your only objective is the same single highest-risk J07/R07-R10/R13 canary under fresh session ID `m1-opt81-semantic-canary-04`:

- invoke the default resolver exactly once and use its light-batch TODO/Gate contract;
- copy recovery-03's thin harness, rebind its session/source path, switch `CORE_PATH` to the installed Opt81 core, delete the custom MySQL connector and its DSN parsing code/imports, and call `AcceptanceDatabase.from_runtime_state(PROJECT_ROOT, state)` with no callback;
- make no other journey, authorization, production, Runtime, or database change;
- run exactly one real canary command through its fresh Gate and stop after the first Gate result. On failure record the complete reachable failure inventory without repair/rerun. On success do not run acceptance prepare/run/check or broader acceptance.

The canary must retain formal workforce contexts, opaque action/target resolution, requester denied Action with unchanged state, director positive approval with approval/lead HTTP read-back and canonical MySQL customer creation/linkage, requester Inbox, idempotent replay unchanged, and second-director terminal conflict unchanged.

Do not modify requirements, PRD, model, production source, generated source, verification, package, Runtime state, or database. Do not create frontend or Runtime Client SDK files. Do not claim whole-project completion.

Finish with outer/pure active duration, resolver/product/Gate counts, exact canary result, non-secret Runtime/cohort/upstream identities, and evidence paths. Never expose credentials, tokens, cookies, session secrets, password, or DSN.
