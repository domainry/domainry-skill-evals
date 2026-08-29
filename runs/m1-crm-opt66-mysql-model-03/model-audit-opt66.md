# M1 Opt66 model-node independent audit

## Measured result

- Candidate: `gpt-5.6-sol/high`
- Template: `2a5d5ece939e9e4ec0de89fadcff66e367f3ad43`
- Active model stage: `1646s`; outer process wall: `2100.11s`
- Tokens: input `18,336,839` (cached `17,959,168`), output `73,254`, reasoning `22,307`
- Capability index: one prerequisite failure, one success; 17 unique selected packets
- Canonical validation: 15 invocations, eight unique batches `1,1,1,1,8,14,6,0`, 32 resolved diagnostics
- Final structural result: validate `valid`, plan `27 create / 0 update / 0 delete`

## Promotion blockers

1. **Rejection reason is semantically corrupted.** `backend/model/40-processes.json` maps the rejected Workflow branch Action input `rejection_reason` to `$record.id`. The accepted PRD J08 requires the director's non-empty reason to be retained and visible. An approval record ID is not that reason. This repair made the model structurally valid by changing the business meaning.
2. **Unspecified currency metadata was invented.** `backend/model/20-crm.json` sets `currency_code: CNY` on lead, approval, and customer currency fields. PRD D-001 explicitly freezes currency/unit metadata as nullable and excludes an unstated currency/conversion rule. Exact two-decimal arithmetic is required; CNY is not.
3. **The funnel SQL does not return absent state buckets.** `backend/reports/funnel_report.sql` groups only rows present in `lead`. PRD D-005 and J10 require every state bucket, with exact counts/sums/missing counts. An empty status has no row in the current query.
4. **Delegated ownership remains unproved.** Validator repair set `auto_assign_current_user: true` on every user `scope_owner`, including `customer.owner_id` and `reminder_receipt.recipient_id`. Those records are created by a director/scheduler path but must retain the originating rep/lead owner. Before apply, the model must prove that server-side Action writes preserve the business owner/recipient rather than substituting the executing principal.
5. **The session ledger calls a model-only checkpoint `done`.** The final TODO passes only after `Current stage: done` and a handoff-only apply Gate were marked passed, although no apply occurred. The final prose limits the claim, but the machine state does not represent the actual reusable checkpoint cleanly.

## Generic optimization evidence

- The custom local preflight reported zero errors twice, yet the canonical loader/graph/authoring chain found 32 diagnostics.
- Seven failed Gate runs had to be repeated directly because Gate receipts retained only byte counts/hashes, not a bounded diagnostic locator/body.
- The first capability index call predictably failed because Runtime Client disclosure bootstrap occurred only after that failure.
- The highest-ROI next batch is a no-HTTP CLI model preflight that reuses the canonical local loading/graph/authoring checks, persists the complete diagnostic batch itself, and returns a compact result locator. This should also make the disclosure bootstrap prerequisite explicit before the category-index call.

## Verdict

`rework`: keep Opt66's database-driver correction, but do not promote this M1 model checkpoint to apply until the semantic blockers are repaired and revalidated from the accepted requirements checkpoint.
