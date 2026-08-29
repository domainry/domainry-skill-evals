This is a staged cross-case evaluation of the installed `domainry-builder-v1` Skill using `gpt-5.6-sol/high`.

Use the installed Skill faithfully. Work only inside the current M1 project Git root. Do not inspect the parent evaluation repository, benchmarks, golden files, scorer, harness, other runs, or historical sessions.

The requirements, PRD, backend model JSON, report SQL, generated backend, project-owned Action source/tests, source-finalization identity, and verified source are accepted and frozen. Opt78 changed only the Builder-owned Application Delivery binding contract. The installed Opt78 CLI reports the current source status as `current`, but a single package probe correctly stopped because the prior V6 verification lacks `application_delivery_binding`. Source inspection proved this binding is produced only by canonical project materialization, not by verification.

Your only objective is an unchanged-model Opt78 rebind probe:

- use the installed Skill's normal whole-project route and resolver exactly once;
- preserve all project-owned requirements, PRD, model, report, Action source, and tests byte-for-byte;
- run canonical local model preflight exactly once;
- run canonical model validate exactly once;
- if both are valid, run canonical model apply exactly once using Go module `github.com/domainry-evals/m1-crm`, product surface `business_workspace`, and normal dependency resolution;
- do not pass an evolution-audit identity on this first probe.

If apply emits a review/evolution audit or source-conflict checkpoint, stop and report its identity, expected changes, protected conflicts, and live-tree immutability. Do not perform the audit-bound apply in this task. If apply succeeds directly, report the new delivery, materialization, backend-only binding, finalization, and source identities.

Do not edit or repair any business/model/source file. Do not rerun package or verification. Do not create, modify, copy, or delete frontend or Runtime Client SDK files. Do not access a database or run Runtime, canary, acceptance, evaluator, or scorer. Do not use compatibility, fallback, bypass, skip, force, destructive, or legacy flags.

Use a fresh session TODO and Gates. Finish with exact resolver/preflight/validate/apply counts and active durations, the structured result, input/output token usage if available, live source hash before/after, Builder binding state, and explicit frontend/SDK path counts. Do not claim re-verification, packaging, Runtime, or later nodes complete.
