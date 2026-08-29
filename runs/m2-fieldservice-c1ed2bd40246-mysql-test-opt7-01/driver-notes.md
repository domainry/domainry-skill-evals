# M2 Opt-07 focused-test node baseline

This run continued the frozen Opt-06 implementation checkpoint using the packaged Opt-07 Builder Skill at template commit `7230082c6f6625354b63257b543e260b7973b818`, `gpt-5.6-sol/high`, and a fresh local MySQL database. It stopped at the focused-test checkpoint. No SQLite, semantic canary, broad project verification, package, Runtime, acceptance, evaluator probe, golden, or scorer command ran.

## What Opt-07 improved

The new real Action compilation gate rejected the invalid frozen source before the first Go test. It found 11 bounded diagnostics; after the first batch repair, two more same-family status errors became reachable behind Go's `too many errors` cutoff. All 13 errors across six Handlers were repaired before `verify.started`, and the final Action check passed.

The autonomous focused-test portion took 270 seconds from `verify.started` to the first Agent exit, versus 381 seconds in Opt-06: 111 seconds faster, a 29.1% reduction. Cumulative Go-test invocations fell from 15 to 12 after the required audit correction.

## Remaining dominant test problem

The first focused package run still aborted on stale generated test scaffolds. Eight isolated test invocations were required to collect the complete inventory: six nil-Execution panics and two directly visible obsolete `*.not_implemented` assertions. One test-only repair round added typed execution stubs and current validation, authorization, and scheduler no-op assertions. The final eight focused tests pass, but there are still no successful business mutation, persistence, idempotency, or MySQL behavior tests.

## Autonomous correctness failure

The Agent changed eight Action `*_test.go` files and added `handler_test_helpers_test.go` after finalization, then incorrectly claimed the receipt remained current because production Go files had not changed. Independent audit showed eight hash mismatches and one missing file in `finalization.json`. The same session was resumed and correctly ran `project check` → `project source finalize` → `go test ./actions/...`; the final receipt now contains all nine Action test files with zero hash mismatches.

Therefore this is the latest valid diagnostic node baseline, but autonomous pass-at-1 is false and one evaluator correction is recorded. The fully valid checkpoint cost 845 active Agent seconds and 12.69M input tokens across the original and resumed turns. The initial session alone used 636 outer seconds; 366 seconds elapsed before `verify.started`.

## Next optimization priority

The highest test-stage ROI is to make generated Action test scaffolds executable against implemented Handlers from the start: typed non-nil execution doubles plus assertions derived from the current Handler contract, so one package run can expose ordinary assertion failures without panic-driven eight-way isolation. Separately, the compile gate should request all compiler errors within its existing bounded output budget so one status-family repair can be genuinely complete.
