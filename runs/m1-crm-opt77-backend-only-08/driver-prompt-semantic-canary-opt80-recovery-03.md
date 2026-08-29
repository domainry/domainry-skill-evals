This is a staged cross-case evaluation of the installed `domainry-builder-v1` Skill using `gpt-5.6-sol/high`.

Use the installed Skill faithfully and read its `SKILL.md` completely before acting. Work only inside the current M1 project. Do not inspect the parent evaluation repository, benchmarks, golden files, scorer, evaluator harness, other runs, or unrelated historical sessions.

The accepted requirements/model, backend-only source, finalization, verification, package, and current managed Runtime are frozen. The Runtime is healthy on the fresh local MySQL cohort recorded in `.domainry/builder/runtime/runtime-process.json`; SQLite is forbidden. Do not start, stop, restart, or status the Runtime. Never print or persist the DSN/password outside the canonical Runtime-bound secret mechanisms.

Only the prior canary recovery session `m1-opt80-semantic-canary-02`, the accepted PRD authorization rows, and the canonical installed harness core are permitted recovery inputs. That Gate failed before any business mutation. Read-only evaluator evidence has now localized its generic HTTP 403 precisely: director Action-list, approval-list, and lead-detail requests all returned 200; the first sales-rep object-detail read in `durable_closure` returned 403. This is correct least-privilege behavior, not a role-binding defect. The accepted PRD explicitly states that customer has no business-role read grant and customer creation/linkage must be proved through formal persistence evidence. Do not add customer or approval read permissions, change the model, or weaken the oracle.

Your only objective is a second minimal recovery of the same single highest-risk J07/R07-R10/R13 semantic canary under fresh session ID `m1-opt80-semantic-canary-03`:

- invoke the default resolver exactly once and use its current light-batch TODO/Gate contract;
- copy the recovery-02 thin harness and preserve its canonical `Sessions` plus formal workforce context selection;
- correct only the evidence ownership boundary: use the director workforce session for approval/lead HTTP read-back; use the requester sales-rep session only for the denied Action and requester Inbox; prove customer nonexistence/creation/linkage through the canonical installed `AcceptanceDatabase.from_runtime_state` read-only MySQL path with an explicit in-memory PyMySQL DB-API connector;
- the database connector must consume the in-memory `DATABASE_DSN`, verify the Runtime cohort through canonical core, use parameterized read-only SELECTs, and never expose credentials/DSN. No INSERT/UPDATE/DELETE/DDL or direct ad-hoc database client is permitted;
- include the database customer row in the deterministic durable-closure hash used for denied unchanged, positive changed, replay unchanged, and terminal-conflict unchanged assertions;
- run exactly one real canary command through its fresh Gate and stop after that Gate result. On failure record the complete reachable failure inventory without repair/rerun. On success do not run acceptance prepare/run/check or broader acceptance.

Do not modify requirements, PRD, model, production source, generated source, verification, package, Runtime state, or database. Do not create frontend or Runtime Client SDK files. Do not claim whole-project completion.

Finish with outer/pure active duration, resolver/product/Gate counts, exact canary result, non-secret Runtime/cohort/upstream identities, and evidence paths. Never expose credentials, tokens, cookies, session secrets, password, or DSN.
