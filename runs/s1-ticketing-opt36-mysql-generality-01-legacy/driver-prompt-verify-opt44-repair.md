Continue the same frozen S1 evaluation with Opt44. This is the verification node only, after source repair and current source finalization.

Boundaries:
- Use the installed Opt44 Skill/CLI and the existing development session.
- Export `GOCACHE=/tmp/domainry-s1-opt44-go-build-cache` for every Go-backed command.
- Confirm Plane v0.18.0-opt44.d988302, the source-finalization Gate is current/passed, and current source SHA is `564996ae752715588f79c161fe5181511bcf7ccd9dc08989773caa2c001f1205` before the formal command.
- Record stage `verify_opt44_source_repair` using epoch seconds and the existing stage-file shape.
- Run `project verify --json` exactly once through the applicable current development Gate runner, with exact required identity bindings. Do not run a direct duplicate verify.
- Require the v6 verification receipt to be passed/current and report all checks, command duration, receipt SHA, project source tree SHA, and source/finalization binding.
- End the stage and stop. Do not package, stop/restart Runtime, run canary, prepare/run/check acceptance, modify source/model/tests/frontend/Skill/harness, or touch MySQL data.
- Keep the old managed Runtime intact; factually report that its packaged source cohort remains old until the later package/runtime nodes.

If verification fails, record one precise finding with the emitted evidence and stop without repair or retry. Report active seconds, formal command count, receipt/Gate status, and Runtime process observation.
