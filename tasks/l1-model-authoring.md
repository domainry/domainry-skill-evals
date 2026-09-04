# L1 微评估:建模一次成型(model-authoring)

**目标指标**:A1_plan_first_pass、A1_plan_error_count、C2、C3。
**假设关联**:Skill 的 backend-model 契约/示例质量直接决定本任务分数。

## 流程(driver 执行)

1. 建隔离目录 `runs/l1-model-<skill_version>-<NN>/project/`,`git init`,放入 `benchmarks/s1-ticketing/requirements.md`。
2. 投放给被评估 agent 的任务指令(逐字):

   > 你已装载环境中由 Builder Skill 身份清单解析出的当前 Skill。请针对 project/ 下的 requirements.md,只完成到「authoring backend/model/*.json」为止:完成需求梳理与领域决策后,编写完整的 backend/model/*.json。不要执行 model apply。写完后停止。

3. agent 停止后,driver 执行(首次调用即评分点):

   ```bash
   harness/capture.sh <run_dir> model_plan -- \
     "<skill_root>/bin/domainry-cli" model plan --json --project <run_dir>/project
   ```

4. 若首次 plan 有错,把完整错误 JSON 回投给 agent 修复,重复 plan 直至通过或 3 轮上限(记录 A6)。
5. 对最终 model 文件做金标准结构核对(golden-checklist 的 F01/F02/F06/F09/F10/F13/F16 可静态判定:对象/状态机/授权/关系/报表/种子是否建模),写 `checklist-results.json`(status 用 pass/missing,本任务不跑 Runtime,故无行为探针)。
6. `python3 harness/scorer.py <run_dir>`。

## 变体

- `l1-model-repair`:由 evaluator 自有 fixture 投放预埋缺陷的 model + plan 诊断输出，考察 ≤1 轮修复率；fixture 不从 Skill 或 Plane 源码仓库读取。
