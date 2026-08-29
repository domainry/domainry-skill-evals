Use the installed `domainry-builder-v1` Skill to continue the S1 ticketing generality evaluation from an intentionally migrated checkpoint. This is an Opt44 apply/materialization node only.

Context and boundaries:
- Active Plane must be `v0.18.0-opt44.d988302` at `http://127.0.0.1:8283`; model is `gpt-5.6-sol` with high reasoning.
- This project is a fresh independent Git root. Its committed requirements.md, docs/backend-requirements-prd.md, and backend/model/*.json are exact frozen copies of the already-reviewed Opt36 S1 artifacts. They replace hours of repeated requirements/model authoring; do not rewrite, reinterpret, or expand them.
- There is no frontend source. Do not create frontend files.
- Do not inspect the parent evaluation repository, benchmarks, golden, scorer, historical run, or any sibling directory. Do not use or recreate legacy Application Delivery fields.
- Use local MySQL only for later Runtime work; this node must not create/use SQLite and must not start Runtime.
- Do not implement project-owned Actions yet, do not verify/package, and do not run canary or acceptance.

Procedure:
1. Read the Skill completely as required. Establish a new visible project TODO for this session and record this as a light implementation continuation whose requirements/model truth is frozen and already accepted.
2. Confirm the four committed input files and Git baseline are present/clean. Capture their hashes. Confirm Opt44 CLI identity.
3. Run `model validate --json` once. It must pass with zero diagnostics; if not, record the exact full diagnostic batch and stop without editing the model.
4. Run `model apply --json` exactly once against the active local Plane, with Go module path `github.com/domainry-evals/s1-ticketing` and reviewed product surface `business_workspace`. This must publish/materialize current Opt44 contracts and project seed into this new root. Do not copy or edit generated/domain/.domainry outputs by hand.
5. Inspect only the bounded apply/materialization receipts and source status. Require current Application Delivery v5 to contain `skill_packages` and no `builder_v6_skill_packages`; record contract/hash/version identities and the project-source gap inventory.
6. End the apply stage and stop before source implementation.

Report active seconds, formal command counts/durations, model/Blueprint/application delivery/materialization/source packet identities, resulting paths/states, Git status, and the next exact node. Do not claim verification, Runtime, canary, or acceptance.
