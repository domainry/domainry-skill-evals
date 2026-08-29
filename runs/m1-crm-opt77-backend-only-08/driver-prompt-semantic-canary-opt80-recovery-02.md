This is a staged cross-case evaluation of the installed `domainry-builder-v1` Skill using `gpt-5.6-sol/high`.

Use the installed Skill faithfully and read its `SKILL.md` completely before acting. Work only inside the current M1 project. Do not inspect the parent evaluation repository, benchmarks, golden files, scorer, evaluator harness, other runs, or unrelated historical sessions.

The accepted requirements/model, backend-only source, finalization, verification, package, and current managed Runtime are frozen. The Runtime is a newly bootstrapped clean local MySQL cohort, healthy at the exact address in `.domainry/builder/runtime/runtime-process.json`; SQLite is forbidden. Do not start, stop, restart, or status the Runtime. Do not print, enumerate, serialize, or persist the DSN or password outside the canonical secret store.

The immediately preceding failed canary session `m1-opt80-semantic-canary-01` is the only historical session you may inspect. Its sole Gate failed before business mutation because its thin harness had two concrete defects:

1. it called `Sessions.session(user_id)`, which intentionally binds the identity context; all role-authorized business requests must instead use the exact Runtime-returned workforce context through `Sessions.context(user_id, "workforce", workforce_profile_id=<formal selector>)`;
2. it subclassed `Sessions` to suppress `_store_secret`, so first-login password rotation was not persisted. Do not subclass or override canonical `Sessions`; canonical 0600 cohort-bound secret persistence is required and must stay excluded from evidence.

The old cohort has been stopped and archived, so its lost credentials and failed evidence are not inputs to this node. The current cohort is fresh. Your only objective is a minimal recovery of the same single highest-risk J07/R07-R10/R13 semantic canary:

- invoke the default resolver exactly once with fresh session ID `m1-opt80-semantic-canary-02` and use its current light-batch TODO/Gate contract;
- reuse the prior thin `semantic_canary.py` rather than rediscovering the journey or rewriting a broad harness; copy it into the fresh session and make only the corrections required above plus binding the current Runtime address from its receipt instead of the retired address;
- use canonical installed `acceptance-harness-core.py`; do not copy/reimplement auth, HTTP, retry, evidence, or secret plumbing;
- the formal workforce selectors are discovered from each authenticated principal-context response; select exactly one returned workforce context for each frozen actor and never manufacture headers;
- run exactly one real canary command through its own fresh Gate; it must cover the existing script's positive, denied, durable approval/lead/customer read-back, requester Inbox, idempotent replay, and post-terminal conflict assertions;
- stop after the first Gate result. On failure, record a complete reachable failure inventory but do not repair or rerun. On success, do not run acceptance prepare/run/check or any broader acceptance.

Do not modify requirements, PRD, model, production source, generated source, verification, package, Runtime state, or database directly. Do not create frontend or Runtime Client SDK files. Do not claim whole-project completion.

Finish with outer/pure active duration, resolver/product/Gate counts, exact canary result, non-secret Runtime/cohort/upstream identities, and evidence paths. Never expose credentials, tokens, cookies, session secrets, password, or DSN.
