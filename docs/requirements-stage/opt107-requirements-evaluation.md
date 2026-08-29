# Opt107 requirements-stage evaluation

Status: complete for `requirements` only. This evaluation does not enter or design the `model` stage.

Machine-readable authority: `opt107-requirements-evaluation.json`.

## Decision

The current requirements content standard should be retained, but the stage orchestration should be replaced by one typed, fail-closed finalizer. The smallest correct requirements load set is already close to the current `requirements_entry`; the main loss is not PRD authoring quality but an internally contradictory close/transition recipe, premature later-stage disclosure, and per-checkbox attachment ceremony.

The resulting workflow remains exactly:

`requirements → model → apply → implement → verify → done`

No top-level stage is added. Domain-truth settlement remains part of `requirements`. Project-specific real Runtime/PostgreSQL journey proof belongs later in `verify`; no independent `acceptance` stage is proposed here. No MySQL-specific replacement flow is proposed.

## Baseline timeline

The authoritative baseline is `runs/m2-fieldservice-opt107-mysql-full-01`. It is historical process/time evidence only: `baseline_eligible=false`, and its MySQL cohort is not a future PostgreSQL success baseline.

| Interval / event | Evidence | Time |
| --- | --- | ---: |
| Agent outer start → requirements attempt open | timing `pre_stage_ms` | 21.481 s unallocated |
| Initial requirements attempt | item_1–item_15 | 378.672 s wall; 1.575 s CLI-active; 377.097 s idle |
| Premature close → repair attempt open | item_16–item_28 | 94.335 s outside recorded attempts |
| Requirements repair attempt | item_28–item_29 | 5.592 s wall; 0.496 s CLI-active; 5.096 s idle |
| Recorded requirements attempt sum | timing `stages.requirements` | 384.264 s |
| First requirements attempt open → actual model open | stage epoch subtraction | 478.599 s |
| Agent outer start → actual model open | outer start + model boundary | 500.080 s |

The commonly quoted `requirements=384.264 s` is only the sum of two recorded attempts. It excludes the 94.335-second gap between attempts. For stage-boundary optimization, 478.599 seconds is the honest continuous local observation; for fresh E2E, neither number is a replacement for outer wall time.

CLI-active is only 2.071 seconds of the recorded 384.264 seconds (0.539%). The baseline's primary cost is Agent orchestration/authoring time, not product command execution. This does not mean all idle time is removable: the PRD was substantive work and must remain complete.

### Ordered event reconstruction

1. `item_1`: read the Skill entrypoint.
2. `item_2`: resolver created the TODO and open requirements attempt; emitted `domainry-requirements-entry-v1`.
3. `item_3`: verified embedded CLI `v0.0.107-opt107.ddf84df5`.
4. `item_5`: read requirements authority, PRD template, and `requirements.md` once.
5. `item_7`: conditionally read domain-truth settlement authority because calculations, inventory settlement, historical facts, and correction/reversal were present.
6. `item_8`: read the current TODO requirements/domain-truth area.
7. `item_9`: authored the PRD and current TODO.
8. `item_10`–`item_13`: sync, list two stage groups, then attach the same PRD evidence to 15 gates. Measured wrappers total 1.375 seconds (`110+81+77+1107 ms`).
9. `item_15`: ran `stage-close --stage requirements`, ending the initial attempt.
10. `item_16`: `resume` returned `repair_required`; `item_17` read the locator packet. The packet complained about missing final acceptance results and disclosed `stage_authority_route.stage=apply`, even though model was not open.
11. `item_19`: before model opened, read the full 345-line development guide plus backend-model, project-mutation, and backend-runtime.
12. `item_20`–`item_22`: reread the whole guide and overlapping subsets three more times; `item_23` reread backend-model; `item_24` inspected later TODO sections.
13. `item_25`: the first atomic requirements→model transition failed with `development source stage has no open attempt`.
14. `item_26`: an additional `status --require-complete` returned blocked and cost 96 ms CLI-active.
15. `item_28`: opened a requirements repair attempt.
16. `item_29`: atomically transitioned requirements→model successfully.

Inventory through the successful boundary: 23 completed command items, one file-change event, two failed command items, 15 attachment sub-operations, two premature later-stage read commands, and four duplicate later-authority read commands. The raw event stream is 4,639,991 bytes (about 4.4 MiB); the analysis script selects only the requirements boundary rather than treating the whole stream as stage evidence.

## Read-only Skill audit

The installed Skill and `/Users/tiger/Projects/verdent-template/skills/domainry-builder-v1` are byte-identical for all four audited requirements files:

| File | SHA-256 | Finding |
| --- | --- | --- |
| `SKILL.md` | `c2186bae…d8e` | Correctly says a fresh `requirements_entry` is complete requirements authority and forbids whole-guide/later-reference reads. |
| `bin/domainry-development-context.py` | `1b547bab…5e6` | Passes `requirements_entry` through from `init-workflow`; later generic authoring context contains broad model references. |
| `references/requirements-and-domain-truth.md` | `02256d7e…fe9` | Strong completeness, evidence precedence, traceability, blocker, and domain-truth rules; retain. |
| `assets/BACKEND_REQUIREMENTS_PRD.template.md` | `2e56db7d…b00` | Strong structured matrices and confirmation checklist; retain and add a typed demand index. Remove its line-11 `see development-guide.md` pointer because the focused requirements authority already defines reference mode. |

The evaluator did not read Gate source or the whole development guide. The context source shows `initialize_whole_project` delegates fresh initialization to `init-workflow`, and `main` emits the returned `requirements_entry`. Therefore the contradictory recipe must be corrected at the `init-workflow` serializer and asserted at the context boundary.

The existing tests prove that fresh context opens one requirements attempt, loads exactly two unconditional authorities, and excludes the guide/TODO template/technical gates/backend-model. They only assert that `sync_todo_gates` and `route_next_stage` are present. They do not assert exact action order, absence of `stage-close`, an atomic transition, or suppression of later authority after an incomplete boundary. Routing tests likewise verify prose-level progressive disclosure but not executable boundary semantics.

### Current minimum load set

Always once:

- Skill entrypoint, compact resolver packet, and embedded CLI identity.
- `requirements-and-domain-truth.md` and the PRD template.
- Current accepted source authority: root `requirements.md` or immutable accepted design references.
- Only the TODO header and packet-provided requirements/domain-truth line ranges.

Conditionally:

- `domain-truth-and-settlement.md` only when structurally accepted requirements contain calculation, historical fact, settlement, correction, or reversal obligations.
- Frontend source evidence only when the resolver's regular-file manifest proves a frontend, and only in the authority's documented evidence order.

Forbidden until model:

- Whole development guide, TODO template, production technical gates, backend-model, every capability reference, and Gate source.

This set does not weaken PRD completeness, one-row-per-requirement traceability, domain-truth ownership/snapshot/correction rules, semantic acceptance journeys, or the narrow `business_blocker` standard.

## Typed demand/capability disclosure profile

The proposed `domainry-requirements-demand-profile-v1` is a compiler output, not an Agent-authored feature-flag file.

It is bound to:

- accepted requirements identity;
- PRD hash;
- source-authority and frontend-evidence manifests;
- requirements stage receipt;
- requirements-entry, CLI identity, and CLI capability-disclosure contract versions.

Each compact demand row contains only a stable demand ID, accepted requirement IDs, one closed demand kind, PRD structural row pointers, acceptance journey IDs, permission/scope pointers, and compiler-selected capability reference keys. It excludes PRD prose and matrices and is capped at 16 KiB.

The compiler parses stable headings, tables, IDs, classifications, and typed cells. It must never infer capability demand from prose keywords. Unknown kinds, unresolved joins, incomplete coverage, `frontend_only` backend demand, an unbounded/malformed blocker slice, identity mismatch, or oversized output fail closed. A valid `business_blocker` marks only its exact demand slice blocked while preserving unblocked demands; it never silently becomes a global stop. Capability paths/keys come only from the versioned CLI registry; the Agent cannot invent or override them.

This allows the model resolver to load only capability references selected by accepted typed demand while preserving the complete PRD as the source of business truth.

## Reusable accepted requirements checkpoint

Contract: `domainry-accepted-stage-checkpoint-v1`, stage `requirements`.

Required identity includes requirements/PRD/frontend/source-authority hashes; requirements-relevant Skill and CLI contract hashes/versions; stage receipt and typed-profile hashes; immutable Git HEAD/tree/status hashes and clean flag; and accepted managed Runtime driver.

Reuse rules:

- Reuse is only for stage optimization and diagnostics.
- Clone the immutable accepted tree into a new blank experiment workspace with a new session and no database/Runtime state.
- Import only the accepted requirements receipt/profile. Do not copy TODO attempts, Gate locks, model files, database state, or Runtime state.
- Recompute all identities before model opens. Any mismatch or inability to prove equality fails closed and reruns requirements.
- A later-stage candidate may differ outside the requirements-contract closure only when a machine diff manifest proves every requirements-relevant Skill/CLI contract unchanged. Otherwise fail closed.
- New staged experiments are PostgreSQL-first. A historical MySQL checkpoint cannot become the future success baseline and gets `requirements_checkpoint.driver_not_postgres`; no MySQL-specific repair branch is added.
- Supplying a checkpoint in final fresh-E2E mode fails with `requirements_checkpoint.fresh_e2e_reuse_forbidden`.

Opt107 itself is not a reusable checkpoint: it is ineligible, MySQL-based, lacks the typed profile and stage receipt contracts, showed a dirty/untracked Git state at the observed boundary, and required a transition repair.

## Exact change request

The full file/function/contract/failure-code matrix is authoritative in the JSON artifact. In summary:

1. `CR-RQ-001`: replace `close_requirements_attempt + route_next_stage` with a single `requirements-finalize` recipe action and `domainry-requirements-entry-v2`. Never expose later authority before atomic success.
2. `CR-RQ-002`: merge sync, lists, 15 attaches, completeness validation, identity binding, receipt emission, and transition under one lock. Retain every PRD/domain-truth predicate.
3. `CR-RQ-003`: add the typed profile schema/compiler/validator and disclose only compiler-selected model references.
4. `CR-RQ-004`: add evaluator-controlled accepted-checkpoint import with exact identity/Git/PostgreSQL checks and an explicit fresh-E2E prohibition.
5. `CR-RQ-005`: replace presence-only routing tests with exact recipe, atomicity, authority suppression, profile coverage/identity, checkpoint invalidation, PostgreSQL-first, and timing-mode tests.

These are change requests for a separate verdent-template task. No verdent-template or installed Skill file was modified here.

## Time claims

Only these effects are currently evidenced:

- 99.927 seconds occurred on the avoidable broken transition path: 94.335 seconds outside attempts plus a 5.592-second repair attempt. Later-reference rereads happened inside that interval and are not counted again.
- 1.375 seconds of measured Gate CLI work came from sync + two lists + 15 attachments and can be folded into one finalizer, but the future finalizer still has nonzero cost.
- No measured optimized requirements duration exists.
- No fresh PostgreSQL E2E exists.
- No 38-minute or other end-to-end promise is made.
- A fast fail-closed diagnostic is not a repair and is not a passing stage.

Stage-local experiment reports and fresh-E2E reports use separate field sets. A staged model run must carry `parent_checkpoint_id`; a fresh E2E must say `fresh_project=true` and `checkpoint_reused=false`.

## Focused verification

Run from the eval repository:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 harness/analyze_requirements_stage.py \
  runs/m2-fieldservice-opt107-mysql-full-01

PYTHONDONTWRITEBYTECODE=1 python3 \
  harness/validate_requirements_stage_artifact.py \
  docs/requirements-stage/opt107-requirements-evaluation.json
```

The validator must return `state: passed` with an empty diagnostics array. The timeline extractor independently derives the stage boundary, timing split, command inventory, raw-source hashes, and requirements failure from the three immutable baseline authorities.
