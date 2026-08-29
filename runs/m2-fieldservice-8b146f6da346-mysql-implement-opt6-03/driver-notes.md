# Driver notes

This independent repeat uses the exact same template commit, packaged Skill, CLI binary, driver prompt, post-apply checkpoint, model, reasoning effort, and isolated `CODEX_HOME` as the valid Opt-06 candidate. The project copy, Agent session, and local MySQL database are fresh.

Protocol and functional results reproduced exactly: one source prepare call, the same content-addressed packet SHA and byte count, no focused Action context, no direct model/generated query, first static check with zero diagnostics, and successful finalization. Stage time was 550 seconds and outer time was 657 seconds.

The repeat is 17.8% faster than the first valid sample at the stage boundary, narrowly outside the strict 15% pairwise timing band, while outer time and tokens remain within 15%. Both samples remain within 15% of the previous protocol-valid Opt-05 stage baseline. Opt-06 is therefore promoted as an aggregate range rather than a single-run point estimate.
