This is a staged cross-case evaluation of the installed `domainry-builder-v1` Opt83 Skill using `gpt-5.6-sol/high`.

Use the installed Skill faithfully and read its `SKILL.md` completely before acting. Work only inside the current M1 project. Do not inspect the parent evaluation repository, benchmarks, golden files, scorer, evaluator harness, other runs, or unrelated historical sessions.

The accepted requirements/model, backend-only source, finalization, verification, and package are frozen. A fresh managed Runtime is healthy at `127.0.0.1:19096` on a new empty-bootstrap local MySQL cohort. SQLite is forbidden. Do not start, stop, restart, or status the Runtime. The evaluator provides the exact managed Runtime `DATABASE_DRIVER`/`DATABASE_DSN` binding; never print, inspect, serialize, or persist it.

Opt83 is the installed baseline. Its canonical MySQL AcceptanceDatabase uses fresh committed read snapshots, so a pre-mutation SELECT must not hide a later Runtime HTTP transaction committed by another connection.

Only recovery-08's thin harness is a permitted recovery input. Recovery-08 already contains the accepted fixes: case-normalized information_schema mappings and formal optimistic-concurrency tokens. It reached and committed the positive Action on the archived prior cohort, proving approval approved, lead converted, and customer created; it failed only because the prior Opt82 MySQL acceptance connection remained on its pre-mutation REPEATABLE READ snapshot.

Your only objective is the same single J07/R07-R10/R13 canary under fresh session `m1-opt83-semantic-canary-09`:

- invoke the default resolver exactly once and use its light-batch TODO/Gate contract;
- copy recovery-08's thin harness, change only session/source path `m1-opt82-semantic-canary-08` to `m1-opt83-semantic-canary-09`, and change `CORE_PATH` from the installed Opt82 core to `/Users/tiger/.codex/isolated/opt83/skills/domainry-builder-v1/assets/acceptance-harness-core.py`;
- retain all journey logic, case normalization, concurrency tokens, formal workforce contexts, opaque identities, requester denial/unchanged state, director positive durable closure, Inbox, exact idempotent replay, and second-director current-token terminal conflict;
- run exactly one real canary command through one fresh Gate and stop after its first result. Do not repair/rerun on failure. On success do not run broad acceptance.

Do not modify requirements, PRD, model, production/generated source, verification, package, Runtime, or database outside the one authorized canary transaction. Do not create frontend or Runtime Client SDK files. Attach only the redacted result to administrative stop/report closures.

Finish with exact canary result, reachable inventory, counts, pure active/Gate/outer timing, non-secret Runtime/cohort/upstream identities, and evidence paths. Never expose credentials, DSN, secrets, cookies, or tokens.
