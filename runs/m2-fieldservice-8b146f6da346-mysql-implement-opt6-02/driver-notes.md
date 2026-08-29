# Driver notes

This is the first valid Opt-06 sample. The candidate Skill was exported from template commit `93d20d1bb833c805e9fd80474ef36b4541b24ca4`, packaged and installed into an isolated `CODEX_HOME`, and its CLI inode and SHA-256 remained unchanged for the whole Agent process. This isolation prevents unrelated local tasks from replacing the evaluated Skill.

The CLI atomically persisted the 172,704-byte implementation packet with mode `0600` and returned a 3,242-byte envelope. The Agent used the packet path for 30 local queries, made no focused `action context` call, and made no direct `backend/model`, generated-source, or generated-package documentation query. The first static Action check passed with zero diagnostics and source finalization succeeded.

The implementation stage took 669 seconds and the outer Agent process took 744 seconds. This sample is valid baseline evidence; stability promotion is decided jointly with the independent repeat run.
