继续同一 S1 checkpoint，只做 Opt39 verify-Gate 迁移复验与 package 节点。不要重读或重做 requirements、model、apply、implementation；不要修改 PRD、backend/model、project-owned source 或 generated source。

环境已 clean-build 为 Opt39：template commit `a013ba7a4a68e2a350ae2e57aac3296bbdffc82c`，Plane `http://127.0.0.1:8283`，版本 `v0.18.0-opt39.a013ba7`。Opt39 修复了旧合并 verify/package Gate 的证据漏洞。

先用最小只读检查确认 Plane/CLI/blueprint/source/finalization/verification identities。然后验证旧合并 Gate 现在 fail closed：只能做不会执行底层 verify/package 命令的拒绝性检查；保留该拒绝证据。

当前 session TODO 是旧模板，只迁移下面这一条已关闭的旧合并 checkbox，不改任何其他 TODO 内容：

`Current metadata checklist and live validation pass; project verification and packaging pass for the current finalized source...`

按 Opt39 `DEVELOPMENT_TODO.template.md` 的精确新文案替换为两个 pending checkbox：独立 verification Gate 和独立 packaging Gate。不要沿用旧 Gate receipt，不要 attach 另一 Gate 的 receipt。刷新/list Gate 后应得到两个不同 Gate；通过新 verification Gate 重新执行正式 `project verify --json` 一次，确认 strict v6 contract、bounded proof、non-empty runtime manifest identity、完整 passing checks。这个 6 秒级复验属于 Opt39 迁移成本，不重新打开上游节点。

verification Gate 通过后，记录当前 epoch 到 `package.started`；通过独立 packaging Gate 首次且仅一次执行正式 `project package --json`。如果失败，不猜测、不修复、不重跑，保留完整 receipt/diagnostics 并停止。若通过，确认 package Gate current/passed、v6 response contract、artifact summary proof、runtime manifest identity、package receipt/artifact identities、正式命令次数和耗时，写 `package.ended` 后停止。

禁止启动 Runtime、访问数据库、执行 acceptance 或 semantic canary。最终报告：旧 Gate fail-closed 结果、新 verify/package Gate 独立性、verify 复验与 package 结果、两个节点各自 active 秒数和正式命令次数、proof/identity/receipt SHA，以及是否发现新的通用问题。
