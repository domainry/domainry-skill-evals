This is a staged cross-case evaluation of the installed `domainry-builder-v1` Skill using `gpt-5.6-sol/high`.

Use the installed Skill faithfully and read its `SKILL.md` completely before acting. Work only inside the current M1 project. Do not inspect the parent evaluation repository, benchmarks, golden files, scorer, evaluator harness, other runs, or unrelated historical sessions.

The accepted requirements/model, backend-only source, finalization, verification, package, and current managed Runtime are frozen. The Runtime is healthy at `127.0.0.1:19095` on the current fresh local MySQL cohort. SQLite is forbidden. Do not start, stop, restart, or status the Runtime. Never print or persist the DSN/password outside canonical Runtime-bound secret mechanisms.

Opt82 is now the installed baseline. It fixes the generic external cohort blocker by making canonical MySQL/PostgreSQL acceptance binding derive the same identity as Builder: contract + driver + receipt DSN identity + database marker identity. No connector callback, Agent-authored DSN parser, direct marker-to-receipt comparison, compatibility path, or fallback is allowed.

Only the immediately preceding recovery session `m1-opt81-semantic-canary-04`, its result, its thin harness, and the installed Opt82 canonical core are permitted recovery inputs. Recovery-04 failed at `runtime_and_database_binding` before any HTTP/session/business mutation solely because Opt81 compared the database marker directly to the derived Runtime receipt identity. Its accepted authorization/evidence ownership remains unchanged: director HTTP reads approval/lead, requester is used only for denied Action and Inbox, and customer persistence is captured through the canonical cohort-verified read-only database path.

Your only objective is the same single highest-risk J07/R07-R10/R13 canary under fresh session ID `m1-opt82-semantic-canary-05`:

- invoke the default resolver exactly once and use its light-batch TODO/Gate contract;
- copy recovery-04's thin harness, rebind only its session/source path and `CORE_PATH` to the installed Opt82 core; do not redesign the journey or add any custom connector/DSN parsing;
- make no other journey, authorization, production, Runtime, or database change;
- run exactly one real canary command through its fresh Gate and stop after the first Gate result. On failure record the complete reachable failure inventory without repair/rerun. On success do not run acceptance prepare/run/check or broader acceptance.

The canary must retain formal workforce contexts, opaque action/target resolution, requester denied Action with unchanged state, director positive approval with approval/lead HTTP read-back and canonical MySQL customer creation/linkage, requester Inbox, idempotent replay unchanged, and second-director terminal conflict unchanged.

Do not modify requirements, PRD, model, production source, generated source, verification, package, Runtime state, or database outside the one authorized canary transaction. Do not create frontend or Runtime Client SDK files. Do not claim whole-project completion.

Finish with outer/pure active duration, resolver/product/Gate counts, exact canary result, non-secret Runtime/cohort/upstream identities, and evidence paths. Never expose credentials, tokens, cookies, session secrets, password, or DSN.
