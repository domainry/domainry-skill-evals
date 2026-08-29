# M2 Opt-09 focused-test evidence-node baseline

This run continued the valid Opt-08 M2 field-service checkpoint with frozen requirements, backend model, production Action source, generated composition, and Action tests. It used the packaged Opt-09 Skill at final template commit `7063d25de408d674c52497f2e09c38ce40434bd8`, `gpt-5.6-sol/high`, and a fresh local MySQL database. No SQLite, semantic canary, broad verification, package, Runtime, acceptance, evaluator probe, golden, or scorer command ran.

## Result

The evidence-aware Gate runner executed each real product command exactly once on first use. The valid Action check exited 0 and bound a bounded structured proof; the real CLI's `diagnostics:null` was safely normalized to an empty inventory only for `state:"valid"` with zero issues. Source finalization exited 0 and its command receipt bound the current `.domainry/builder/receipts/finalization.json` artifact and SHA-256. The focused `go test ./actions/...` command then actually launched from `backend`, passed, and bound its own test command receipt. All three Gates finished passed with no attach, duplicate execution, receipt substitution, stale identity, or evaluator intervention.

Independent audit found the complete backend tree byte-identical to the Opt-08 source checkpoint, requirements and PRD unchanged, no forbidden downstream command, no project SQLite file, and zero tables in the fresh MySQL database.

## Rework samples excluded from the baseline

The first live replay at initial commit `9729495f2d9b0005175acd4d52b5dfd839e1cc23` exposed the real CLI's valid `diagnostics:null` shape. The runner correctly executed the product check only once and stopped, but rejected that valid inventory. Repair commit `0a047c83211f187626ab0fab27516e588b898785` fixed the shape contract.

The second replay exposed a canonical-label drift: the actual TODO said `Current local composition is finalized`, while the runner recognized only the legacy phrase `local composition finalized`. Check and finalize each ran once, but the focused-test command was rejected before launch because the finalize receipt lacked structured proof. Repair commit `7063d25de408d674c52497f2e09c38ce40434bd8` centralized canonical and legacy recognition and added a true 1/1/1 end-to-end fixture. Neither failed replay is baseline-eligible.

## Timing and next signal

The valid continuation took 186 seconds outer wall time. The three real product commands consumed only 2.687 seconds total (1.096s check, 0.104s finalize, 1.487s test), or about 1.44% of the run. Roughly 183 seconds remained in Skill/guide/template reading, resolver/TODO setup, inter-command reasoning, and final reporting. Therefore Opt-09 is kept for evidence correctness and deterministic one-execution semantics, but a wall-clock speedup is not claimed. The next high-value target is a narrowly scoped frozen-checkpoint continuation packet that avoids loading whole-batch authoring context for a deterministic check/finalize/test node.
