- Verify 结果：**passed**；Gate current/passed。
- 正式命令次数：**1**；耗时 `6474.276 ms`。
- 纯 active 时间：**60 秒**（`1787364916..1787364976`）。
- Receipt：`domainry-project-verification-receipt-v6`，SHA `5c744323…4e48e`。无顶层 `state` 字段；10/10 checks passed，diagnostics 为空。
- 身份：
  - Blueprint：`16b07de7…16af`
  - Source：`7734f14b…e6e`
  - Runtime manifest：`163be30b…27fc`
- 通用工具/Skill 问题：
  - verify Gate receipt 的 `proof` 为空。
  - Gate identity 未记录 Runtime manifest SHA。
  - Gate label 同时声明 verify/package，但仅执行 verify 即可 passed。

`verify.ended=1787364976` 已写入；未执行 package、Runtime、数据库或 acceptance。