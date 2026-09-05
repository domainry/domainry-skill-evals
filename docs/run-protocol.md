# 评估运行协议 v3

Calibration、轮换 holdout、冻结 manifest、双分母和首轮/convergence 谱系规则见 [evaluation-protocol.md](evaluation-protocol.md)。这些规则只属于 evaluator，不得进入候选 Skill 包或其 authoring context。

## 角色分工

- **被评估 agent**:装载已冻结的当前安装 Builder Skill 副本,只拿到 `benchmarks/<b>/requirements.md`,按 Skill 流程工作。**不可见** golden-checklist、scorer、本仓库其余内容。
- **driver(评估驱动者)**:创建 run 目录、投放任务、把每次 CLI 调用经 `harness/capture.sh` 落盘、任务结束后执行金标准探针并写 `checklist-results.json`、跑 `harness/scorer.py`。

## 候选 Skill 身份与隔离

`config.json` 只配置当前安装候选 Skill 根目录、CLI 相对路径和 `apply model` 的外部服务目标。评估器不得配置、读取、构建或推断 Skill/Domainry Plane 源码仓库。

统一 driver 从 `--candidate-config` 解析安装候选，验证目录内 `skill-identity.json`、`skill-package.json`、Skill 树哈希和 CLI 二进制哈希闭环，并写入 `candidate-before.json`。它随后把完整候选复制到新建的 `<isolation-root>/codex-home/skills/<skill_name>`，复制后再次闭环验证。Agent 结束后同时生成 `candidate-after.json` 与 `candidate-isolated-after.json`；原目录或隔离副本任一身份、树或 CLI 哈希漂移，run 均以 `environment_invalid_candidate_drift` 作废。

`--isolation-root` 必须在启动前完全不存在、位于 evaluator 仓库和 run 目录之外。driver 在其中创建且仅创建独立 Agent HOME、独立 CODEX_HOME、临时目录、空的无提交 Git project 和 Runtime 目录；`runtime/cohort.sqlite` 及其 WAL/SHM 在 Agent 启动前必须不存在。发现旧 project、`.domainry`、SQLite、Agent history、TODO 或任何非候选 CODEX_HOME 内容都会拒绝启动。

真实 `codex` 入口需要认证时，driver 默认只读取调用方 `CODEX_HOME/auth.json`，也可用
`--auth-source <trusted-auth.json>` 显式指定。它只解析并以 `0600` 权限暂存这一份 JSON 到隔离
CODEX_HOME；history、thread/session DB、memory、log、state、queue、skills 和普通 config 一律
不复制。认证内容、hash 和来源路径不写入 freeze、日志、scorecard 或错误消息。Agent 无论正常
结束、失败或预算终止后都会立即删除隔离 `auth.json`；清理失败使用
`environment_invalid_auth_cleanup` 作废 run。没有可用认证的真实 Codex 入口在创建 isolation 前
fail-fast。

外部服务目标只允许 `--environment local|dev|stage|online` 或一个 HTTP(S) `--service` URL。服务不可达、版本不兼容或交付签名链不健康属于运行基础设施失败，不得归因给 Skill，也不得临时转去构建某个源码仓库。

对 `--service` 目标，driver 自身在 Agent 前后各执行一次与 `harness/preflight.py` 相同的只读
`/health` 检查。启动前必须 healthy 且至少披露 Application Delivery、Runtime contract/module、
project template、Runtime client、Skill packages 和 project-delivery trust 检查。freeze 保存健康
文档的规范 hash 及服务公开的 version、manifest/module/closure、Runtime API/authoring contract、
template/client/package hash 和 trust identity 等稳定字段；不保存认证或服务源码路径，也不向
Agent 传递该快照。结束后任何字段或健康状态漂移均为
`environment_invalid_service_drift`，checker 不执行。

## run 目录

```
runs/<benchmark>-<skill_version>-<NN>/
  candidate-before.json   Agent 启动前的安装候选身份闭环
  candidate-isolated-before.json 隔离副本的启动前身份闭环
  candidate-after.json    Agent 结束后的安装候选身份重验
  candidate-isolated-after.json 隔离副本的结束后身份重验
  freeze-manifest.json    不存在证明、候选身份、模型/预算和 prompt/checker/scorer hashes
  meta.json               benchmark、candidate_id、skill_version、run_id、
                          run_kind、parent_run_id、terminal_state、measurement_complete、
                          project_path、agent_declared_done、human_interventions、started/ended_epoch
  lifecycle.json          driver 状态、冻结预算、使用量、停止原因、首次评分失败
  progress.json           driver 原子刷新的实时派生状态（不参与评分）
  cli/NNN-<family>.json   capture.sh 工件(family 见 capture.sh 头注)
  tokens.json             可选:total_tokens / reading_tokens(读 Skill 文档的消耗)
  stages.json             可选:各阶段秒数(driver 手工;优先级低于 agent 产出的
                          project/.domainry/development/stages.json,见「投放提示要求」)
  checklist-results.json  金标准探针结果(driver 执行,禁止采信 agent 自述)
  failures.json           失败归因(owner 可含 CLI diagnostic 原始 domainry-cli，或 evaluator 归类的
                          skill_doc|skill_tooling|cli_platform|model_capability|benchmark_defect)
  scorecard.json          scorer.py 产出
```

## 统一 driver 与运行终态

使用 `harness/run_driver.py` 启动可测 Agent，而不是把“持续修复”留给通用提示词。命令以
JSON argv 数组传入，不经过 shell。Agent 命令必须使用 `{model}` 与 `{prompt}`（需求和 driver
policy 的完整文本），可使用 `{project}`、`{database}`、`{candidate_cli}`，但禁止
`{run_dir}`、`{prompt_path}`、`{verify_result}`、`{flow_evidence}` 以及任何
resume/continue/session 参数。checker 可使用 `{checker}`、`{project}`、`{run_dir}`、
`{database}`、`{verify_result}` 和 `{flow_evidence}`。driver 会生成最终 `agent-prompt.md`，实时保存
JSONL，按事件提取 CLI 捕获，然后运行 checker 与 scorer。

只有实际执行 `model capability`、`model plan`、`apply model`、`apply finalize` 或 `verify` 的
Domainry CLI argv 才进入 scoring capture、首败、重试与 C4/progress 计数。`--help`、`-h`、
`help`、`--version`、`version` 等 metadata 调用只是 auxiliary observation，即使写成
`domainry-cli verify --help` 也不得冒充一次成功 verify。识别按 shell argv 的独立 token 进行；
普通参数文本或路径中包含 `--help` 字样不会隐藏真实执行。

```bash
python3 harness/run_driver.py \
  --run-dir runs/<new-run-id> --isolation-root /tmp/<unique-new-isolation-root> \
  --benchmark m1-crm --run-id <new-run-id> \
  --candidate-config config.json --model <exact-model-id> \
  --mode baseline --prompt <base-prompt.md> \
  --budget-wall-seconds 3600 --budget-total-tokens 5000000 \
  --budget-cli-invocations 20 --budget-cli-retries 0 \
  --agent-command-json '["codex","exec","--json","--model","{model}","{prompt}"]' \
  --checker-source harness/run_m1_baseline.py \
  --checker-command-json '["python3","{checker}","--project","{project}","--run-dir","{run_dir}","--database","{database}","--verify-result","{verify_result}","--flow-evidence","{flow_evidence}"]'
```

`baseline` 不得带 parent；任一评分 family 首次失败后 driver 强制停止 Agent，不等待其自主
收敛。`convergence` 必须显式使用 `--mode convergence --parent-run-id <baseline-or-prior-run>`，
允许在预算内重试，但 `pass_at_1_eligible=false`。主要终态：

run 目录不得预置 freeze、候选身份或任何 measured-run 工件；isolation root 更不得预先存在。
driver 建立并验证这两棵独立目录，拒绝复用或覆盖。

- `completed` / `acceptance_failed`：测量边界完整，后者为完整但未通过；
- `baseline_first_scoring_failure`：首个评分命令失败后已截断；
- `budget_exhausted_wall_clock|tokens|cli_invocations|cli_retries`：预算截断；
- `delivery_incomplete`：Agent 正常退出但显式报告 `not_done`，或完整评分交付前置条件未满足；
- `agent_process_failed|invalid_agent_event_stream|acceptance_not_executed|scorer_failed`：运行器终态。
- `invalid_agent_session_context`：缺少唯一新 session、同一 run 出现多个 session 或 session 已被历史 run 使用；
- `environment_invalid_candidate_drift|environment_invalid_freeze_drift`：候选或冻结输入在运行中漂移。
- `environment_invalid_auth_cleanup`：临时认证材料未能按策略清理；
- `environment_invalid_service_drift`：Application Delivery/Runtime 服务身份或健康状态在运行中变化；
- `flow_evidence_conflict|flow_evidence_archive_drift`：verify、兼容外部证据或归档副本不一致。

只有 `completed` 或 `acceptance_failed` 的 `measurement_complete=true`。
checker 仅在 Agent 最终结构化结果为 `done`，且 model plan、apply model、apply finalize 和 verify
的最新 capture 均成功、verify 明确为 `verified_and_stopped`、checker 所需 verify/evidence 工件
可解析时运行。`EVAL_RESULT={"state":"not_done"}` 永远不放行 checker；此时终态为
`delivery_incomplete`，未发生的漏斗阶段和 A5 保持不可测，不伪装成 acceptance 失败。
`baseline_first_scoring_failure` 额外记录 `environment_valid=true` 与
`measurement_boundary=baseline_first_failure_sealed`，表示首败边界按设计完成封存，而不是环境
不完整。若首败发生在 verify 之前且没有 verify capture，driver 不执行 checker，而是写入
`checklist-results.json` 的 `status=not_executed`；此时验收首过率不可测，不得把缺少 Runtime
产物误记为验收失败。driver 即使提前停止，
也必须保留 `agent-events.jsonl`、已完成的 `cli/*.json`、checker stdout/stderr 或失败占位结果、
`failures.json`、`meta.json`、`lifecycle.json` 和 `scorecard.json`。首个失败 CLI capture 若含
结构化 `diagnostics`，driver 按每条 diagnostic 保留 owner、stage、code/message 和诊断事实。
CLI capture 的混合输出只接受独立的完整 JSON 文档，并优先选择带 contract 的 envelope；不得
扫描 JSON 字符串或人类诊断文本内部的 `{`/`[` 片段，也不得因尾部 `reports[1]`、issue 数字等
内容覆盖 envelope。若首败评分 capture 没有可用 diagnostics，但含结构化
`output.telemetry.first_failure`，则从该对象保留 owner、stage/name、elapsed_ms，同时保留外层
state/error 与完整 telemetry。归因只能读取已封存的首个失败 capture，不读取后续 capture，也不从
自由文本猜测责任方。CLI 自报 owner 时不得降级为 unattributed。只有结构化 owner 确实缺失的
driver 失败才用 `owner:null, attribution_status:pending` 保存。

Codex JSONL 没有任何 usage snapshot 时，`usage.total_tokens` 与 scorecard `C2_total_tokens` 保持
null，且不生成 `tokens.json`；不得根据事件数、运行时间或截断位置估算 Token。

## 实时进展工件

Agent 运行期间 driver 持续以同目录临时文件加 `os.replace` 原子更新 `progress.json`，契约为
`domainry-eval-progress-v1`。读者任何时刻都应看到完整旧版本或完整新版本，不会看到半写 JSON。
该文件只从已经接收的 Agent JSONL、Domainry CLI started/completed 事件、Agent 明确维护的
`.domainry/development/stages.json`、driver 生命周期和最终 scorecard 派生，绝不成为 checker 或
scorer 输入，因此不改变评分语义。

它包含 evaluator lifecycle phase（agent/checker/scorer/terminal）及起止时间、当前 Delivery
stage 及 requirements/model/apply/verify 的已观测时间、wall elapsed、Domainry CLI 调用/完成/
失败/重试计数、最近子命令状态、Agent 最后事件接收时间、首败封存状态、checker 是否获准执行，
以及终态 scorecard 摘要。Agent 提供的阶段 epoch 必须全部处于 Agent 生命周期边界内并按
requirements→model→apply→verify 单调且互不重叠；违反时整组阶段时间记为不可测，并用
`delivery_stage_timing_status` 保留具体 invalid 原因。事件或阶段文件没有提供的值为 `null` 并标为 `unavailable`；尤其不从
墙钟或事件数量估算 Token。Agent 异常、预算终止和 baseline 首败也会在封存路径结束时写最终
terminal progress，正常完成时 `lifecycle_state` 与 `lifecycle.json`、scorecard 摘要与
`scorecard.json` 一致。

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
2. driver 证明 isolation root、项目和 SQLite 均不存在，再创建独立 `CODEX_HOME`、空 Git 项目和 SQLite cohort 路径，复制冻结候选后仅投放需求与 driver policy。Agent 必须以事件流中的唯一新 `thread_id` 单会话执行当前五命令工作流到 done；缺少 session 证据或复用历史 `thread_id` 时 run 无效。保存 Codex JSONL 事件流，并用 `harness/extract_cli_captures.py` 提取每次 Builder CLI 调用；缺少任一当前评分 family 时不能声称 pass@1。
3. `verify` 必须返回 `verified_and_stopped`：同一个 business-flow 测试二进制在初次启动和同 cohort 重启时都通过，最终 Runtime 已停止。
4. driver 执行 benchmark checker，写 `checklist-results.json`；再运行 `python3 harness/scorer.py runs/<dir>`，归档 scorecard。

### M1 当前契约驱动验收

M1 不直接执行 `benchmarks/m1-crm/golden-probe.py` 中遗留的固定 Action、字段、身份和默认密码。driver 使用 `harness/run_m1_baseline.py --verify-result <captured-verify.json>`：它从最终签名 Runtime manifest 验证 M01-M19 的结构事实，要求项目 PRD 与测试源码同时覆盖需求中公开的 BF01-BF08，并验证当前 CLI 的初次启动与同 cohort 重启业务流均 passed、身份一致、最终 stopped。Identity 用户/组织、Runtime-owned owner 字段和场景 fixture 不要求出现在 Blueprint/manifest；它们由项目业务流通过正式测试路径证明。测试函数可在公开 BF ID 后自由命名，评估器不得依赖历史函数全名或把一个历史测试暗中映射到多个 BF。

项目与 Runtime 数据库必须在 Agent 启动前均不存在；该不存在证明写入 run freeze manifest。任何失败后的修复都创建新的 convergence run 和新的 SQLite cohort，不删除数据库伪装成原始 pass@1。

M1 新 run 使用 `domainry-m1-evaluator-result-v3`，并向 checker 提供
`domainry-business-flow-evidence-v1`。该文档按 `initial` / `restart` 两阶段、BF01-BF08
组织；每个 BF 包含 `status` 与非空 `steps`。每个 step 至少包含：

权威证据由最后一次 verify capture 的顶层 `business_flow_evidence` 或
`output.business_flow_evidence` 提供。driver 严格核对 `contract_version`，原样归档为
`run/business-flow-evidence.json`，并只把该归档副本交给 checker。两处内嵌字段同时出现时必须
一致。`--flow-evidence-source` 只用于旧 Runtime 的兼容或诊断：verify 已内嵌证据时它不能覆盖，
二者规范 JSON hash 不同即 fail closed。缺失或 contract 无效的证据不会被 driver 补造，仍由
checker 判为失败；checker 若改写或删除归档副本，run 以 `flow_evidence_archive_drift` 作废。

```json
{
  "id": "stable-step-id",
  "operation": "runtime operation family",
  "source": "runtime.records|runtime.action|runtime.workflow|runtime.scheduler|runtime.report|runtime.data_exchange|runtime.identity|runtime.navigation|project_handler",
  "status": "passed",
  "requirements": ["1", "5"],
  "observations": {}
}
```

`requirements` 是公开需求编号，不是隐藏 M 编号。checker 只依赖 manifest 引用结构、业务
标签、公开状态/需求语义和真实行为证据，不依赖历史资源 key。BF08 在 initial/restart 均必须
分别证明 `report.prepare`、`data_exchange.job.owner_bound`、
`report.prepare.unauthorized_denied`、
`data_exchange.job.completed`、`data_exchange.job.download`、
`data_exchange.job.foreign_download_denied` 与 `artifact.csv.content_validated`，来源分别为
Runtime Report/Data Exchange。`records.csv_export` 是另一能力，即使 CSV 内容正确也不得替代
BF08；出现该兜底、缺少结构证据或用不完整 observations 代替真实 job/download/content proof
时，M16 失败且 `silent_downgrade=true`。已完整记录的真实 Data Exchange 运行失败仍是普通
BF08 fail，不自动算 silent downgrade。

BF08 的 observations 还必须用同一不透明 `job_id` 贯穿 prepare/owner/completed/download，
并分别记录 `accepted=true`、非授权 actor 的 prepare `access_denied=true`、
`requester_owned=true`、`job_status=completed`、真实 job download
的 `actual_job_download=true`/非零 `byte_count`/CSV content type、异 actor 的
`access_denied=true`，以及 CSV 可解析、行数与 Report 一致、content hash 已核对。checker
只比较这些行为事实和不透明 ID 的一致性，不读取历史资源 key。

机器 schema 位于 `docs/schemas/freeze-manifest-v1.schema.json`、
`docs/schemas/progress-v1.schema.json`、
`docs/schemas/run-lifecycle-v1.schema.json`、
`docs/schemas/business-flow-evidence-v1.schema.json`、
`docs/schemas/m1-evaluator-result-v3.schema.json` 和
`docs/schemas/scorecard-v3.schema.json`。

## 架构约束:数据库无关(多库可移植)

框架将来要做多数据库切换,**skill 文档、交付物、验收检查器一律不得依赖任何数据库特有能力**(如 PostgreSQL RLS)。租户隔离走 workspace 应用层(`workspace_id` 过滤)+ 声明式业务数据域。验收标准须用普通 SQL 可验的行为证明隔离,禁止要求 `rls_*`/`set_config`/security_posture 等库专有产物。检查器若违反此约束即为缺陷(见 platform-findings #17)。

验收与评分**只在 SQLite 上执行**(opt-16 起):不要求多 dialect 运行时证据,agent 不得为验收自行架设 PostgreSQL/MySQL;可移植性由代码/模型层的库无关约束保证,与单库验收正交。

## 中断恢复纪律

测量 run 不允许 resume/continue 既有 Agent session。API 中断、断网或进程退出后，原 run 按已有证据封存；后续工作必须建立新的 convergence run、新 isolation root、新 Git project、新 SQLite cohort 和新 Agent session，并通过 `parent_run_id` 保留谱系。不得复制旧 TODO、`.domainry`、数据库或项目实现。

## 对比规则

同一 benchmark、不同 skill_version 的 scorecard 逐字段对比;北极星 pass@1 变化必须伴随漏斗指标解释(哪层首过率带来的),防止巧合。

**历史 scorecard 兼容性**：当前结果使用 `scorer_schema=domainry-builder-eval-v3`。v2 文件保持
原样可读并只保留审计价值；它的旧 A7/B3 语义不得与 v3 静默横向比较，也不得通过重跑 scorer
覆盖原文件。更早 schema 使用已删除命令或旧阶段口径，同样不重算、不参与当前基线。
