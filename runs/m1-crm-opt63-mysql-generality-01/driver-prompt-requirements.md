Use the installed `domainry-builder-v1` Skill to begin a fresh M1 CRM generality evaluation. This invocation is the requirements/PRD node only.

Context and boundaries:
- Model is `gpt-5.6-sol` with high reasoning. The active local Plane is `v0.18.0-opt63.7e43fe6` at `http://127.0.0.1:8283`.
- The current directory is an independent clean Git root. Its committed `requirements.md` is the only business input and must remain byte-identical.
- There is no frontend source. Treat the committed requirements as the delivered product evidence; do not invent or create frontend files.
- Do not inspect parent directories, the evaluation repository, benchmarks, golden files, scorer, historical runs, sibling directories, or template/framework source.
- Use only the installed Skill and its CLI. Do not modify the Skill.
- Later Runtime work must use a fresh local MySQL database. This node must not create a database, use SQLite, call `model validate/apply`, materialize, implement source, verify, package, start Runtime, or run acceptance.

Procedure:
1. Read the installed Skill completely and follow its requirements route. Create the one project-visible development TODO required by the Skill.
2. Confirm the Git root is clean, record the requirements SHA-256, and inspect only `requirements.md` plus the Skill resources routed for requirements/PRD work.
3. Maintain `.domainry/development/stages.json` in real time using epoch seconds and exactly the six standard keys when applicable: `requirements`, `model`, `apply`, `implement`, `verify`, `acceptance`. For this invocation, open and close only `requirements`.
4. Produce the canonical evidence-backed backend dependency PRD at the Skill-prescribed project path. Every object, role, scope, state transition, approval threshold, transaction boundary, notification, scheduler rule, report/export rule, navigation requirement, and acceptance identity/seed requirement must trace to `requirements.md`. Mark genuine ambiguities explicitly; do not add speculative capabilities.
5. Run only the Skill-prescribed requirements/PRD consistency checks that do not enter model authoring or contact the Plane.
6. Stop immediately after the requirements node is complete. Leave model authoring for the next invocation.

Report active seconds, files changed, requirements/PRD identity hashes, unresolved ambiguities, Git status, and the exact next node. Do not claim model, apply, implementation, verification, Runtime, or acceptance completion.
