Use the installed `domainry-builder-v1` Skill through its caller-explicit `source-finalization-continuation` route. Upstream requirements/modeling are accepted and frozen. The current source finalization checkpoint is valid with tree SHA `acea255d2b83f2a44633afd03a21aa83daee1a47e803eccb8b9dc793d93338d2`.

Resolve the compact continuation envelope exactly once with focused Go test package `./actions/ticketing` (the envelope executes tests with `cwd backend`, so this backend-relative path is intentional). Execute the returned three Gate recipes strictly in order. Stop after the three Gates and report their durations/counts, current identities, Git status, and the next exact `project verify` node.

Do not load whole-project resources. Do not run source prepare, model validate/apply, project verify/package, Runtime, canary, or acceptance. Do not inspect the parent evaluation repository or sibling runs, and do not edit source or managed state outside the returned Gate recipes.
