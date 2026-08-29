# M1 CRM Opt67 model-stage independent audit

## Frozen inputs and execution

- Template commit: `08e24832a7d66857722b8122dd2387781aad1613`
- Candidate: `gpt-5.6-sol/high`
- Project seed: `1626b61409a72469292a5d55d2d9416556c49a53`
- `requirements.md`: `e0efeb60fc61f13ed0fd7f66d925660e282096b149f1850ab05ac0886e9a6d37`
- Accepted PRD: `c25c7882646be6febfb0e44f081919908e48081172375aa4beb5d5c8f51d062d`
- Candidate wall time: `2793s`; live model timestamp: `2525s`
- Tokens: input `16,950,454` (cached `16,420,096`), output `94,889`, reasoning `35,954`
- Candidate session: `01a02a11-7ddd-7ac3-9e13-eda494100e9f`

The run remained model-only. It did not run `model apply`, start Runtime, or access an application database.

## Mechanical validation evidence

- Runtime Client bootstrap preceded capability discovery.
- Capability category index: one successful invocation.
- Selected category packets: 22 unique keys, each loaded once.
- Local preflight: 7 CLI invocations. The first was a command-contract failure because required `--json` was omitted. The six effective batches were `32, 29, 3, 44, 0, 0` diagnostics; the last valid rerun followed requirement-backed semantic edits.
- Canonical live `model validate`: 2 invocations, both zero-diagnostic. The second was required because semantic reconciliation invalidated the first model identity.
- `model plan`: one invocation, `33 creates / 0 updates / 0 deletes / 0 unchanged`.
- Candidate TODO: `17/17`, expected stage `model`.
- Independent root rerun: local preflight `valid`, issue count `0`; canonical validate `valid`, issue count `0`, coverage `33 items / 19 requirements / 42 acceptance scenarios`.

Opt67 achieved its primary mechanical goal: the Agent no longer used repeated HTTP validation to retrieve diagnostic text. Compared with Opt66, canonical validate fell from 15 invocations to 2. It did not reduce end-to-end model time: live time increased from `1646s` to `2525s`, while input tokens fell from `18,336,839` to `16,950,454`. The extra time/output came from a much broader late semantic reconciliation and 42-scenario acceptance inventory.

## Confirmed improvements over Opt66

- Funnel SQL now seeds all five status buckets and uses `COUNT(l.id)` plus a guarded missing-amount expression, so an empty bucket remains present with counts `0`.
- Currency is no longer invented as CNY; exact 19,2 metadata uses `XXX` to represent an unspecified currency/no conversion policy.
- Formal identity bootstrap includes two departments, differentiated sales/director principals, Workforce profiles/assignments, menus, and role-menu bindings.
- Customer direct CRUD remains denied through the absence of `customer.read/create/update/delete` role permissions; Handler data access does not itself publish generic CRUD permission.
- Acceptance metadata now includes principal-context, same/cross-department, Workflow task decision, audit readback, empty-bucket, and 0/1000/1001 export cases.

## Semantic blockers; do not promote to apply

### 1. Lead create does not default status to `new`

`lead.status` is required and enumerated but has no `default_value`. The only Business Workspace entrypoint exposes generic `lead` creation, and there is no custom create Action that supplies the state. Runtime record creation applies a field default only when `default` or `default_value` is authored. Therefore R03/M03 is not implemented by the current model even though the acceptance scenario says create should pass.

Generic correction: whenever an accepted requirement declares an initial/default state for a generic create surface, author the exact object-field `default_value` and verify it matches the state-machine state set.

### 2. Workflow rejection stores a constant instead of the submitted decision reason

The rejection branch binds:

```json
"rejection_reason": "Rejected through the director approval task; the submitted decision comment remains in Workflow Runtime evidence."
```

This does not retain the director's submitted reason in `conversion_approval.rejection_reason` and cannot populate the requester notification with that actual reason. It contradicts J08/R07/R09/M07.

Runtime already stores the task comment in process variable `approval_comment` before executing the rejected branch. However the authoring semantic validator rejects `$workflow.approval_comment`: its supported-reference list only includes trigger-time workflow fields. This is a generic Foundation contract mismatch, not a CRM-specific missing feature.

Generic correction: disclose and validate post-approval `$workflow.approval_comment` (and the paired decision value) on action nodes reachable from an approval branch, then bind required rejection-reason Action input to that variable. Invalid pre-approval use must continue to fail closed.

## Verdict

**Rework.** The structural preflight optimization is kept, but this M1 candidate is not an apply checkpoint. The next model attempt must restart from the accepted requirements checkpoint after a generic authoring/Skill fix, not patch this candidate in place or consume evaluator-only findings as project input.
