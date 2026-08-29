继续当前 S1 implementation 节点，复用现有 requirements/model/delivery/materialization/implementation source；不要重做任何上游阶段。

Driver 已将安装包与 Plane 升级到独立提交 `8ded6af936641c6c717ccbbfe1d4119821a381b2`，版本 `v0.18.0-opt37.8ded6af`。该提交只修复 Gate runner 的 project-check contract 与失败诊断 proof，不改变 S1 业务模型或现有源码。请先验证新 Skill/CLI 身份并读取新 Gate runner 的直接相关契约说明，禁止全量重读 requirements/model/PRD/能力分类。

从当前 source checkpoint 定点执行：

1. 用 Opt37 Gate runner 包装正式 `project check --json --scope actions`。当前 source 的底层 check 已知应 exit 0/state valid；验证 Gate 本身也能 passed，proof 保存正确 contract/state/issue_count。
2. 若 check 仍返回业务诊断，必须直接从新 receipt 的结构化 diagnostics proof 读取并一次批修，验证不再依赖 Driver 转述。
3. check passed 后执行 conditional-mutation 静态 Gate、正式 source finalize、然后通过 Gate 首次执行 focused Go test。按 source 变化规则保持 check/finalize identity current。
4. 完成后写 `implement.ended`，停在 `source-finalized + focused-test-passed`；禁止 verify、package、Runtime、数据库和 acceptance。

保留并报告历史轨迹：Opt36 check 前三次因诊断不可读失败、一次 Driver correction；业务修复后底层 exit 0 但旧 Gate contract mismatch；Opt37 定点复验结果。报告 Opt37 receipt proof、finalization SHA、test 命令/结果、总 implement 纯耗时；不要把等待 template 修复的停顿计入 implement active time，请在阶段记录或报告中单独列出 pause interval `1787363160..1787363970`（若实际恢复 epoch 不同，以恢复时即时 epoch 为准）。
