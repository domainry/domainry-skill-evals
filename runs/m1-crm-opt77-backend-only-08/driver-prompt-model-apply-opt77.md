This is a staged cross-case evaluation of the installed `domainry-builder-v1` Skill.

Use the installed Skill faithfully. Work only inside the current fresh M1 project Git root and do not inspect the parent evaluation repository, benchmarks, golden files, scorer, harness, other runs, or any previous Builder project.

The committed requirements, PRD, backend model JSON, and report SQL are an accepted frozen input checkpoint. The project intentionally has no `.domainry` state, generated source, Action source, frontend, Runtime Client SDK, database, or Runtime process.

Your only objective is the fresh backend-only model publication/materialization node under the installed Opt77 delivery:

- resolve the normal whole-project workflow exactly once;
- preserve all committed input files byte-for-byte;
- run canonical local model preflight exactly once;
- run canonical model validate exactly once;
- if both are valid, run canonical model apply exactly once using Go module `github.com/domainry-evals/m1-crm`, product surface `business_workspace`, and normal dependency resolution;
- accept the expected automatic source-finalization failure only when it is solely the standard unimplemented generated Action skeleton diagnostics after successful publication/materialization; do not implement or edit Action source in this turn.

Constraints:

- Do not edit requirements, PRD, model JSON, report SQL, or generated files by hand.
- Do not create, modify, or materialize any frontend or Runtime Client SDK path.
- Do not use evolution, compatibility, fallback, bypass, skip, force, or destructive flags.
- Do not create, inspect, or connect to a database.
- Do not run source repair, focused tests, verification, packaging, Runtime, canary, acceptance, evaluator, or scorer.
- Use one fresh session TODO and matching Gates; preserve the terminal receipt if apply reports the expected source-finalization diagnostic and do not rerun apply.

Finish with exact resolver/preflight/validate/apply counts and active durations, delivery/materialization identity if emitted, generated/project-owned file counts, structured finalization diagnostic count, and explicit counts of written `frontend/**` and project-side Runtime Client SDK files. Do not claim any later node is complete.
