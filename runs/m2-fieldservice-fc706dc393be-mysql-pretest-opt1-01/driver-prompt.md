Use the installed `domainry-builder-v1` Skill to implement the backend described by `requirements.md` in this fresh project.

This is a staged pre-test evaluation. Complete only these stages, in order:

1. requirements and domain truth;
2. capability discovery plus complete model authoring, `model validate`, and `model plan`;
3. one `model apply` against the pinned local Plane, including materialization;
4. implement every generated project-owned Handler, run the required static Action check, and successfully finalize source.

Stop immediately after clean source finalization. Do not run Go tests, `project verify`, `project package`, a Runtime process, acceptance prepare/run/check, evaluator probes, or any golden/scorer command. Do not claim the complete delivery is done; report the truthful pre-test checkpoint.

Use the inherited local MySQL environment for the entire run. Do not use or create SQLite. Do not print, rewrite, or persist the database DSN. Use the pinned local Domainry Plane at `http://127.0.0.1:8283` wherever a target is required.

Maintain `.domainry/development/stages.json` in real time with epoch-second `started` and `ended` fields and exactly these applicable stage keys: `requirements`, `model`, `apply`, `implement`. Start and end a stage at the actual boundary; never reconstruct the timestamps afterward.

`requirements.md` is the sole business-requirement input. Do not inspect the parent evaluation repository, any `benchmarks`, `golden`, `scorer`, historical run, or candidate-Skill source repository. Do not modify the requirement, prompt, evaluator assets, golden rules, scorer, or installed Skill. Use fresh project-local identities and data. Do not ask for human clarification; preserve unresolved non-critical assumptions explicitly and stop on a truly critical unresolved decision.
