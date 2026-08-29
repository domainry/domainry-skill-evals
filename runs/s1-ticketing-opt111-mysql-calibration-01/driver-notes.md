# S1 Opt111 calibration driver notes

The candidate delivery completed the installed five-stage workflow in one Agent session with zero human repair. Its unique TODO reached `done` with 32/32 checks and no unresolved applicable row. The final project-owned verification evidence reports BF01-BF10 10/10 and a restart replay of the highest-risk BF02 canary against MySQL.

The frozen evaluator could not produce golden outcomes. `benchmarks/s1-ticketing/golden-probe.py` imports `sqlite3`, queries `sqlite_master`, accepts a SQLite DB path, and assumes a legacy password lifecycle. The run was frozen for MySQL and the managed Runtime rotates a development credential; after the delivery's forced-password-change flow, the probe aborted during login before calling `record()` for F01-F16. This is classified as `benchmark_defect`.

The frozen oracle and scorer were not changed. All 16 benchmark rows remain present as `not_executed`; project BF cases do not replace them. The legacy scorer consequently serializes `pass_at_1=false`, `B1=0.0`, and `A6_false_done=true`. For this run those fields are invalid fallbacks rather than observed candidate failures; candidate pass-at-1 is not measurable.

Useful process observations remain valid: 33 minutes 6 seconds outer wall time, zero human interventions, 19,704,293 total tokens (19,200,256 cached input), successful final structure/package, healthy final Runtime, and the repair inventory in `failures.json`.
