Use the installed `domainry-builder-v1` Skill and its packaged CLI from exact Application Delivery `v0.18.0-opt72.d9d0874`, template commit `d9d0874496adbbd89e90f59a8582f7b3b88d3530`, and Plane `http://127.0.0.1:8283`. Use `gpt-5.6-sol` with high reasoning.

This is an explicitly authorized `source-finalization-continuation` on the existing M1 project. The prior Agent/session `01a02b3f-80a1-7963-8e0f-95de50b8a717` has definitively ended. Upstream requirements/model/Report SQL/Opt72 atomic promotion and the current project-owned Action source are accepted and frozen. The current checkpoint is expected to be live delivery `sha256:4d249113d044b08698c733db486ebda84b1fa93859823922ea0ed0eafedbee64`, materialization receipt `f63ae295a4250278b29e30e55c3d86fe489be67b76f07a41d018c836e39c2558`, and atomic-apply finalization receipt `c195d0b46382755c5ed0b47548711c58ab42541cbe00577ebd51a9828acedef0`.

Load the full installed `SKILL.md`, but do not load `references/development-guide.md`, `assets/DEVELOPMENT_TODO.template.md`, or any whole-project reference. Invoke the compact resolver exactly once with:

```sh
"$SKILL_ROOT/bin/domainry-development-context.py" \
  --project "$PROJECT_ROOT" \
  --profile source-finalization-continuation \
  --focused-test-package ./actions/crm
```

Use only the new continuation session/TODO and the exact three Gate recipes returned by that resolver, in order:

1. valid canonical Actions `project check`;
2. `project source finalize`;
3. module-focused Go test for `./actions/crm`.

Do not invent, expand, replace, repeat, or supplement those recipes. Do not edit any project-owned, generated, domain, model, requirements, Report, or test file. If any Gate is invalid, stale, blocked, or terminal-failed, preserve its complete bounded evidence and stop without retry or repair. Do not run model commands, capability discovery, source prepare, project verify/package, Runtime, database, acceptance, evaluator, or scorer. Do not use SQLite or MySQL in this node.

Report wall/active time and model usage; resolver/command counts and durations; new session/Gate/receipt identities; exact frozen checkpoint verification; check/finalize/test results; any remaining source gap; and the exact next node. Do not claim Runtime readiness, acceptance, project verification, or completion.
