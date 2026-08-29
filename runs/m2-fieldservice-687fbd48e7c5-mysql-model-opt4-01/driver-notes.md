# Driver notes — opt-04 model checkpoint

This run was independently cloned from the opt-01 `requirements-complete` checkpoint into a fresh project and fresh empty MySQL database. No opt-02/03 repaired model was reused.

The fast path was recognized. The Agent started its model timestamp 26 seconds after process launch, compared with 59 seconds in opt-03 and 306 seconds in opt-02, and skipped whole-project workflow/domain-truth/production-gate/runtime-client rereads. It nevertheless read the generic Handler template, seven ledger patterns, and loaded 24 capability categories containing 190 operations instead of a demand-minimal set.

The primary validation sequence was `8→4→0`. It matched opt-01's three primary calls and reduced opt-01's first batch of 30 diagnostics to 8, but six of those eight were Report/export contract constraints that the skipped context did not prevent. Final model and plan were valid with 18 creates and no updates/deletes.

Timing is decisively negative. The declared model interval is 2016 seconds and the comparable outer interval is 2042 seconds (`1787288956→1787290998`), 947 seconds / 86.48% slower than the opt-01 keep baseline. Although command count fell to 47 and input tokens to 8.39M, long generation/reasoning intervals dominated wall time.

Verdict: `rollback`. The optimization commit must be reverted. A future attempt needs a deterministic resolver-produced demand-to-category/reference route; prose asking the Agent to self-select is not sufficient. Experimental commit `3798c1cbb067ddd827e4610f6f991bdb4f4128cb` and tree hash `54539fe890b1272e0f6da28fa071ffe0f7af03003f483caccb032c00f3e82516` remain audit-only.
