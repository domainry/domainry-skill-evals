# 评估运行协议 v2

Calibration、轮换 holdout、冻结 manifest、双分母和首轮/convergence 谱系规则见 [evaluation-protocol.md](evaluation-protocol.md)。这些规则只属于 evaluator，不得进入候选 Skill 包或其 authoring context。

## 角色分工

- **被评估 agent**:装载已冻结的当前安装 Builder Skill 副本,只拿到 `benchmarks/<b>/requirements.md`,按 Skill 流程工作。**不可见** golden-checklist、scorer、本仓库其余内容。
- **driver(评估驱动者)**:创建 run 目录、投放任务、把每次 CLI 调用经 `harness/capture.sh` 落盘、任务结束后执行金标准探针并写 `checklist-results.json`、跑 `harness/scorer.py`。

## 候选 Skill 身份与隔离

`config.json` 只配置当前安装候选 Skill 根目录、CLI 相对路径和 `apply model` 的外部服务目标。评估器不得配置、读取、构建或推断 Skill/Domainry Plane 源码仓库。

启动 Agent 前运行 `python3 harness/eval_config.py --json`，把完整输出写入 run 的 `candidate-before.json`。它验证候选目录内 `skill-identity.json`、`skill-package.json`、Skill 树哈希和 CLI 二进制哈希的闭环。随后把整个候选 Skill 复制到全新的隔离 `CODEX_HOME/skills/<skill_name>`；Agent 只能装载该副本。复制后及 Agent 结束后用 `--candidate-skill-root <isolated-copy>` 重验隔离副本，并对原安装目录再次重验；任一哈希漂移都会使 run 无效。

外部服务目标只允许 `--environment local|dev|stage|online` 或一个 HTTP(S) `--service` URL。服务不可达、版本不兼容或交付签名链不健康属于运行基础设施失败，不得归因给 Skill，也不得临时转去构建某个源码仓库。

## run 目录

```
runs/<benchmark>-<skill_version>-<NN>/
  candidate-before.json   Agent 启动前的安装候选身份闭环
  candidate-after.json    Agent 结束后的安装候选身份重验
  meta.json               benchmark、candidate_id、skill_version、run_id、
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
     "apply":        {"started": 1787122652, "ended": 1787128375},
     "verify":       {"started": 1787128375, "ended": 1787129218}
   }
   ```

   阶段键固定为当前 Skill 的四个工作阶段(requirements/model/apply/verify)；源码实现和
   `apply finalize` 都属于 apply，done 只是终态、不单独计时。不得虚构 implement 阶段。
   未经历的阶段可缺省。scorer 的 C5 读取顺序:**agent 产出的该文件 >
   runs/<dir>/stages.json(driver 手工,{stage: seconds} 形态)> 产物 mtime 近似**
   (mtime 近似会被后期演化轮覆盖产物污染,仅兜底;来源见 scorecard 的
   `C5_stage_seconds_source`:agent-stages.json / stages.json / mtime-approx)。

## 候选版本

候选主标识为 `<skill-package.version>+<skill_tree_sha256前12位>`。`skill_tree_sha256` 与 `cli_binary_sha256` 均来自包元数据并由 evaluator 对安装目录重新计算验证，不能用源码 commit、目录 mtime 或排除 CLI 的临时 tar 哈希替代。

## L1 微评估任务(见 tasks/)

L1 在隔离目录进行，只执行 `model capability` / `model plan`，分钟级、候选变化即跑。

## L3 全量流程

1. driver 运行 `python3 harness/preflight.py` 重验候选 Skill，并对 `config.json` 的外部服务目标做只读健康预检；`pass` 不为 true 时不得启动测量 run，也不启动或构建源码仓库。
2. 新建独立 `CODEX_HOME`、空 Git 项目和 SQLite cohort，复制冻结候选后投放需求，Agent 单会话执行当前五命令工作流到 done。保存 Codex JSONL 事件流，并用 `harness/extract_cli_captures.py` 提取每次 Builder CLI 调用；缺少任一当前评分 family 时不能声称 pass@1。
3. `verify` 必须返回 `verified_and_stopped`：同一个 business-flow 测试二进制在初次启动和同 cohort 重启时都通过，最终 Runtime 已停止。
4. driver 执行 benchmark checker，写 `checklist-results.json`；再运行 `python3 harness/scorer.py runs/<dir>`，归档 scorecard。

### M1 当前契约驱动验收

M1 不直接执行 `benchmarks/m1-crm/golden-probe.py` 中遗留的固定 Action、字段、身份和默认密码。driver 使用 `harness/run_m1_baseline.py --verify-result <captured-verify.json>`：它从最终签名 Runtime manifest 验证 M01-M19 的结构事实，要求项目 PRD 与测试源码同时覆盖需求中公开的 BF01-BF08，并验证当前 CLI 的初次启动与同 cohort 重启业务流均 passed、身份一致、最终 stopped。Identity 用户/组织、Runtime-owned owner 字段和场景 fixture 不要求出现在 Blueprint/manifest；它们由项目业务流通过正式测试路径证明。测试函数可在公开 BF ID 后自由命名，评估器不得依赖历史函数全名或把一个历史测试暗中映射到多个 BF。

项目与 Runtime 数据库必须在 Agent 启动前均不存在；该不存在证明写入 run freeze manifest。任何失败后的修复都创建新的 convergence run 和新的 SQLite cohort，不删除数据库伪装成原始 pass@1。

## 架构约束:数据库无关(多库可移植)

框架将来要做多数据库切换,**skill 文档、交付物、验收检查器一律不得依赖任何数据库特有能力**(如 PostgreSQL RLS)。租户隔离走 workspace 应用层(`workspace_id` 过滤)+ 声明式业务数据域。验收标准须用普通 SQL 可验的行为证明隔离,禁止要求 `rls_*`/`set_config`/security_posture 等库专有产物。检查器若违反此约束即为缺陷(见 platform-findings #17)。

验收与评分**只在 SQLite 上执行**(opt-16 起):不要求多 dialect 运行时证据,agent 不得为验收自行架设 PostgreSQL/MySQL;可移植性由代码/模型层的库无关约束保证,与单库验收正交。

## 中断恢复纪律

run 因外部原因(API 中断、断网)恢复时，只恢复同一 Agent 会话和 TODO 当前阶段；不得新建第二 TODO、重做已通过阶段或更换候选 Skill/服务目标。恢复导致候选或 freeze identity 变化时，本 run 作废并新建 convergence run。

## 对比规则

同一 benchmark、不同 skill_version 的 scorecard 逐字段对比;北极星 pass@1 变化必须伴随漏斗指标解释(哪层首过率带来的),防止巧合。

**历史 scorecard 兼容性**：只有 `scorer_schema=domainry-builder-eval-v2` 的结果可与当前候选横向比较。旧 schema 使用已删除命令或旧阶段口径，只保留审计价值，不重算、不参与当前基线。
