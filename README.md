# domainry-skill-evals

Builder Skill 的评估与优化闭环仓库。**与 plane 仓库(domainry-framework)运行实现解耦**,只通过 `config.json` 引用权威身份清单、安装父目录、CLI 相对路径与 Plane 地址。

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
| `harness/scorer.py` | scorecard 生成器 |
| `runs/` | 运行工件(不入库大文件) |
| `scorecards/` | 版本化评分结果,优化对比的依据 |

## 快速开始

```bash
# 计算当前 Skill 版本号
tar -cf - -C "$(python3 harness/eval_config.py --field skill_root)" --exclude bin . | sha256sum | cut -c1-12

# 跑一个 L1 建模微评估:见 tasks/l1-model-authoring.md

# 评分
python3 harness/scorer.py runs/<run-dir>
```

## 评估层级

L0 诊断触发(分钟)→ L1 单阶段微评估(分钟,迭代主力)→ L2 单模块全链路(小时)→ L3 全量 benchmark + 金标准验收(半天,北极星)。
