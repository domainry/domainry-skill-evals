# M2 Opt-08 focused-test node baseline

This run continued a compile-valid M2 field-service checkpoint with only the eight legacy generated Action tests restored. Production Action source, requirements, backend model, and generated composition matched the valid Opt-07 checkpoint. It used the packaged Opt-08 Builder Skill at template commit `2ee614ea4191100f622a66482d6ba4a9c6b35d06`, `gpt-5.6-sol/high`, and a fresh local MySQL database. No SQLite, semantic canary, broad project verification, package, Runtime, acceptance, evaluator probe, golden, or scorer command ran.

## Result

The first `project check --json --scope actions`, before any Go test, returned all eight stale generated test scaffolds in one stable bounded inventory. The Agent repaired the complete test-only batch with typed non-nil Execution stubs and current assertions, then reached `state:"valid"` and finalized the current source. The first and only `go test ./actions/...` passed all eight Handler tests in 1.067 seconds. There were zero isolated diagnostic test commands, zero focused-test failures, zero post-test repair rounds, and zero reruns.

The Agent completed autonomously with no evaluator correction. Independent audit confirmed the finalization snapshot contains all eight Action test files plus the shared test helper, all 21 source snapshot hashes are current, `project check` remains valid, and an uncached focused package rerun passes. Requirements, `backend/model`, and production Action source are unchanged. The fresh MySQL database still has zero tables because this node uses typed capability doubles and does not launch Runtime.

## Comparison with Opt-07

Against the Opt-07 autonomous test-node run, the whole Agent continuation fell from 636 to 579 seconds (−57s, −9.0%) and input tokens fell from 4.872M to 2.975M (−38.9%). Work deliberately moved before `verify.started`: startup increased from 366 to 429 seconds, while `verify.started` to final response fell from 270 to 150 seconds (−120s, −44.4%). Agent Go-test commands fell from 11 to 1 (−90.9%).

Against the fully valid Opt-07 checkpoint, which required one audit continuation, wall time fell from 973 to 579 seconds (−40.5%), Go-test commands from 12 to 1, and evaluator interventions from one to zero. This is now the latest valid focused-test diagnostic-node baseline.

## Remaining optimization signal

The dominant residual time is no longer test execution. Of the 579 seconds, 429 elapsed before `verify.started`. The Agent still read all eight Handler bodies and generated capability interfaces to author useful test doubles, and evidence bookkeeping repeated a valid `project check` plus finalization. The development Gate could not directly treat the expected nonzero first check as evidence, so the Agent had to bind the finding table to a later passing receipt. A smaller integrity limitation also remains: focused-test gates were attached to the finalization receipt with the real test result in the note, rather than to a dedicated Go-test command receipt. These are the next high-value workflow targets; compiler all-errors remains a separate compile-stage optimization.
