This is a staged cross-case evaluation of the installed `domainry-builder-v1` Skill.

Use the installed Skill faithfully. Work only inside the current M1 project and do not inspect the parent evaluation repository, benchmarks, golden files, scorer, harness, or historical runs.

The accepted requirements, PRD, domain truth, all backend model JSON/SQL, all project-owned Action handlers/tests, and the current source-finalization checkpoint are frozen and read-only. The sole objective is to evolve the existing Builder delivery from its old project-side frontend/Runtime Client SDK materialization contract onto the installed backend-only Opt76 delivery contract, while preserving the frozen business model and project-owned backend source.

Constraints:

- Do not edit requirements, PRD, model JSON, report SQL, Action source, tests, or generated source by hand.
- Do not create, drop, truncate, inspect, or connect to any database.
- Do not start Runtime or run canary, acceptance, evaluator, scorer, verification, or packaging.
- Do not create, modify, or materialize any frontend or Runtime Client SDK files.
- Do not add compatibility, fallback, bypass, skip, force, or destructive flags.
- Use a fresh session TODO and Gate state for this exact node. Preserve all prior sessions and evidence.

Run the installed Skill's normal resolver exactly once. After its mandated identity/routing steps, run canonical local model preflight once and canonical model validate once against the frozen model. If both are valid, run canonical model apply once with Go module `github.com/domainry-evals/m1-crm`, product surface `business_workspace`, and normal dependency resolution.

If and only if that apply returns the formal existing-project evolution-review requirement, inspect only the newly emitted audit, verify that the business model/project contract/Runtime API and project-owned backend source are preserved and that the change is limited to removal of Builder-owned project frontend/Runtime Client SDK materialization plus the installed delivery update, then run exactly one fresh audit-bound model apply through a new round-specific Gate with a concise truthful evolution reason. Stop on any other diagnostic batch.

On success, report exact command counts, active durations, new delivery/materialization/finalization identities, and whether any frontend or Runtime Client SDK path was written. Do not claim verify/package/Runtime/acceptance completion.
