Use the installed `domainry-builder-v1` Skill to continue this existing M1 CRM project from its accepted Opt68 model-complete checkpoint.

This is a stage-reuse evaluation of the `model apply` node only. The frozen `requirements.md`, accepted PRD, complete `backend/model/*.json`, Report SQL, prior TODOs, Gate receipts, and closed model timestamp are upstream evidence. Do not restart requirements/model authoring, rewrite any frozen artifact, reopen settled decisions, or reconstruct prior timestamps.

Context and boundaries:
- Model is `gpt-5.6-sol` with high reasoning. The pinned local Plane is exactly `v0.18.0-opt68.7376915` at `http://127.0.0.1:8283`.
- The model checkpoint has independently passed local preflight and canonical validation: 37 items, 19 requirements, 30 acceptance scenarios, Blueprint `1c487a79cd246260ede18f615e930d137ac796d23abc0b418b60603e8434479a`.
- Later Runtime and acceptance nodes must use a fresh local MySQL schema. This apply node must not connect to, create, inspect, or mutate an application database; must not introduce SQLite assumptions; and must not start Runtime.
- Do not inspect parent directories, evaluator files, benchmarks, golden files, scorer, historical runs, sibling directories, or template/framework source. There is no frontend; do not create or modify frontend files.
- Create a new session-owned project-visible TODO, preserve all earlier TODOs/Gates, and treat the accepted model as read-only unless the one required validation contradicts the frozen checkpoint. If it does, record the exact diagnostic batch and stop without repair.

Complete exactly the apply/materialization node:
1. Load the installed Skill and its routed apply authorities. Resolve project context once, verify exact installed CLI identity, and start the live `apply` timestamp in `.domainry/development/stages.json` before the apply command.
2. Confirm the frozen requirements, PRD, ten model files, two Report SQL files, capability lock, prior model timestamp, and Git baseline. Record hashes without reading evaluator-owned files outside the project.
3. Run canonical `model validate --json` once. Require `state=valid`, zero diagnostics, 37 items, and the frozen Blueprint identity. On any mismatch, stop and do not edit or apply.
4. Run `model apply --json` exactly once against the active local Plane with Go module path `github.com/domainry-evals/m1-crm`, product surface `business_workspace`, and normal dependency resolution. Do not pass bypass/skip/compatibility flags and do not rerun the command merely because automatic source finalization reports expected unimplemented Handler gaps.
5. Inspect only bounded apply/publication/materialization/source-status receipts. Require current Application Delivery/Runtime module/project template/SDK/Skill identities, a published 37-create/0-update/0-delete model, generated project source/Action skeleton inventory, and explicit fail-closed source gaps. Do not edit generated or project-owned source in this node.
6. Close all apply-node Gates that are actually supported, end the live `apply` timestamp, run TODO consistency at the resulting exact checkpoint, and stop before source implementation.

Forbidden in this node: capability rediscovery, model preflight/plan, a second validate/apply attempt, Action source implementation, source finalization repair, Go tests, project verify/package, Runtime start/status, acceptance prepare/run/check, evaluator probes, or any database operation.

Final report must include: active apply seconds and outer timing if known; exact validate/apply counts, durations, exits, and states; model/Blueprint/capability-lock/application-delivery/runtime-module/materialization/source-packet identities; generated file and source-gap counts; Gate/TODO status; unchanged frozen hashes; Git status; and the exact next node. Do not claim implementation, finalization, Runtime, verification, acceptance, or whole-project completion.
