# 评估运行协议 v1

Calibration、轮换 holdout、冻结 manifest、双分母和首轮/convergence 谱系规则见 [evaluation-protocol.md](evaluation-protocol.md)。这些规则只属于 evaluator，不得进入候选 Skill 包或其 authoring context。

## 角色分工

- **被评估 agent**:装载指定版本的 Builder Skill,只拿到 `benchmarks/<b>/requirements.md`,按 Skill 流程工作。**不可见** golden-checklist、scorer、本仓库其余内容。
- **driver(评估驱动者)**:创建 run 目录、投放任务、把每次 CLI 调用经 `harness/capture.sh` 落盘、任务结束后执行金标准探针并写 `checklist-results.json`、跑 `harness/scorer.py`。

## run 目录

```
runs/<benchmark>-<skill_version>-<NN>/
  meta.json               benchmark、skill_version(Skill 包内容短哈希)、run_id、
                          agent_declared_done、human_interventions、started/ended_epoch
  cli/NNN-<family>.json   capture.sh 工件(family 见 capture.sh 头注)
  tokens.json             可选:total_tokens / reading_tokens(读 Skill 文档的消耗)
  stages.json             可选:各阶段秒数(driver 手工;优先级低于 agent 产出的
                          project/.domainry/development/stages.json,见「投放提示要求」)
  checklist-results.json  金标准探针结果(driver 执行,禁止采信 agent 自述)
  failures.json           失败归因(owner ∈ skill_doc|skill_tooling|cli_platform|model_capability|benchmark_defect)
  scorecard.json          scorer.py 产出
```

## 投放提示要求

driver 投放任务提示时,除需求文本外**必须**附带以下要求(不泄露金标准/评分细节):

1. **阶段计时**:要求 agent 在项目目录维护 `.domainry/development/stages.json`,
   进入/离开每个阶段时实时写入 epoch 秒:

   ```json
   {
     "requirements": {"started": 1787117118, "ended": 1787118000},
     "model":        {"started": 1787118000, "ended": 1787122652},
     "apply":        {"started": 1787122652, "ended": 1787122716},
     "implement":    {"started": 1787122716, "ended": 1787128375},
     "verify":       {"started": 1787128375, "ended": 1787129218}
   }
   ```

   阶段键固定为 scorer 的 C5 五阶段(requirements/model/apply/implement/verify);
   未经历的阶段可缺省。scorer 的 C5 读取顺序:**agent 产出的该文件 >
   runs/<dir>/stages.json(driver 手工,{stage: seconds} 形态)> 产物 mtime 近似**
   (mtime 近似会被后期演化轮覆盖产物污染,仅兜底;来源见 scorecard 的
   `C5_stage_seconds_source`:agent-stages.json / stages.json / mtime-approx)。

## skill_version 计算

```bash
tar --sort=name --mtime='UTC 2020-01-01' --owner=0 --group=0 --numeric-owner \
  -cf - -C <skill_root> --exclude bin . | sha256sum | cut -c1-12
```

排除 `bin/`(33MB 二进制,其版本单独记录),只对文档/模板/脚本内容取哈希,保证「改一行文档=新版本」。**2026-08-18 起改用上面的确定性 tar**:旧命令把 mtime/属主算进哈希,git checkout 重写时间戳就会翻哈希(实测 opt-13 内容不变、哈希 5287d3b722c2→4c2672e427be)。历史 scorecard 的旧式哈希仅作标签;opt-13 内容的确定性哈希 = `5e675d34e423`。

## L1 微评估任务(见 tasks/)

L1 在无 Plane 的隔离目录进行,只用 CLI 的本地命令(validate/plan),分钟级,改动即跑。

## L3 全量流程

1. driver 起本地 Domainry Plane(在 plane 仓库,`scripts/builder/domainry-plane-control.sh start`);评估库不依赖其代码,只依赖 `config.json` 里的路径与地址。
2. 新建空项目目录 → 投放需求 → agent 全流程到 done。
3. driver 对运行中的 Runtime 逐条执行 golden probe,写 `checklist-results.json`。
4. `python3 harness/scorer.py runs/<dir>` 产出 scorecard,归档到 `scorecards/`。

### M1 当前契约驱动验收

M1 不再直接执行 `benchmarks/m1-crm/golden-probe.py` 中遗留的固定 Action、字段、
身份和默认密码。driver 必须使用 `harness/run_m1_baseline.py`:它从最终签名 Runtime
manifest 验证 M01-M19 的结构事实,在执行前要求 SQLite `lead` 行数与冻结 seed 数精确
相等,然后运行 BF01-BF08 并按代码内固定映射生成 `checklist-results.json`。缺少 manifest
事实、缺少业务流、业务流失败或复用受污染 cohort 均 fail closed。压力/边界 fixture 不得
与下一轮基线共享数据库。

## 架构约束:数据库无关(多库可移植)

框架将来要做多数据库切换,**skill 文档、交付物、验收检查器一律不得依赖任何数据库特有能力**(如 PostgreSQL RLS)。租户隔离走 workspace 应用层(`workspace_id` 过滤)+ 声明式业务数据域。验收标准须用普通 SQL 可验的行为证明隔离,禁止要求 `rls_*`/`set_config`/security_posture 等库专有产物。检查器若违反此约束即为缺陷(见 platform-findings #17)。

验收与评分**只在 SQLite 上执行**(opt-16 起):不要求多 dialect 运行时证据,agent 不得为验收自行架设 PostgreSQL/MySQL;可移植性由代码/模型层的库无关约束保证,与单库验收正交。

## 中断恢复纪律

run 因外部原因(API 中断、断网)恢复时:**禁止全量重读 skill 文档**——只按当前阶段读对应 reference;已 passed 的门禁证据不重跑不重绑。违反视为 driver 侧成本缺陷记入 driver-notes(先例:opt-12 恢复会话全量重读耗 ~448k token,opt-14 中断后同名门禁证据重绑 3-4 次)。

## 对比规则

同一 benchmark、不同 skill_version 的 scorecard 逐字段对比;北极星 pass@1 变化必须伴随漏斗指标解释(哪层首过率带来的),防止巧合。

**历史 scorecard 兼容性**:标注 `"scorer_schema": "pre-2026-08-18"` 的归档 scorecard(l2-pipeline-9e99138bb008-01、e2e-8e1d3895f3e3-01)由旧版 scorer 产出,A2(无 designed-handoff 豁免)/A5/C4(旧返工计法)与现行字段语义有漂移且输入不可复现、不重算;逐字段对比时这三项差异不作回归判定。
