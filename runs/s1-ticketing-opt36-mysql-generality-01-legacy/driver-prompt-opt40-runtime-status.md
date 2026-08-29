继续同一 S1 checkpoint，只做 Opt40 Runtime Gate 定点复验，不执行 semantic canary 或 acceptance。Runtime 已在 `127.0.0.1:38285` 运行，正式 start 历史次数保持 1；禁止 stop/restart/start。

环境：Opt40 template commit `128d6e0ff5d8b0d64f834397a19d3e55c7d05ea4`，Plane `http://127.0.0.1:8283`，installed Skill `v0.18.0-opt40.128d6e0`。本轮进程继承与 start 相同的 `DATABASE_DRIVER=mysql` 和本地 MySQL DSN。禁止打印、echo、读取或保存 DSN/密码；只保留非敏感身份哈希。

不要修改旧的精确 `Managed Runtime starts once at 127.0.0.1:38285...` checkbox 或其历史 receipt。按 Opt40 新模板在它后面仅增加精确 pending checkbox：

`Current managed Runtime health is running, current, and HTTP-healthy on its bound loopback address; runtime-process status revalidates the same v3 managed process, delivery, binary, Runtime-manifest, and database cohort identities`

Evidence pending。刷新 Gate，确保新 current-health Gate 独立，旧 start Gate保持 passed，更宽 sessions/test-data-ready Gate保持 pending。

通过新 current-health Gate 首次且仅一次执行 installed CLI 的 `runtime-process status --project <project>`，不得使用 wrapper。要求 Gate 强类型验证并 passed；command receipt 必须包含 bounded non-sensitive `managed_runtime` proof：v3 contract、running/current/healthy/200、address、package/verification/finalization/source/runtime-manifest/binary/database driver/database identity/cohort identity；bindings/identity 必须包含当前 managed runtime cohort。核对 proof 不含 DSN、数据库路径或日志路径。

若失败，不重跑、不修复，只保留 diagnostics 停止。若通过，记录 status 命令耗时、receipt SHA、current Gate 状态后停止。禁止业务/identity API、数据库查询、acceptance prepare/run/check、semantic canary。Runtime 保持运行。
