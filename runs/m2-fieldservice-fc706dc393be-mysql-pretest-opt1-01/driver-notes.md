# m2-fieldservice MySQL pre-test optimization 01

This is a fresh `gpt-5.6-sol/high` run of template commit `01e76833af320f4854ba06295c28c0742805d5cc`, using the user-provided local MySQL server. It evaluates the atomic complete-model validation protocol and stops after clean source finalization.

## Result

- Requirements: 282s versus 358s baseline.
- Model: 1095s versus 1788s baseline. The complete inventory existed before the first validation. Direct validation converged `30 → 1 → 0` in three calls versus 15 calls in the baseline, and no valid-model regression followed.
- Apply: 81s versus 41s baseline. One apply committed/materialized all 22 model items, then correctly failed closed on the eight generated Handler placeholders.
- Implement: 459s versus 779s baseline. All 8 Handler bodies were implemented; static Action check and source finalization both passed first attempt.
- Total staged time: 2017s versus 2966s, a reduction of 949s (32.0%).

The first validation's 30 diagnostics were repaired as one bounded batch. They were primarily schema-shape diagnostics, plus report SQL, role-relation, export-control, menu-binding, and ledger constraints. The only second-round diagnostic was `ledger.behavior_owner_mismatch`.

## Test boundary

No Go test, `project verify`, package, managed Runtime, acceptance command, golden probe, evaluator, or scorer was run. MySQL remained at zero tables because Runtime was not started. Generated `go.mod`/`go.sum` contain an indirect SQLite library dependency, but SQLite was neither configured nor used as persistence and no DSN was persisted.

## Checkpoint policy

Four immutable local Git checkpoints were frozen and indexed by `checkpoint-manifest.json`: requirements-complete, model-valid, post-apply, and source-finalized. A later optimization declares its earliest affected stage and starts from the preceding checkpoint with a newly derived project directory and a new empty MySQL database. Same-stage A/B runs always branch independently from the same parent checkpoint. Any upstream rule change invalidates downstream checkpoints.

## Verdict

`keep_pretest`: the targeted convergence and time metrics improved materially, while the 40-second apply increase is outweighed by a 949-second total reduction. This is not yet a full behavioral verdict: the optimized model inventory is more compact than the prior baseline, so a periodic fresh full-chain run remains required before release-level promotion.
