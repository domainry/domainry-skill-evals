This is a staged cross-case evaluation of the installed `domainry-builder-v1` Skill using `gpt-5.6-sol/high`.

Use the installed Skill faithfully. Work only inside the current M1 project Git root. Do not inspect the parent evaluation repository, benchmarks, golden files, scorer, harness, other runs, or historical sessions.

The prior Agent turn has ended. The accepted frozen model produced the immutable, reviewed Opt78 evolution audit `f24f571fa72f4e47536ebcde9ba42a169ff62b3623d8a8633106de375a5201e6`. Review established:

- Blueprint, Project Contract, Runtime API, Runtime module, requirements, model, and source seed semantics are unchanged;
- the change is a `v6_upgrade` replacing the old full Application Delivery cache with the backend-only `application-delivery-binding` and refreshed Builder-owned contract caches;
- all 18 Action source/test conflicts have identical old/new seed hashes and are explicitly `suggested_owner=project_source`; their completed live implementations must be preserved byte-for-byte;
- `backend/go.mod` and `backend/go.sum` are current project-owned/local-composition files and must remain byte-identical;
- frontend and Runtime Client SDK project paths are zero and must remain zero.

The audit is accepted for exactly this bounded migration. Your only objective is the audit-bound Opt78 promotion:

- use the installed Skill's normal whole-project route and resolver exactly once;
- create a fresh minimal session TODO/Gates;
- preserve requirements, PRD, model, reports, Action source/tests, `backend/go.mod`, and `backend/go.sum` byte-for-byte;
- run canonical local model preflight exactly once;
- run canonical model validate exactly once;
- run canonical model apply exactly once with Go module `github.com/domainry-evals/m1-crm`, product surface `business_workspace`, normal dependency resolution, `--evolution-audit-sha256 f24f571fa72f4e47536ebcde9ba42a169ff62b3623d8a8633106de375a5201e6`, and a concise reason limited to upgrading the Builder-owned Opt78 backend delivery binding while preserving project-owned source.

Do not edit or repair any business/model/source file. Do not run verification or package in this task. Do not create, modify, copy, or delete frontend or Runtime Client SDK paths. Do not access a database or run Runtime, canary, acceptance, evaluator, or scorer. Do not use compatibility, fallback, bypass, skip, force, destructive, or legacy flags.

If promotion succeeds, report delivery/materialization/finalization identities, binding contract identity, materialized owner/file counts, protected source hashes before/after, and explicit frontend/SDK counts. If it fails, stop after this single audit-bound apply and report the structured blocker without retry.
