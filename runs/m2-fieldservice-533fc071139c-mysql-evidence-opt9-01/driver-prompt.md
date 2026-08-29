Use the installed `domainry-builder-v1` Skill to continue the frozen M2 field-service delivery from its scaffold-clean, compile-valid, source-finalized checkpoint through the focused-test evidence node only.

This is a continuation evaluation of the installed evidence-aware Gate runner. Requirements, domain truth, capability discovery, model authoring, validation, planning, apply, materialization, Handler implementation, Action compile repair, stale-test-scaffold repair, and business test assertions are frozen upstream evidence. Do not redo those stages and do not modify `requirements.md`, `docs/backend-requirements-prd.md`, `backend/model/*.json`, production Action source, or Action test source.

Create one new current-session scoped TODO with only these three executable Gates, in order:

1. `project check --json --scope actions` returns exit 0 and `state:"valid"`;
2. current local composition is finalized;
3. module-focused Go tests pass.

Resolve the installed Skill/CLI once, sync and list the new Gates once, then execute each real product command exactly once through its matching `domainry-development-gates.py run` form documented by the installed Skill:

- valid Action check with the exact JSON contract/state expectation and source binding;
- source finalize with source binding;
- after recording `verify.started` while preserving existing `implement.started/ended`, focused `go test ./actions/...` through `run --cwd backend` with source binding.

Do not execute check, finalize, or Go test directly before or after the Gate run. Do not use `attach` for these Gates, search historical receipts, inspect another session's evidence directory, or substitute a receipt from another command. Stop immediately after the focused test Gate passes or a precisely classified non-project-owned blocker is proved. Report the exact product-command execution counts, receipt paths/kinds, Gate status, and timing. Keep `verify.ended` absent.

Do not run a semantic canary, `project verify`, `project package`, any Runtime process, acceptance prepare/run/check, evaluator probe, golden, or scorer command. Use the inherited fresh local MySQL environment for every command. Do not use or create SQLite. Do not print, rewrite, or persist the database DSN. The pinned local Domainry Plane is `http://127.0.0.1:8283`, but no Plane mutation is expected.

Do not inspect the parent evaluation repository, any `benchmarks`, historical run, framework source checkout, hidden assertion, or the Opt-09 implementation repository. Do not modify this driver prompt, evaluator assets, installed Skill, or CLI. Do not ask for human clarification.
