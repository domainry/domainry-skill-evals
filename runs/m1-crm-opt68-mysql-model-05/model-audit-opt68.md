# M1 CRM Opt68 model-stage independent audit

## Frozen inputs and execution

- Template commit: `73769154b8cb372c592ec989ba960b2bfbe57a69`
- Candidate: `gpt-5.6-sol/high`
- Project seed: `1626b61409a72469292a5d55d2d9416556c49a53`
- `requirements.md`: `e0efeb60fc61f13ed0fd7f66d925660e282096b149f1850ab05ac0886e9a6d37`
- Accepted PRD: `c25c7882646be6febfb0e44f081919908e48081172375aa4beb5d5c8f51d062d`
- Candidate wall time: `1593s`; live model timestamp: `1364s`
- Tokens: input `13,011,408` (cached `12,721,664`), output `69,290`, reasoning `25,196`
- Candidate session: `01a02a62-b356-7141-b2a8-92cfee7a3a02`

The run remained model-only. It did not run `model apply`, start Runtime, execute tests, or access an application database. The local Plane stayed healthy with the exact Opt68 Application Delivery and signer identity.

## Mechanical validation evidence

- Runtime Client bootstrap preceded capability discovery.
- Capability category index: one invocation.
- Selected capability packets: 21 unique keys, each fetched once.
- Local preflight: four effective invocations with diagnostic counts `2, 5, 0, 0`; seven total diagnostics in two coherent repair batches. The fourth invocation was required after the candidate's semantic authorization narrowing.
- Canonical `model validate`: two invocations, both valid with zero diagnostics. The second followed the semantic edit.
- `model plan`: one invocation, `37 creates / 0 updates / 0 deletes / 0 unchanged`.
- Candidate model Gates: `17/17`; TODO check passed at expected stage `model` with `22/26` items checked and later-stage work deliberately pending.
- Independent evaluator rerun: local preflight `valid` with issue count `0`; canonical validate `valid`, issue count `0`, coverage `37 items / 19 requirements / 30 acceptance scenarios`; Plane `/health` healthy with zero failed checks.

Compared with the prior two M1 model runs, Opt68 improved both convergence and cost:

| Candidate | Live model seconds | Input tokens | Output tokens | Preflight / validate behavior |
|---|---:|---:|---:|---|
| Opt66 | 1646 | 18,336,839 | 73,254 | no authoritative local preflight; 15 validate calls |
| Opt67 | 2525 | 16,950,454 | 94,889 | 6 effective preflights, 2 validates; semantic blockers remained |
| Opt68 | 1364 | 13,011,408 | 69,290 | 4 preflights, 2 zero-diagnostic validates; semantic audit passed |

Opt68 reduced live time by `1161s` versus Opt67 (`-46.0%`) and by `282s` versus Opt66 (`-17.1%`). Input tokens fell by `3,939,046` versus Opt67 (`-23.2%`) and by `5,325,431` versus Opt66 (`-29.0%`).

## Independent semantic reconciliation

### Opt67 blockers are closed naturally

1. `lead.status` is required, enumerated, and explicitly declares `default_value: "new"`. The value belongs to the authored state machine and supports the generic create surface; it was authored by the candidate without evaluator findings in its prompt.
2. The rejected approval branch binds `rejection_reason` to `$workflow.approval_comment`. The Action is reachable only through the actual approval node's `rejected` edge, and `empty_assignee_policy` is `fail`, so no skip/bypass path can fabricate the variable.

### Authorization and ownership

- Generic lead create uses a trusted `scope_owner` user field with `auto_assign_current_user: true`, plus Runtime-recognized `owner_department_id` and `owner_department_path` fields. Runtime derives the department fields from the authenticated owner's active Workforce assignment rather than accepting client scope claims.
- Sales lead read scope is department-wide. Detail updates and lifecycle/conversion commands remain owner-checked Business Handlers. Director lead visibility is global, but no generic lead update/create permission is published.
- Customer and approval Handler access is represented by data-access scope without publishing `customer.*` CRUD permission keys. Customer update/delete acceptance scenarios are denied, preserving R10.
- The candidate narrowed sales Handler access to approval/customer records from `all_records` to requester/source-owner predicates and revalidated the resulting model.

### Lifecycle, effects, reports, and fixtures

- Lead lifecycle is exactly `new -> contacted -> qualified -> converted/lost`; `converted` and `lost` are terminal. Approval lifecycle is `pending -> approved/rejected`.
- Direct and approval conversion Actions declare idempotency, optimistic concurrency, the required cross-object read/write set, audit events, and the unique source-lead/customer and lead/approval relations.
- Approval Actions publish only approved/rejected notifications; reminders use a weekday `09:00` schedule and a unique per-lead/business-date receipt.
- Funnel SQL left-joins the five-state dimension, so empty buckets remain present. `COUNT(l.id)` returns zero for an empty bucket while `SUM(l.expected_amount)` remains null when there is no present amount; missing amounts are counted separately.
- Governed CSV omits contact name and phone, has deterministic ordering and a literal bound, is director-only, requester-audited, and uses the declared audit/download objects.
- The inventory covers all R01-R19. It contains two departments, five sales/director user fixtures plus one scheduler service identity, six primary lead seeds spanning both departments, every lifecycle state, and both sides of the `100000.00` threshold.
- No connector, Consumer Portal, currency conversion, CNY assumption, SQLite fallback, or frontend artifact was introduced. `XXX` is used only as the Runtime exact-decimal no-currency sentinel for the unspecified currency fact.

## Residual proof boundary

The model checkpoint does not prove generated Handler source, apply convergence, managed Runtime behavior, MySQL queries, restart/replay, or standard acceptance. Those are the next nodes and must use a fresh local MySQL schema. The 30 declared acceptance scenarios cover every requirement group, but their behavioral oracles must still be exercised after implementation; model validity is not being treated as whole-project acceptance.

## Verdict

**Promote to `model apply`.** Opt68 closes both Opt67 semantic blockers, independently passes structural and live validation, preserves the frozen requirement hashes, and has no newly identified model-stage blocker. Promotion is limited to the model checkpoint; full M1 success remains unproven until apply, implementation, fresh-MySQL Runtime verification, and standard acceptance pass.
