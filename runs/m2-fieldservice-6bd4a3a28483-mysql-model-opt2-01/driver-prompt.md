Use the installed `domainry-builder-v1` Skill to continue the backend described by `requirements.md` from the supplied immutable requirements-complete checkpoint.

This is a stage-reuse evaluation of model authoring only. `requirements.md` and `docs/backend-requirements-prd.md` are already accepted parent-checkpoint outputs: do not re-run requirements discovery, rewrite them, or restart from the original requirements stage.

Complete only the model stage:

1. start the live `model` timestamp;
2. perform capability discovery and author the complete backend model plus source-owned report SQL;
3. run `model validate` only after the complete inventory and required preflight are finished;
4. repair any complete diagnostic batch, if needed;
5. run `model plan` after validation is valid and close the model-stage evidence gates;
6. end the live `model` timestamp and stop.

Do not run `model apply`, source preparation or implementation, Go tests, `project verify`, `project package`, a Runtime process, acceptance prepare/run/check, evaluator probes, or any golden/scorer command. Do not claim the complete delivery is done; report only the truthful model-valid checkpoint.

Use the inherited local MySQL environment. Do not use or create SQLite. Do not print, rewrite, or persist the database DSN. The pinned local Domainry Plane is `http://127.0.0.1:8283`, but this stage must not publish or apply anything.

Maintain `.domainry/development/stages.json` in real time with epoch-second `started` and `ended` fields for exactly the `model` stage. Do not add a reconstructed requirements timestamp.

The checkpoint files are the sole business input. Do not inspect the parent evaluation repository, any `benchmarks`, `golden`, `scorer`, historical run, candidate-Skill source repository, or checkpoint sibling. Do not modify the requirement, accepted PRD, prompt, evaluator assets, golden rules, scorer, or installed Skill. Do not ask for human clarification; preserve unresolved non-critical assumptions explicitly and stop on a truly critical unresolved decision.
