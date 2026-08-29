# Driver notes — opt-03 model checkpoint

This run was independently cloned from the same opt-01 `requirements-complete` checkpoint as opt-02. It did not reuse either opt-02's or this run's repaired model output. The project used a fresh empty MySQL database; its table count remained zero because the run stopped before apply.

The opt-03 documentation was materially used. Before the first formal validation, the Agent ran an explicit whole-draft Report preflight that required emission `value.key` equality, exact `join_cardinalities` keys `alias` and `cardinality`, canonical SQL paths, `ORDER BY`, and literal `LIMIT` in `1..10000`. All Report-contract diagnostic classes observed in opt-02 disappeared.

The overall model result nevertheless regressed relative to the opt-01 keep baseline. The primary validation sequence was `1→29→35→0`: one requirement-loader conflict, a 29-diagnostic batch dominated by Action payload/output `config` aliases plus identity/Workflow shapes, then a 35-diagnostic batch after a mechanical repair removed required Object-field `config`, and finally valid. Evidence gates executed one additional validation and one additional plan, producing effective totals of five validations and two plans.

The Agent started its live model timestamp 59 seconds after process launch. The declared interval is 1156 seconds; the checkpoint-comparable outer interval is 1215 seconds (`1787287429→1787288644`). This is 120 seconds / 10.96% slower than opt-01's 1095-second keep baseline, though 184 seconds faster than opt-02's adjusted 1399 seconds.

Verdict: `rework`. The Report rule direction is supported, but the batch did not meet its first-pass-valid hypothesis and cannot become the next checkpoint parent. Experimental commit `78c64670ab07448d2216897e44f769f670a69a77` and tree hash `d28b359906724b6415f87139e73812ca2cb6909fa682e1338e5f0f9dadbacc17` are retained only for audit.
