继续同一 S1 implementation checkpoint。安装包与 Plane 现已升级为 clean-build Opt38：template commits `8ded6af936641c6c717ccbbfe1d4119821a381b2` + `41d47dd762b0c4fdece838d658ed880545bc0e4b`，版本 `v0.18.0-opt38.41d47dd`。

不要重读或重做任何上游业务工作。先核对 Opt38 身份与 Gate runner 的默认 `PROJECT_CHECK_CONTRACT`；当前 clean CLI 实际 response contract 是 `domainry-builder-v6-project-check-v1`，而 `version --json` 的 `domainry-project-check-v2` 是 capability 广告，不是这次 response expectation。使用 Opt38 新默认/recipe，不要显式误传 capability v2。

从同一未变 source 定点复验 check Gate；要求底层 exit 0/state valid 且 Gate passed，receipt `proof.project_check` 有正确 contract/state/issue_count/diagnostics。通过后继续 conditional-mutation 静态 Gate、正式 source finalize、Gate-run focused Go test；若源码变化，遵循 check/finalize 重绑。完成写 `implement.ended`，停在 `source-finalized + focused-test-passed`；不要 verify/package/Runtime/database/acceptance。

第二段工具暂停从 `1787364162` 到本轮实际恢复 epoch，不计入 implement active time。最终报告 Opt38 定点结果、proof、finalization SHA、test 结果、总 active implement 耗时，以及两条 template commit。
