继续同一 S1 checkpoint，只执行 verify 节点。当前已经 source-finalized 且 focused test passed；不要重读或重做 requirements、model、apply、implementation，也不要修改 PRD、backend/model、project-owned source 或 generated source。

环境固定为 clean-build Opt38：template commits `8ded6af936641c6c717ccbbfe1d4119821a381b2` + `41d47dd762b0c4fdece838d658ed880545bc0e4b`，Plane `http://127.0.0.1:8283`，版本 `v0.18.0-opt38.41d47dd`。先用最小只读核对确认当前 blueprint/source/finalization 身份和 Plane health，不做上游广泛重读。

将当前 epoch 写入 `verify.started`，然后严格按 installed Skill 的 verify recipe，通过对应 Development Gate 执行正式 `project verify`。只允许该节点要求的只读验证和证据读取；若验证失败，不要猜测或扩展修复，直接保留完整 receipt/diagnostics 并停止报告，因为本轮目标是定位 verify 节点的优化空间。若验证通过，确认 Gate current/passed、receipt contract/state、命令次数、耗时和绑定身份，写 `verify.ended` 后立即停止。

禁止 package、Runtime、数据库、acceptance；禁止从头开始。最终只报告 verify 节点结果、纯 active 秒数、命令次数、receipt/diagnostics、blueprint/source/runtime-manifest identities，以及是否发现通用工具或 Skill 问题。
