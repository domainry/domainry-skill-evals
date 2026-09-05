# domainry-skill-evals

Builder Skill 的评估与优化闭环仓库。评测对象是 `config.json` 指向的**当前已安装、已打包 Skill**；评估器直接校验该目录内的 identity、package metadata、Skill 树和 CLI，不读取或构建任何 Skill/Plane 源码仓库。Domainry Plane 仅作为 `apply model` 的外部服务边界。

```
优化循环:baseline 评估 → 失败归因 → 优化假设 → 改 Skill → 重跑受影响层级 → scorecard 对比
```

## 结构

| 路径 | 内容 |
|---|---|
| `docs/metrics-spec.md` | 指标权威定义(北极星 pass@1 + A 准确率漏斗 / B 覆盖度 / C 成本 / D 稳定性) |
| `docs/run-protocol.md` | 运行协议:run 目录约定、skill_version 计算、L1/L3 流程 |
| `benchmarks/s1-ticketing/` | S 级基准:需求规格(agent 输入)+ golden checklist(评分金标准,agent 不可见) |
| `tasks/` | L1 微评估任务定义 |
| `harness/capture.sh` | CLI 调用捕获器(每次调用 → 可评分工件) |
| `harness/extract_cli_captures.py` | 从 Agent JSONL 提取实际执行；metadata/help/version 仅作辅助观测 |
| `harness/run_driver.py` | 全新隔离根、候选冻结、新 Agent session、原子实时 progress、baseline/convergence 生命周期、预算与证据封存 |
| `harness/scorer.py` | scorecard 生成器 |
| `runs/` | 运行工件(不入库大文件) |
| `scorecards/` | 版本化评分结果,优化对比的依据 |

## 快速开始

```bash
# 校验并冻结当前候选 Skill 身份
python3 harness/eval_config.py --json

# 候选身份 + 外部服务健康预检（失败时不得启动测量 run）
python3 harness/preflight.py

# 统一 driver 参数、最小临时认证、隔离规则与预算；isolation root 必须全新且在仓库外
python3 harness/run_driver.py --help

# 长跑期间读取当前派生进展（只读，不参与评分）
jq . runs/<run-id>/progress.json

# 跑一个 L1 建模微评估：见 tasks/l1-model-authoring.md

# 评分
python3 harness/scorer.py runs/<run-dir>
```

## 评估层级

L0 诊断触发(分钟)→ L1 单阶段微评估(分钟,迭代主力)→ L2 单模块全链路(小时)→ L3 全量 benchmark + 金标准验收(半天,北极星)。
