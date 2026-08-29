Build the complete backend system specified in `requirements.md` and carry it autonomously through the installed Domainry Builder Skill's full workflow to its truthful terminal state.

Execution constraints:

- The only business requirement input is `requirements.md` in the current project root. It is final and contains no unresolved user decision; do not ask the user questions.
- Load and follow the host-installed Skill at `/Users/tiger/.codex/skills/domainry-builder-v1/SKILL.md`. Resolve and use only that installed package's CLI. Domainry Plane is available at `http://127.0.0.1:8283`.
- This is a fresh full implementation batch. The project has no delivered frontend; do not create frontend source. Implement both declared product Surfaces at the backend/Runtime contract boundary.
- Do not inspect the parent evaluation repository, any `benchmarks`, `golden`, `scorer`, `harness`, previous run, scorecard, framework source checkout, or hidden assertion. Do not use prior deliveries or old evidence. Standard system toolchains/module caches and the installed Skill are allowed.
- This run is explicitly required to use the isolated local MySQL service supplied through the inherited `DATABASE_DRIVER=mysql` and `DATABASE_DSN` environment. All Runtime, packaging, verification, and acceptance commands must preserve those variables. Do not start or fall back to SQLite, do not create a `.db` acceptance database, and do not replace or clear the supplied MySQL database outside the installed Skill's normal fresh-project workflow.
- Maintain `.domainry/development/stages.json` in real time. Use epoch seconds and exactly these stage keys when entered: `requirements`, `model`, `apply`, `implement`, `verify`, `acceptance`; each stage records `started` and `ended`.
- Use fresh project-local identities/data and the formal Runtime Principal Context Resolver. Never construct Runtime-owned principal/profile/scope headers or query Runtime-owned identity tables.
- Run the platform acceptance runner first, then build only the thin business assertions required for skipped cases on top of the installed `acceptance-harness-core.py`.
- Keep the final managed Runtime running and healthy for independent post-delivery acceptance. Do not stop it during cleanup.
- Finish with a concise factual terminal report. Claim `done` only if the installed Skill's evidence gates and exact acceptance denominator actually permit it; otherwise report the precise terminal failure classification and blockers.
