# Driver notes

This is the fair fresh-Agent parent control for Opt-05. It uses the exact candidate parent commit, the same immutable Opt-01 `post-apply` checkpoint, the same `gpt-5.6-sol/high` configuration, and a separate fresh local MySQL database.

The parent made 17 effective `action context` invocations: eight in the first all-Action loop, eight individual re-queries, and one additional focused re-query. Its first static check reported three issues; a repair made the check valid and source finalization succeeded.

The run reached the same implementation checkpoint as the candidate in 757 stage seconds and 826 outer seconds, using 5,197,700 input tokens. It is valid as the causal parent control.
