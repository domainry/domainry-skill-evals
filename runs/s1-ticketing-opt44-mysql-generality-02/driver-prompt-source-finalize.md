Use the installed `domainry-builder-v1` Skill through its caller-explicit `source-finalization-continuation` route. This is the Opt44 S1 source-checkpoint validation/finalization node only.

Context and boundaries:
- Project root is the current Opt44 materialized S1 project. Plane is `v0.18.0-opt44.d988302` at `http://127.0.0.1:8283`; model is `gpt-5.6-sol` with high reasoning.
- The prior node already validated the frozen model once and published/materialized delivery `sha256:2332d42ed74c072be5b42e5e0977abd4b09e873fa848c095649d6cafd0c0d382`. Do not rerun model validate or model apply.
- A previously validated project-owned checkpoint has restored only `backend/actions/ticketing/ticket_assign.go` and `ticket_assign_test.go`. Their SHA-256 values are `1e3c4d6eac17dbf62121fd94922474620b8a4f71373c5974be10388ec5bfd177` and `0b3bf860f7a827fc5c46308d4d87fa1cd174250dc87f7adb3f91a2e2d979e579`. The current generated `ticket_assign` capability contract is byte-identical to the checkpoint contract.
- Do not inspect the parent evaluation repository, benchmarks, scorer, golden, sibling directories, or historical runs. Do not edit requirements, model, domain ledger, generated source, managed contracts, or frontend.
- Use local MySQL only in later Runtime work. This node must not create/use SQLite, start Runtime, verify, package, run canary, or run acceptance.

Procedure:
1. Follow the compact source-finalization continuation envelope exactly; do not load whole-project development resources.
2. Confirm Opt44 identity, current delivery/Blueprint/source packet identities, the two checkpoint hashes, and that the generated capability contract is current.
3. Run the bounded current source status/prepare operation required by the route, the generic offline `project check --json`, and only the focused Go test package for `backend/actions/ticketing` with the supplied writable `GOCACHE`.
4. If all pass, run `project source finalize --json` exactly once. Inspect its receipt and confirm the previous placeholder/capability-use failure is closed. Do not rerun apply.
5. Stop immediately after source finalization. Report active seconds, formal command durations/counts, current source/finalization identities, Git status, and the next exact node (`project verify` only).

Do not claim verification, packaging, Runtime, canary, acceptance, or project completion.
