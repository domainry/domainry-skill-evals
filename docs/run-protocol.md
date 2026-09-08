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

启动前还必须按 CLI 使用的 SemVer 规则比较候选包版本与 `application_delivery` 版本。若服务版本
更高，正常 CLI 会原子升级已安装 Skill，破坏冻结候选；driver 必须在创建 isolation 和启动 Agent
之前以 `service.application_delivery_newer_than_candidate` fail-fast。该门禁属于 evaluator 隔离，
不得通过删除或禁用产品的 CLI 自动更新能力来规避。

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
  lifecycle.json          driver 状态、冻结预算、使用量、停止原因、评分/诊断首次失败
  progress.json           driver 原子刷新的实时派生状态（不参与评分）
  agent-events.jsonl      Codex 原始 JSONL（保持原样）
  agent-event-observations.jsonl evaluator 对每条 JSONL 的接收 epoch 与行号绑定
  cli/NNN-<family>.json   CLI 工件；含评分 family 与独立 verify_fixture diagnostic family
  stage-timing.json       evaluator 从 lifecycle + CLI 事件推导的五段区间与 provenance
  tokens.json             可选:兼容 total_tokens、供应方 usage breakdown、reading_tokens
  stages.json             可选:旧 driver 手工阶段秒数（仅在无 evaluator 事件计时时兜底）
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

只有实际执行 `model capability`、`model plan`、`apply model`、`apply finalize` 或完整生命周期 `verify` 的
Domainry CLI argv 才进入 scoring capture、首败、重试与 C4/progress 计数。`--help`、`-h`、
`help`、`--version`、`version` 等 metadata 调用只是 auxiliary observation，即使写成
`domainry-cli verify --help` 也不得冒充一次成功 verify。只读的 `verify fixture` 进入独立非计分
`verify_fixture` capture family，保存 started/completed、exit code、聚合输出、可用时独立
stdout/stderr、evaluator-observed 时长；它不进入 A4、C4 scoring invocations、评分首败、CLI
预算或重试预算，也不会把随后的完整 verify 计为重试。识别按 shell argv 的独立 token 进行；
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

### Claude Code 作为被评估 Agent

`harness/claude_agent.py` 把 `claude -p --output-format stream-json` 翻译成 driver 已消费的 Codex 事件形态（`thread.started`、`item.started/completed` 的 `command_execution` 含 `exit_code`、累计 `usage`），并把 `CLAUDE_CONFIG_DIR` 指向隔离 `CODEX_HOME`，使 Agent 只看到冻结候选。driver 拒绝 agent 命令中出现 evaluator 路径，因此把适配器以裸命令名放到 `PATH`（例如 `ln -s <repo>/harness/claude_agent.py ~/.local/bin/claude-eval-agent`）。认证走 `--auth-source <0600 JSON>`，内容是 `ANTHROPIC_*` 环境变量键值，适配器只注入子进程环境。示例：

```bash
python3 harness/run_driver.py ... --model claude-fable-5-1 \
  --agent-command-json '["claude-eval-agent","--model","{model}","{prompt}"]' \
  --auth-source ~/.config/domainry-evals/claude-auth.json
```

注意 Claude 的 `usage.input_tokens` 含缓存读取（Codex 口径亦然），C2 数值会显著大于 Codex run；比较时看 `non_cached_input_tokens`。

`baseline` 不得带 parent；任一 Agent 命令非零退出，或任一 Domainry CLI 返回明确失败状态后，
driver 强制停止 Agent，不等待其自主
收敛。`convergence` 必须显式使用 `--mode convergence --parent-run-id <baseline-or-prior-run>`，
允许在预算内重试，但 `pass_at_1_eligible=false`。主要终态：

若失败点已封存 evaluator checkpoint，convergence 同时传入
`--checkpoint-manifest <checkpoint.json> --checkpoint-archive <checkpoint-project.tar.gz>`。
driver 校验 manifest contract、`baseline_eligibility=false`、source/parent 谱系和 archive SHA256，
再把项目内容恢复到新初始化的 Git 工程；旧 `.git`、Agent session 和 SQLite 数据库一律不恢复。
checkpoint manifest/archive 及其哈希进入 freeze manifest，并在 Agent 退出后复验。baseline 禁止使用
checkpoint。这条路径只节省已完成的业务建模/生成工作，不改变 convergence 永不作为 pass@1 证据的规则。

需要失败后暂停并交给底座 owner 修复时，显式添加 `--checkpoint-on-first-failure`。
此选项默认关闭；开启后 convergence 与 baseline 都在首个非零 Agent 命令或明确的 Domainry
失败状态（包含 `verify fixture` 诊断）处停止 Agent。driver 确认 Agent 整个进程组没有可写入的
存活成员后，将当时源码保存到本 run 下新的 `failure-checkpoint-<unique>/checkpoint-project.tar.gz`
及 `checkpoint.json`，绝不覆盖输入 checkpoint。Agent 终态失败、checker 失败以及其他未完成终态
也会尝试封存；正常完成不生成失败 checkpoint。封存排除旧 Git、Runtime state、SQLite、Agent
session、Domainry lock，以及 checker 中断后可能残留的 `backend/bf06evaluatorprobe-*` 评估专属临时
源码，并跳过 symlink/特殊文件而不跟随。空项目或无法证明 Agent 已停止等情况
不能伪造可恢复成功：`failure-checkpoint-result.json`、lifecycle 和 progress 会明确记录
`status=failed`、失败阶段和错误类型，部分工件不能用于恢复。

成功结果为 `failure_checkpoint.status=sealed`，包含 manifest/archive 路径与哈希，并通过原有
`checkpoint_identity` 验证。manifest 固定 `source_run_id` 为当前 run、
`baseline_eligibility=false`、`measurement_class=checkpoint_convergence_not_baseline`，记录输入
checkpoint 谱系和新失败边界，项目状态为未验收且故障归因待判断。新的 resume boundary 要求先读
本次失败、判断责任方与受影响阶段；不会沿用可能已经执行完的旧 `next_node`。修复后用新 run id、
`--mode convergence --parent-run-id <失败的当前run-id>` 和新 manifest/archive 恢复。
策略冻结在 freeze manifest，生成结果记录在 lifecycle/progress；此选项不改变评分分母、诊断
非计分地位或 pass@1 规则。

若封存 archive 内容仍有效、但旧 resume boundary 被后续权威需求/验收合同取代，可创建
manifest-only 派生 checkpoint：`contract_version` 仍为 v1，`source_run_id` 保持 archive 的来源
convergence，`parent_checkpoint` 固定父 manifest/archive SHA256，`archive` 继续指向并声明同一字节
archive SHA256，且显式记录 `reused_parent_archive_byte_for_byte=true`。派生 manifest 只能重写权威
resume/prohibited-repair 边界，不能声称 archive 内容已改变。driver 仍以显式传入的原 archive 做哈希、
恢复与结束后漂移复验；必须有单元测试证明新 manifest 通过 `checkpoint_identity` 并实际注入 prompt。

run 目录不得预置 freeze、候选身份或任何 measured-run 工件；isolation root 更不得预先存在。
driver 建立并验证这两棵独立目录，拒绝复用或覆盖。

- `completed` / `acceptance_failed`：测量边界完整，后者为完整但未通过；
- `baseline_first_scoring_failure`：首个评分命令失败后已截断；
- `baseline_first_command_failure`：首个辅助、诊断或其他非评分 Agent 命令失败后已截断；
- `convergence_first_scoring_failure` / `convergence_first_command_failure`：启用自动 checkpoint 时
  的 convergence 首败截断，measurement boundary 为 `convergence_first_failure_sealed`；
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
`baseline_first_scoring_failure` 和 `baseline_first_command_failure` 额外记录 `environment_valid=true` 与
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

`lifecycle.json` 同时记录 `scoring_first_failure` 与 `diagnostic_first_failure`；旧读取器继续使用
兼容别名 `first_scoring_failure`。`first_failure` 指向两个通道中事件顺序最早的语义失败。
Diagnostic 失败本身不改变终态优先级：例如更晚的供应方 token 快照超过预算时，终态和
`termination` 仍为 `budget_exhausted_tokens`，而更早的 `verify_fixture` 失败仍完整保留在
`diagnostic_first_failure`、`failures.json` 和 scorecard 的独立 diagnostic attribution 中。
Diagnostic attribution 不进入 A 漏斗、A7 或普通 `failure_attribution`。

Codex JSONL 没有任何 usage snapshot 时，`usage.total_tokens` 与 scorecard `C2_total_tokens` 保持
null，且不生成 `tokens.json`；不得根据事件数、运行时间或截断位置估算 Token。供应方累计预算
口径固定为 `input_tokens + output_tokens`。`cached_input_tokens` 是 input 的子集且计入预算一次，
`reasoning_output_tokens` 是 output 的子集且计入预算一次，两者都不得再次相加。工件同时保存
input、cached input、non-cached input、output、reasoning output 与 `budget_tokens`；某个可选
明细未被事件暴露或不合法时仅该明细保持 null 并标为 partial/invalid_detail，不作估算。

## 实时进展工件

Agent 运行期间 driver 持续以同目录临时文件加 `os.replace` 原子更新 `progress.json`，契约为
`domainry-eval-progress-v1`。读者任何时刻都应看到完整旧版本或完整新版本，不会看到半写 JSON。
该文件只从已经接收的 Agent JSONL、Domainry CLI started/completed 事件、driver 生命周期和
最终 scorecard 派生，绝不成为 checker 或
scorer 输入，因此不改变评分语义。

它包含 evaluator lifecycle phase（agent/checker/scorer/terminal）及起止时间、当前 Delivery
stage 及 requirements/model/apply/verify 的 evaluator 汇总时间、wall elapsed、评分 CLI 与独立
diagnostic CLI 的调用/完成/失败/重试计数、各自最近子命令与首次失败、Agent usage breakdown、
最后事件接收时间、首败封存状态、checker 是否获准执行，
以及终态 scorecard 摘要。事件边界不足时对应值为 `null`，整体标为 `partial` 或 `unavailable`；尤其不从
墙钟或事件数量估算 Token。Agent 异常、预算终止和 baseline 首败也会在封存路径结束时写最终
terminal progress，正常完成时 `lifecycle_state` 与 `lifecycle.json`、scorecard 摘要与
`scorecard.json` 一致。

driver 同时逐行写 `agent-event-observations.jsonl`，以 `event_line`、`event_item_id` 和
`observed_epoch` 将 evaluator 接收时刻绑定到原始 `agent-events.jsonl`。CLI capture 保留对应的
started/completed 行号与 epoch。`stage-timing.json` 使用固定边界：`discovery` 从 Agent lifecycle
开始到 `model plan` 前最后一次 `model capability` 完成；`plan` 从该点到首次 `apply model`
开始；`apply` 到首次 `apply finalize` 开始；`finalize` 到首次正式 `verify` 开始。正常阶段转换
一律以 evaluator 观察到的下一阶段 CLI `started` 为结束边界。若下一阶段从未开始且 Agent
随后终止，只在当前阶段自己的 CLI `started` 已被观察到时闭合：优先使用该阶段最后一次已
started 尝试的 evaluator-observed `completed`；若该尝试到 Agent 结束仍无配对 completed，
才使用 lifecycle `agent_ended_epoch`，并在 provenance 中绑定未配对 started 事件。`verify`
使用相同终止规则。Agent 仍在运行、当前阶段 CLI 未 started，或边界顺序无法证明时，该阶段
明确为 `unknown`；后续未开始阶段也保持 `unknown`，不得报成 0，且不得用事件数量、产物
mtime 或 Agent 自报时间猜值。五段按顺序组成已观察关键路径，并输出已观察总时长、未知阶段
与最大耗时热点。`verify_fixture` 另列在 `diagnostic_intervals`，显示为
`pre_verify_diagnostic`；它绝不建立或闭合正式 `verify` 阶段。

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
   未经历的阶段可缺省。该文件只作为 evaluator 时间线的交叉校验证据；坏数据只记录在
   `C5_project_stage_report.status`，不能清空已有 evaluator 事件区间。C5 读取顺序是
   **`stage-timing.json` evaluator 观察 > `runs/<dir>/stages.json` 旧 driver 手工值 > 产物
   mtime 近似**。旧四段汇总保持兼容：requirements=discovery、model=plan、
   apply=apply+finalize、verify=verify；五段原始区间及 provenance 在 `C5_stage_timing`。

## 候选版本

候选主标识为 `<skill-package.version>+<skill_tree_sha256前12位>`。`skill_tree_sha256` 与 `cli_binary_sha256` 均来自包元数据并由 evaluator 对安装目录重新计算验证，不能用源码 commit、目录 mtime 或排除 CLI 的临时 tar 哈希替代。

## L1 微评估任务(见 tasks/)

L1 在隔离目录进行，只执行 `model capability` / `model plan`，分钟级、候选变化即跑。

## L3 全量流程

1. driver 运行 `python3 harness/preflight.py` 重验候选 Skill，并对 `config.json` 的外部服务目标做只读健康预检；`pass` 不为 true 时不得启动测量 run，也不启动或构建源码仓库。
2. driver 证明 isolation root、项目和 SQLite 均不存在，再创建独立 `CODEX_HOME`、空 Git 项目和 SQLite cohort 路径，复制冻结候选后仅投放需求与 driver policy。Agent 必须以事件流中的唯一新 `thread_id` 单会话执行当前工作流到 done；缺少 session 证据或复用历史 `thread_id` 时 run 无效。保存 Codex JSONL 事件流，并用 `harness/extract_cli_captures.py` 提取每次 Builder CLI 调用；缺少任一当前评分 family 时不能声称 pass@1，`verify_fixture` 仅提供独立诊断证据。
3. `verify` 必须返回 `verified_and_stopped`：同一个 business-flow 测试二进制在初次启动和同 cohort 重启时都通过，最终 Runtime 已停止。
4. driver 执行 benchmark checker，写 `checklist-results.json`；再运行 `python3 harness/scorer.py runs/<dir>`，归档 scorecard。

### M1 当前契约驱动验收

M1 不直接执行 `benchmarks/m1-crm/golden-probe.py` 中遗留的固定 Action、字段、身份和默认密码。driver 使用 `harness/run_m1_baseline.py --verify-result <captured-verify.json>`：它从最终签名 Runtime manifest 验证 M01-M19 的结构事实，要求项目 PRD 与测试源码同时覆盖需求中公开的 BF01-BF08，并验证当前 CLI 的初次启动与同 cohort 重启业务流均 passed、身份一致、最终 stopped。Identity 用户/组织、Runtime-owned owner 字段和场景 fixture 不要求出现在 Blueprint/manifest；它们由项目业务流通过正式测试路径证明。测试函数可在公开 BF ID 后自由命名，评估器不得依赖历史函数全名或把一个历史测试暗中映射到多个 BF。

项目与 Runtime 数据库必须在 isolation 建立前均不存在；该不存在证明写入 run freeze manifest。
无 checkpoint 时 Agent 启动前项目保持空白；checkpoint convergence 可由 driver 在冻结后恢复已封存项目内容，
但仍使用新 Git metadata、新 Agent session 和新 SQLite cohort。任何失败后的修复都创建新的 convergence
run 和新的 SQLite cohort，不删除数据库伪装成原始 pass@1。

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
  "source": "runtime.records|runtime.action|runtime.workflow|runtime.record_timer|runtime.scheduler|runtime.report|runtime.data_exchange|runtime.identity|runtime.navigation|project_handler",
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

BF06 不再接受租户 Scheduler 扫描。结构门禁要求 lead 有独立 `status_changed_at` 与
`next_followup_at` datetime 字段；Workflow 以合法 field-change trigger 监听
`next_followup_at`，且合法 Graph V2 使用非空唯一 node/edge ID、有效 edge 端点，并有连通的
`trigger → contract.condition{type=field_equals,field=status,value=contacted}` 的 `true` 分支
`→ timer → action`；该 condition 的 `false` 分支不得到达 timer。真实
`node.contract.timer` 必须包含非空 `timer_key`/`purpose`、
`source_field=next_followup_at` 和 `timezone=Asia/Shanghai`。
`next_followup_at` 是项目 Handler 已按 7 天规则、部署时区和工作日日历算好的精确工作日早晨，
timer 不得再带 offset/calendar 重算。Action 必须指向该 lead；提醒对象必须有 lead relation、
recipient、本地日期，并用恰好覆盖 lead relation 与本地日期字段的 composite unique 实现业务去重。
编译后只认 Runtime ObjectSchema 的 `validations` 数组：`type=composite_unique`，`fields`
恰好包含这两个不同字段。不得将并不存在的 `unique_constraints` / `constraints` 当作 Runtime 契约。
无关字段上的 unique、任意两字段 unique，或把 recipient 加入唯一键，都不能证明“每 lead 每本地日期
最多一条”。进入/离开 contacted 的业务 Action 负责设置/清空 due 字段，
due Action 负责重读状态、写提醒和推进 due；这些写侧事实由 BF06 行为验证。存在指向该 follow-up
Workflow/Action 的 Scheduler definition，或存在任何指向 lead/本提醒 Action 的 standalone
scheduled Workflow（即使没有 Scheduler definition），M14 均 fail closed。evaluator 还全局扫描所有
生产 Action/Workflow；任一处出现 `evaluation_time`，或用 `updated_at` 代替
`status_changed_at`，M14 均失败；无关业务的 Scheduler 不影响本项事实。

BF06 使用 A/B/C/D 组合证据，不压缩 7 天生产 Workflow，也不要求新 Runtime API：

- A（生产黑盒）：用普通 `lead.advance` 把当前 lead 推进到 contacted，读取并证明
  `status_changed_at` 与严格晚于七天、落在下一工作日早晨的 `next_followup_at` 已持久化，并证明
  当下没有提醒；restart 阶段读取同一 lead/两个时间字段，仍处于到期前且没有提醒。
- B（业务 Handler）：checker 在评分时亲自执行 `./actions/crm` 中以 `TestM1Req14` 命名的五个
  focused tests，证明工作日计算、进入设置、退出清空、due Action 重读状态并写提醒/通知/唯一键、
  同日重放、推进下一 due 和 stale no-op。evaluator-owned coverage 断言要求这些 case 实际执行非零
  项目 Handler 语句，空测试失败。测试可向项目 Handler 注入 clock，但生产 Action/Workflow 输入绝无
  `evaluation_time`。
- C（Runtime timer）：checker 在评分时亲自执行 `./tests/recordtimer` 的两个独立集成测试；使用
  project delivery 优先、本机只读 module download cache 后备的 file-only hermetic `GOPROXY`、
  `GOFLAGS=-mod=readonly` 和必要 SDK build tag，执行
  `go list -m -json github.com/domainry/domainry-runtime` 并校验 delivery binding，同时用
  `go list -deps` 与 evaluator-owned coverage 断言证明测试真正执行外部 Runtime record-timer 代码。
  checker 还临时注入、执行并哈希 evaluator-owned Go probe，直接以 Runtime 的公开 policy 断言
  `next_followup_at` source field 在零 offset 下保持精确 due，且默认全局 worker 已启用；项目源码不能
  提供或替换该 probe。
  Main module、任何 Replace、落入 project tree 的模块、缺版本/校验和、空测试和 blank import 均失败。
  该测试用真实 now+短 duration
  验证 due 持久化、pre-due no-op、全局 worker 自动 resume，以及到期前重启后同 timer 恢复；它不
  改动 CRM 的 7 天规则，也不新增 CRM rearm/snooze Action。
- D（绑定）：manifest 结构事实把 A/B/C 绑定到生产链：`next_followup_at` field-change → contacted
  condition → `node.contract.timer(source_field only)` → per-record Action。

managed verify 的 BF06 只报告 A 的黑盒事实以及 B/C suite identity；不得自报 timer 表、内部
timer ID 或不存在的 Runtime proof。checker 生成并归档
`domainry-bf06-evaluator-certificates-v1`，内含实际命令退出码、精确测试集、测试输出 SHA-256、
测试源码 SHA-256、B 的项目 Handler 覆盖，以及 C 的 Runtime dependency list、外部 module identity、
delivery binding、hermetic Go 环境、record-timer 覆盖和 evaluator-owned probe 证书。缺包、漏测、
失败、证书漂移、零覆盖、probe 漂移或本地冒充均 fail closed。

BF06 的必需 operation/source 如下；同一 operation 重复出现会失败：

| Phase | operation | source | observations |
| --- | --- | --- | --- |
| initial | `lead.contacted.due.persisted` | `runtime.action` | `record_id,status,status_changed_at_persisted,next_followup_at_persisted,status_changed_at,next_followup_at,local_next_followup_at,calculation_owner,business_calendar_key` |
| initial | `lead.contacted.no_immediate_reminder` | `runtime.records` | `record_id,next_followup_at,observed_at,reminder_count_before,reminder_count_after` |
| initial/restart | `handler.followup_due.focused_tests` | `project_handler` | `suite_id=m1_req14_handler,evaluator_certificate_required=true,required_cases` |
| initial/restart | `runtime.record_timer.integration_tests` | `runtime.record_timer` | `suite_id=m1_req14_runtime_record_timer,evaluator_certificate_required=true,required_cases` |
| restart | `lead.contacted.due.restart_durable` | `runtime.records` | `record_id,status,status_changed_at,next_followup_at,read_after_restart,reminder_count` |

A 的三条 step 还必须记录 `real_clock=true`、`evaluation_time_supplied=false`、
`direct_database_write=false`、`scheduler_invoked=false`。checker 比较 initial/restart 的
`record_id`、`status_changed_at` 和 `next_followup_at`，验证 due 时间关系与工作日早晨，并要求两阶段
都引用完整 B/C case set。评估侧不得改数据库、回拨全局时钟、手工 resume timer，或仅调用
Scheduler 后把另一条 Action 的结果归因给 Scheduler。

机器 schema 位于 `docs/schemas/freeze-manifest-v1.schema.json`、
`docs/schemas/progress-v1.schema.json`、
`docs/schemas/run-lifecycle-v1.schema.json`、
`docs/schemas/business-flow-evidence-v1.schema.json`、
`docs/schemas/bf06-evaluator-certificates-v1.schema.json`、
`docs/schemas/m1-evaluator-result-v3.schema.json` 和
`docs/schemas/scorecard-v3.schema.json`。

## 架构约束:数据库无关(多库可移植)

框架将来要做多数据库切换,**skill 文档、交付物、验收检查器一律不得依赖任何数据库特有能力**(如 PostgreSQL RLS)。租户隔离走 workspace 应用层(`workspace_id` 过滤)+ 声明式业务数据域。验收标准须用普通 SQL 可验的行为证明隔离,禁止要求 `rls_*`/`set_config`/security_posture 等库专有产物。检查器若违反此约束即为缺陷(见 platform-findings #17)。

验收与评分**只在 SQLite 上执行**(opt-16 起):不要求多 dialect 运行时证据,agent 不得为验收自行架设 PostgreSQL/MySQL;可移植性由代码/模型层的库无关约束保证,与单库验收正交。

## 中断恢复纪律

测量 run 不允许 resume/continue 既有 Agent session。API 中断、断网或进程退出后，原 run 按已有证据封存；
后续工作必须建立新的 convergence run、新 isolation root、新 Git metadata、新 SQLite cohort 和新 Agent
session，并通过 `parent_run_id` 保留谱系。只有 evaluator 明确冻结、校验并登记的 checkpoint archive 可以
恢复项目实现与 `.domainry` 项目状态；旧 TODO、Agent 状态、Git 历史和数据库仍不得复制。

## 对比规则

同一 benchmark、不同 skill_version 的 scorecard 逐字段对比;北极星 pass@1 变化必须伴随漏斗指标解释(哪层首过率带来的),防止巧合。

**历史 scorecard 兼容性**：当前结果使用 `scorer_schema=domainry-builder-eval-v3`。v2 文件保持
原样可读并只保留审计价值；它的旧 A7/B3 语义不得与 v3 静默横向比较，也不得通过重跑 scorer
覆盖原文件。更早 schema 使用已删除命令或旧阶段口径，同样不重算、不参与当前基线。
