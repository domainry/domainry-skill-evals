# 优化日志

裁决规则见 docs/linear-optimization.md。基线 = 上一个 keep 版本。

| 批次 | commit | 假设 | 跑过的评估 | 关键指标变化 | verdict |
|---|---|---|---|---|---|
| baseline | plane@42e2988 (skill 447aecd4b362) | — 当前未修改的 Skill | L1 model-authoring (s1-ticketing) ×1 | 诊断轨迹 1→34→7→1,3 轮返工**未收敛**;B1=0.926;B3=0.867;C1=2367s;C2=318k;归因 skill_doc 43/48 条 | — 基线 |
| opt-01 | plane@c306876 (skill 844c6c19e2dd) | 把校验器/Blueprint 真实契约反哺文档 → A1 错误 48→个位数、返工 3→~1 | L1 model-authoring (s1-ticketing) ×1,全新 agent 同输入 | 诊断轨迹 1→1→0 **收敛(state=valid)**;累计诊断 48→2(-96%);A5 3→2;B1 0.926→**1.0**;B3 0.867→0.933;C1 -54%(2367→1086s);C2 -35%(318k→206k);2 条残留均为已知文档缺口 | **keep** |
| opt-02 | plane@e518c81 (skill 4a3e8b4ccd23) | 修 opt-01 残留(record_scope 必填、action_labels 必填、cookbook 4 处字段矛盾)→ A1 首过 0 诊断 | L1 model-authoring ×1,全新 agent 同输入 | 靶向缺陷全部消失;轨迹 1→1→0 收敛;agent 侧有效返工 2→1(第 2 轮系 driver 指导失误);B1 1.0、B3 0.933 保持;新暴露 1 条:opt-01 文档示例缺 variables[](→opt-03) | **keep** |
| opt-03 | plane skill-opt HEAD (skill 63999fbcab6d) | 补 variables 契约+修示例 → 首次 validate 0 诊断 | L1 model-authoring ×1,全新 agent 同输入 | **A1 首过=true,首次 validate 即 state=valid/0 诊断,A5 返工=0**(L1 一次成型里程碑);B1 1.0→0.926(F16 回退:seed↔Identity 关系文档歧义致本轮 agent 保守弃绑 assignee,非静默,→opt-04 靶点);C2 200k 持平 | **keep** |
| 稳定性 D1 | skill 63999fbcab6d ×3 重复 | 验证 opt-03 一次成型非运气 | L1 model-authoring ×3(run-01/02/03) | A1 首过 **2/3**;pass@1 **1/3**(run-02 全绿:首过+0 返工+B1=1.0);run-03 3 轮未收敛。方差三来源:①seed↔Identity 绑定歧义(01 弃绑失分/02、03 绑定);②business_handler 行为元组细则缺失+**校验器互斥**(结构层要 read_set 非空 vs 组合层要匹配 data_access 派生集,create-only handler 无合法写法,cli_platform);③"每个 handler Action 需未授权角色 denied 场景"组合规则未文档化 | opt-04 靶点确定 |
| opt-04 | plane skill-opt HEAD (skill 9e99138bb008) | 修 D1 三个方差来源(seed 绑定/behavior 元组/denied 场景规则) | L2 pipeline 试点间接验证;D1×3 复验待跑 | L2 全链路首次打通:apply→骨架→handler 实现(6/6 测试)→finalize/check 全绿→verify→package→**托管 Runtime healthy**;实现阶段新挖 6 缺口(build tag 无合规路径为阻断级);acceptance prepare 卡在 denied-report 表达(→opt-05) | keep(暂定,待 D1 复验) |

## baseline 详情(l1-model-447aecd4b362-01)

- **A1 未一次通过,3 轮修复后仍剩 1 条编译诊断**(transition Action 的 authorization/permission 误用)。
- **48 条累计诊断中约 43 条归因 skill_doc**:expected_outcome 枚举文档过期(13)、通知 schema 零文档(25)、requirement payload 字段未发布(1)、菜单建模误导(2)、transition 授权语义未说明(2+)。真正的 agent 建模错误仅 2 条。
- **B1=0.893 覆盖率高**:16 项金标准 14 pass、1 fail(F05 transition 声明)、1 missing(F15 菜单,平台不支持建模,已显式记录非静默)。
- **CLI 侧观察(cli_platform)**:fail-fast + 分阶段披露(schema→compose→runtime_manifest)放大返工轮数;exit code 0 但 state=repair_required。
- 首批优化假设:①把 CLI 真实 schema 反哺文档(修 expected_outcome 枚举、发布通知/requirement payload 契约、澄清 transition 授权与菜单宿主)→ 预期 A1 错误数 48→个位数;②审核报告 P0 硬阻断修复。

## L3 里程碑(l2-pipeline-9e99138bb008-01,行为级验收)

- **16/16 金标准探针全部通过(B1 行为级 = 1.0)**:CRUD/状态机边沿/角色差异化转换/RLS 行隔离/幂等创建重放/只增评论/受保护报表/有界分页/审计留痕/事务性分派通知落 Inbox,全部在真实 Runtime 上实测通过。
- 验收分母 101 用例已生成并绑定 Runtime cohort;acceptance check 的 typed artifact harness 为剩余工作。
- 运行时层新发现(opt-06 靶点):transition 调用形状未文档化 + **不带 payload 静默假成功(cli_platform 严重缺陷)**;automation assert 真实 config {source,operator,value} 与 $candidate 前缀;ConditionalUpdate CAS 惯用法缺文档;SubjectVersion 经类型化 SDK 不可满足(SDK 丢弃 Version/UpdatedAt)。
- 累计归因:skill_doc 9 / cli_platform 5 / skill_tooling 1。
| opt-06 | plane@fa0fc10 (skill 8e1d3895f3e3) | 运行时层契约文档化(transition 形状/automation config/CAS 惯用法/build tag/SubjectVersion)→ handler+automation 运行时一次成型 | e2e-8e1d3895f3e3-01 全链路 | **validate/apply/实现/prepare 四阶段全部一次通过**;实现阶段 CAS/SubjectVersion/build tag 全部按文档一次写对(上轮 3 处运行时缺陷全消);运行时仅 1 轮 agent 返工(automation 作用域新缺口)+1 个平台 stale 缺陷;金标准 16/16、B1=1.0、B3=1.0(全平台复用);总耗时 29 分钟、288k tokens | **keep** |

## E2E 全链路终评(e2e-8e1d3895f3e3-01,opt-01~06 累计效果)

需求 → model(validate 一次 0 诊断,33 项/24 场景)→ apply(一次到实现交接)→ handler 实现(一次全绿,7 测试)→ acceptance prepare(一次通过,131 用例——baseline 此处 8 轮)→ verify/package/Runtime → **金标准 16/16(B1 行为级=1.0,B3 平台复用=1.0)**。
全程 agent 侧仅 1 轮返工(automation before-update 作用域拦截转换 Action——新 skill_doc 缺口→opt-07)+1 个平台缺陷(删除的 automation 在既有库不收敛,须清库→cli_platform)。
对比 baseline:当初仅 model 阶段就 3 轮未收敛、48 条诊断;现在全链到运行时行为验收合计 1 轮返工。
| opt-07 | plane skill-opt HEAD (skill ed940eb45f92) | automation 作用域语义文档化 → 最后一类返工消失、D1 方差消除 | D1 ×3(L1)+ 全链严格 pass@1 | **D1:A1 首过 3/3**;**严格 pass@1 = TRUE**:run-01 全链(validate→apply→实现→prepare→verify→package→Runtime→金标准 16/16)零 agent 返工、零 driver 产品修复;C1 全链 20 分钟、C2 231k tokens | **keep** |

## 北极星达成(strict-pass1-ed940eb45f92-01)

opt-01~07 累计效果:全新 agent、同一 S1 需求,从零到运行中的已验收 SaaS 后端,**pass@1 = true**——
validate 首过 0 诊断 → apply 一次到交接 → handler 实现一次全绿(7 测试)→ prepare 一次通过(121 用例)→ verify/package/Runtime 一次 → **金标准 16/16(B1=1.0,B3=1.0)**。
返工轮数 0;总耗时约 20 分钟 / 231k tokens(baseline:仅建模阶段即 3 轮未收敛,2367s/318k 且不可交付)。
D1 稳定性:同版本 ×3 建模全部首过(3/3)。
| M1 baseline | skill ed940eb45f92(opt-07)| — M 级首评(workflow/审批/scheduler/受控导出/部门域/SQL 报表首测) | m1-model run ×1 | 首轮仅 2 条诊断(S1 baseline 同点位 48 条,已打磨文档迁移良好);但新文档区 6 轮返工、累计 37 条诊断才收敛:object_sql 编写契约(13)、identity_bootstrap 宿主(6)、平台权限声明(2)、批量幂等/多条目合并(2)等——全部转 opt-08 靶点;19/19 金标准建模齐全 | opt-08 靶点确定 |
| opt-08 | plane@bdd8800 (skill fc4a295089bb) | M1 六组契约文档化 → M1 建模返工 6→~0 | m1-model 复评 ×1,全新 agent 同输入 | 诊断轨迹 **2→1→1→0(3 轮)** vs baseline 6 轮 37 条;object_sql/identity_bootstrap/平台权限三大契约全部一次写对;残留 3 条新组合规则(运行时产物对象种子不豁免、relation payload 需 target_object_key、handler 需直接 positive 场景)→ opt-09 | **keep** |

## M1 全链里程碑(m1-full-chain,金标准 19/19)

审批工作流(通过→同事务转化+建客户;拒绝→回退+留痕)、双分支金额路由、注册/转化幂等、部门级 RLS(同部门可见/跨部门隐藏/非 owner 写拒)、客户只读、cron 定时提醒(DB 老化 fixture 实测派发+去重)、受控导出正反探针、审计 86 条——全部真实 Runtime 验证。
6 个 handler 实现阶段一次全绿(26 测试);运行时阶段 4 轮真返工,全部为**新契约层**:①创建型 Handler 的 kind 双所有者冲突(五层静态检查全穿透);②department 域魔法字段(owner_department_path 锚点/config 必填/workforce 绑定);③Handler 跨对象写受调用者数据域约束。→ opt-10 文档靶点 + 平台清单追加。
| opt-10 | plane@559c8b1 (skill 0ea7c47991f7) | M1 运行时三层契约文档化 → M 级建模近零返工 | m1-model 复评 ×1,全新 agent 同输入 | 诊断轨迹 **2→0(1 轮,单根因)**;kind/department 锚点字段/workforce 绑定/跨对象写域/种子显式携带**全部一次建对**;M1 建模收敛史:baseline 6 轮 37 条 → opt-08 3 轮 4 条 → opt-10 1 轮 2 条 | **keep** |
| opt-12 | plane@4d4d821 (skill 053ab2d91ecb) | 模板对齐(运行时证据项移入 verify/复合检查拆单/依赖顺序合法化,含 opt-11 门禁工具对齐) | S1 fullflow agent-driven ×1(需求→done 全链,agent 自driving CLI) | 建模/实现/交付链**全程一次通过**(finalize→verify→package→Runtime 首次即绿);运行时集成回环 **1 轮返工**(itg-01: update handler 漏写 ConditionalUpdate CAS 条件——文档已覆盖仍漏,测试替身不强制谓词放行→平台清单#8);金标准 **15/15 可交付项全过,B1=0.9643**(F15 菜单显式 missing:平台菜单首建死结→清单#7);B3=1.0;终态非 done:R15 acceptance_failed + acceptance check 环境不可闭合(故障注入/PG RLS,A4 维持 not_measurable);⚠️ 中途外部断网一次,会话经 fullflow-01.md 成功恢复(框架可恢复性实证),C1/C2 跨中断不可比 | **keep** |
| opt-13 | plane@3de974c (skill 5287d3b722c2) | CAS 静态自检(TODO 必选项+runtime-client.md 自检命令)→ itg-01 类缺陷(handler 漏写 ConditionalUpdate 条件)在实现阶段被拦截,运行时集成返工 1→0 | driver 静态回归(非 agent run):召回=重建 itg-01 缺陷文件被标记(exit 1);精确率=4 个历史项目工件零误报(exit 0);门禁可满足性=label 对 gates 工具命令类别匹配为空 | **driver 评前审查发现并修复首版两缺陷**:①label 含 "non-test"/"unit tests"/`_test\.go` 子串误触发门禁 "test" 命令类别→grep 证据命令被拒(不可满足条目,即 opt-12 缺陷类);②裸 `grep -L` 管道退出码不承载判定(GNU grep 两种状态均可 exit 0)→缺陷项目也能绑 passed;改为捕获输出判空、exit 1 当且仅当存在违规文件。文件粒度局限已注明(单文件混合有/无条件调用会漏,依赖一 handler 一文件默认布局) | keep(暂定,待下次 fullflow 复验) |
| opt-13 复验 | 同上(skill 5287d3b722c2) | fullflow 确认 CAS 自检使 itg-01 类运行时返工 1→0 | S1 fullflow agent-driven ×1(fullflow-5287d3b722c2-01,~56min/391k tokens,无中断) | **假设成立**:自检命令被 agent 逐字执行并绑定门禁(exit 0),运行时回环 CAS 类返工 1→0;validate 首过 0 诊断,真实返工仅 1 轮 reviewed evolution(验收场景修正);A6 false-done=0,agent 全程证据诚实。**B1 0.9643→0.8214 非 skill 劣化**:F05/06/07 单根因新平台缺陷——三段式权限键两层授权解释不一致(ActionAllowed 3 段 shim 放行 vs ObjectForAction 重算 `<object>.<末段>` 必拒),validate 放行、运行时必死;opt-12 恰用两段式键故未触发(命名方差)→平台清单 #11。终态 verification_blocked:F-ACCEPT-01 凭据交接缺口(driver 实测 dev 默认密码可用,链路技术可通)+F-LOCK-01(锁过期不解除,疑似缺陷 #12)。**opt-14 靶点:①backend-model.md 钉死 permission key 语法(两段式 `<object>.<action>`);②验收凭据引导(dev 默认密码流程/避免锁定探测);run 协议:driver 投放时交接部署凭据** | **keep** |
| opt-14 | main@c7793be (skill a9cb04b888c2,平台 v0.0.3-main 含 5 修复) | 权限键两段式语法+dev 凭据引导+平台修复后 5 处文档对齐 → 上轮两大阻塞消失,B1 回 1.0 | S1 fullflow agent-driven ×1(fullflow-a9cb04b888c2-01;两次外部 API 中断经同 agent 恢复,C1 近似) | **金标准 16/16,B1=0.8214→1.0(fullflow 赛道首次含 F15 满分)**;权限键全两段式(#11 未触发);验收会话零锁定自建(凭据流程一次走通);R15 菜单首建+角色差异化实测(agent=[my_tickets] vs manager=[all_tickets,ticket_report],平台修复 #7 实战生效);**acceptance check 首次真实执行**:120 用例 85 过/35 声明缺口/0 意外,集成 45/45,A5=0,B2=0,B3=1.0,0 伪造;终态 acceptance_failed(诚实):余量全为检查器与平台/环境契约不一致(F-V1 PG-RLS 姿态、F-V3/V4 分页游标、F-V5 冲突错误码、F-V6 快照器)+基准分母缺口(F-V2 backend-only 却要前端轨迹)+skill 门禁工具键名缺陷(F-V7→**opt-15 靶点**);平台修复 #1/#3/#7/#8 全部实战回归通过 | **keep** |
| opt-15 | main@b692cb9(tooling-only,skill 内容哈希不变 a9cb04b888c2) | 门禁工具从 runtime-process 回执发现 runtime 身份 → F-V7 消失,runtime 级证据可绑定/可失效 | 工具单测 3/3(含新增修前必挂回归)+真实语料回归:三个归档 fullflow 项目 identities() 的 runtime 身份从 EMPTY 全部变为可解析 | 根因:交付 manifest 只有 40 位 `manifest_hash`,工具找 64 位 `*_sha256` 键名+位长双重不匹配 → runtime 身份恒空,且 **runtime 级 stale 检测形同虚设**(空==空恒 current,隐藏正确性洞);修复后以运行中 Runtime 的 `runtime_manifest_sha256`(runtime-process.json)为第一发现源,重启换 bundle 才触发失效——语义更正 | keep(暂定,待下次 run 全链复验) |

## S1 fullflow 终评(fullflow-053ab2d91ecb-01,agent 自 driving 全链)

- 全新 agent 从 requirements.md 到交付链全绿:PRD 12 节、模型一次建对、handler 实现、finalize→verify→package→托管 Runtime 一次成型。
- 运行时集成回环唯一返工 itg-01:`update_ticket_details` 的 `ConditionalUpdate` 无 CAS 条件(`conditional_mutation_required`)。**文档(runtime-client.md opt-06 惯用法)已覆盖仍被漏写**——单靠文档不足,生成测试替身不强制谓词是穿透主因(平台清单#8);可选 skill 侧缓解:verify 门禁加静态检查(`ConditionalUpdate` 调用点必须伴随 `Require*`/`WithExpectedUpdatedAt`)→ 候选 opt-13 靶点。
- 新平台死结 itg-02:业务菜单正规通道不可创建(Expected-Schema-Hash 必检 vs 不存在资源空 hash,无集合创建路由),R15 只能 acceptance_failed(清单#7);F15 显式 missing 非静默,与 baseline 处置一致。
- 会话恢复实证:外部断网丢失 agent 上下文后,全新会话仅凭 `.domainry/development/fullflow-01.md` + 门禁文件恢复,54/9/13 收敛且修复真实缺陷——开发 TODO 作为唯一状态权威的设计经受了真实中断。
- driver 探针基建:golden-probe 支持 handler-action 型交付(CREATE/UPDATE/COMMENT_ACTION)、探针数据 RUN_TAG 唯一化(自然键交付撞 duplicate_identity)、按用户密码覆盖(PROBE_PASSWORDS);修复 F08 判定 bug。

## M2 合并终验(m2-fieldservice-95bda9c73eaf-01,2026-08-19)—— 首个诚实 done + 金标准满分

按用户决定,opt-16..20 采用"各批次单独 commit、合并终验"模式,本 run 一次裁决五个批次 + 平台修复第 2/3 批行为回归。**结果:B1 = 23/23 = 1.0(P0 加权 40/40),0 交付失败,0 静默降级,A6=false;终态 done/passed_with_declared_gaps(190 用例 151 过/0 败/39 typed 声明缺口);C2 = 198,210 tokens(vs opt-14 S1 的 397k,更大基准减半);C1 12,100s;A5=0。** opt-15 复验通过(gates 74/74 全闭,runtime 身份绑定生效)。平台第 2/3 批修复实战回归全过:#17 隔离库无关证明、F-V2/intent-trace backend-only 分母、declared-gap 机制(诚实 done 的解锁关键)、#13 凭据披露(验收身份自建零锁定)、#4 SDK 版本、#6 validate config 校验、P2-7/8。探针侧:9 项首轮假失败为列表封套 id 位置的探针形态问题,修参后全过;M2 探针参数仍手工(自动派生仅 S1,候选后续)。

| 批次 | commit | 假设 | 跑过的评估 | 关键指标变化 | verdict |
|---|---|---|---|---|---|
| opt-16 | main@40b2c76 | 隔离证明库无关化(移除 PG-RLS 指令)→ 消除 PG 歧途 | M2 终验 | 全程零 PG 接触,隔离金标准(N04 行级、Portal 隔离)全过 | **keep** |
| opt-17 | main@b751c52(消息误标 opt-16) | 验收 SQLite-only(G31 收窄、G19 EQP)→ 消方差省时 | M2 终验 | SQLite 单库验收全链通过,无多 dialect 工作量;G19/G31 类 case 正常闭合 | **keep** |
| opt-18 | main@0ba41a7(消息误标 opt-17) | 核心文档去重 −15.5KB → C2 降、语义不漂移 | M2 终验 | C2 198k(历史 fullflow 减半);74 门禁全闭无文档歧义返工 | **keep** |
| opt-19 | main@19044d3(消息误标 opt-18) | capabilities 按需索引 → 只读所需能力文件 | M2 终验 | 61 类索引+10 类逐类发现(未整目录扫读);C2 佐证 | **keep** |
| opt-20 | main@2dd42f8(消息误标 opt-19) | 验收 backend-only(移除 CU/浏览器证据)→ 消除 CU 假阻塞 | M2 终验 | 无浏览器环境下达成 done(此前同环境必 verification_blocked);39 缺口全 typed 无一伪造 | **keep** |
| opt-21 | main@6b6a8d2(消息标 opt-20) | PRD 引用模式+表格贫瘠化 → 需求段 40min 降 15-20min | 未跑(本 run 后合入) | 待下次 run(注意:C5 显示本 run model 段 4652s 含 PRD,为下次对比基线) | 待复验 |

**下一轮靶点(按耗时收益排序)**:①实现段 5659s 是最大头(C5:implement 47% / model 38% / verify 14%),用本 run 工件归因(生成 vs 回环)后定 opt-22;②acceptance runner(平台 P0 建议,verify 段内 agent 自建 harness 是主要成分);③M2 探针参数自动派生。

## 实现段 5659s 归因(基于 m2-fieldservice-95bda9c73eaf-01 工件,2026-08-19)

用 receipts/journal/runtime.log 事件时间戳归因(mtime 近似被后期模型演化污染,不可用):**handler 业务代码编写只占 ~25%(约 31min)**;其余 ~75% 由三类非业务开销构成——①agent 自建验收 harness(2811 行 Python/135KB,比 Go 业务代码还大)≈最大单项;②3 轮模型演化回环(IF-1 scheduler.command 权限、IF-2 受控导出 grants、IF-3 object_sql 缺 LIMIT——全部是平台契约坑,非业务错误);③harness 误放 `backend/**` 触发全量 re-finalize + 572 证据文件重录。→ 靶点 H1 harness 模板(估省 1500-2500s)、H2 finalizer 预检(600-900s)、H3 平台坑清单(900-1500s)。

| 批次 | commit | 假设 | 跑过的评估 | 关键指标变化 | verdict |
|---|---|---|---|---|---|
| opt-22 | main@90e1549 | H3 平台坑清单文档化(scheduler.command 权限规则、受控导出 grants、object_sql 显式 ORDER BY+字面 LIMIT)+ H3b harness 位置纪律(harness 代码/中间产物只准放 `.domainry/development/**`,禁入 `backend/**`)→ 消除 3 轮模型演化回环与全量 re-finalize | 静态检查(链接、py_compile、cmd 锚点测试)通过;行为复验待下次 run | 三个 IF 回环点各对应一条"写前即知"的规则;估省 900-1500s + 免 re-finalize | 待复验 |
| opt-23 | main@5bcd296 | H2 finalizer 源契约预检(runtime-client.md:循环内禁能力 I/O、字面 `Page(page, pageSize)` 1..200、禁丢弃 error、有界扇出示例)→ finalize 拒收类返工前移到编写时 | 同上静态检查通过 | 覆盖本 run finalize 阶段实际踩过的源契约拒收点;估省 600-900s | 待复验 |

| opt-24 | main@565985f(skill hash cfc514a2b129) | H1 runner-first 验收 + 通用 harness core(agent 只写断言)→ 消除 2811 行自建 harness 的大头(估省 1500-2500s) | 静态:py_compile、链接扫描 0 断链、cmd 锚点测试、todo-check/gates 测试全过;Python core 输出经临时 Go 测试过真 ValidateCaseObservation(http_exchange+persistence_snapshot,DisallowUnknownFields);行为复验待下次 run | 平台侧配套:acceptance runner v1 合入 main(11e26b2+8dc9074,`project acceptance run --cases standard`,M2 分母 65% 落自动执行族);CLI/Plane 部署 v0.0.7-main | 待复验 |

| opt-25 | main@03cf9ed(skill hash aa9ef881e1b2) | 前端项条件化(无 frontend/src 时 3 条机器判定收口项替代 16 条细项;verify 段五件套删除)+ 前端缺陷 finding-only(任何 scope 不修 frontend/**)+ 证据只准工具产出/指针化 + stages.json 维护规则 → 消除空转门禁证据与前端修复回环 | 静态:gates/todo-check 新增 fail-closed 测试(伪造收口必挂)、锚点测试、0 断链;行为复验待下次 run | 实证依据:cfc514a2b129-01 run 零前端项目仍走 15 条前端项+5 个空转证据 JSON | 待复验 |

## 平台修复第 4 批(2026-08-19,main 565985f..6da528b,已推远端)

用户指令"已知问题全部修复,修完合入 main"。8 个 commit,4 条线并行(独立 clone 分支→cherry-pick 回 main→分支清理,单 main 恢复):
- **契约左移 ×5**(bac381a..d01c53d):IF-1 scheduler 派发权限闭合、IF-2 受控导出 grants 链闭合、IF-3 object_sql 显式 ORDER BY+字面 LIMIT(vitess plan facts)、EX-A scheduler workflow 目标必须 scheduled+enabled、EX-C 报表 audience 权限可满足性(顺修 audience_roles 死代码)。全部"validate 放行运行时必死"类,M2 工件双向验证(演化前必拒/终版全过)。可做未做:max_rows 对齐、workflow.run 闭合、automation run_as 闭合。
- **runner v2**(5d6e748):concurrency_conflict 族机械化(确定性 CAS 探针,双成功=failed 非零退出);contract_version 不变;纯 HTTP 机械化到此见顶,余下需注入/编排钩子。
- **增量证据失效**(6da528b):分母新增 artifact_manifest(operation 依赖闭包摘要+共享摘要,emission 级归因),check 支持跨世代 carry-forward(完整哈希证明链,任何不可判定分支落 stale),新 CLI `project acceptance stale-report`;模型 item 级演化不再 572 证据全量重录。边界:handler 源码/集合级变更仍全量失效(诚实取舍)。
- **evals 测量修复 ×3**(c9ee051..b57211e,已推):agent-driven run A 组从回执推导(95bda9c73eaf-01 重算 pass@1=false→**true**,此前为机械假 false)、C5 优先读 agent stages.json、历史 scorecard schema 标注。
- 预存红灯不变(projectmaterializer ×1、frontendcomponentcontract ×2 环境)。**部署待当前 run 结束后统一升 v0.0.8-main(CLI 与框架需原子换版:新分母字段旧 CLI 不能解码)**。待办 skill 批次 opt-26:stale-report 演化流程接入 verification.md/harness core、check 回执新字段兼容。

| opt-26 | main@1e75c5b(skill hash e3881bed55da) | 增量证据失效接入 skill:演化后 prepare→stale-report→只重录 stale+missing→check;harness core ResultsFile 旧世代 rebind(保留 current/declared_gap、丢 stale 外壳);TODO 禁无差别全量重录 | 静态:gates 6/6、todo-check 10/10、锚点测试(stale-report 命令披露)、py_compile+功能冒烟、0 断链;行为复验待下次 run | 配套平台批 4 的 6da528b;要点:check 要求 results 绑当前分母,harness rebind 是业务族闭环必要件 | 待复验 |

**评估侧同批推进**:probe_derive.py 扩展 M2(`--task m2`,49 参数从 runtime-manifest.json 自动派生,vs 手工版 49/49 一致;对在跑 Runtime 实测重放 23/23);列表封套/payload 兼容层折回基准探针(adapted@ 注记,record 断言未动)——M2 探针从此免手工参数(evals 619090d)。opt-21/22/23 合并复验 = 下一次 benchmark run(基线:model 4652s 含 PRD、implement 5659s)。

## M2 合并复验(m2-fieldservice-cfc514a2b129-01,2026-08-19)—— B1 二连满分 + 验收实证深度大幅提升,runner v1 实战归零(F8)

一次裁决 opt-21..24 + acceptance runner v1 实战。**结果:B1 = 23/23 = 1.0(P0 加权 40/40,连续第二个 M2 满分),pass@1=true,A6=false,0 交付失败;终态 done/passed_with_declared_gaps(192 用例 175 过/17 声明缺口/0 败,上轮 151/39)——多证明 22 个难例,含 6/7 重启敏感旅程 L5(4×outbox exactly-once、导出断点续跑、scheduler fenced retry)与 20+ SIGKILL 重启循环。C1 = 13,821s(+1,721 vs 基线)、C2 = 226,458(+28k)**:总量微升,但时间花向从"声明缺口"转为"真实证明";速度假设的主拦路石是 F8(runner v1 登录不带 X-Workspace-ID 被本交付 Runtime 全路由强制头拒绝,192 用例全 skip,runner 收益归零)。金标准探针参数首次全自动派生(probe_derive --task m2);脏 Runtime 适配已折回基准探针(adapted@ 注记)。C5 为 mtime-approx 且被验收期模型演化污染(driver 实时观察:需求+建模 ~29min vs 基线 77min)。

| 批次 | commit | 假设 | 跑过的评估 | 关键指标变化 | verdict |
|---|---|---|---|---|---|
| opt-21 | main@6b6a8d2(skill 内嵌于 cfc514a2b129) | PRD 引用模式+表格贫瘠化 → 需求段大幅提速 | M2 复验 | driver 实时观察:需求+建模 ~29min(基线 77min,−62%);PRD 引用式输出,无重述膨胀;建模一次通过(A1/A2/A3 首过) | **keep** |
| opt-22 | main@90e1549 | H3 平台坑清单+harness 位置纪律 → 消除 IF-1/2/3 类演化回环与 backend/** 污染 re-finalize | M2 复验 | IF-1/2/3 三坑零复发(本 run 新发现 F9-F14 均为新契约面);harness 全程 `.domainry/development/**`,零 re-finalize 事故(F14 证据链佐证纪律被执行) | **keep** |
| opt-23 | main@5bcd296 | H2 finalizer 源契约预检 → finalize 拒收前移 | M2 复验 | finalize 无拒收回环(A3 首过);上轮踩过的循环内能力 I/O/分页字面量/error 丢弃零复发 | **keep** |
| opt-24 | main@565985f(skill cfc514a2b129) | H1 runner-first + harness core → 验收 harness 成本大降 | M2 复验 | harness core 被正确采用(agent 只写断言层,底座复用 523 行 core);但 runner v1 实战 0 用例执行(F8 平台缺陷,非 skill 问题),省时假设未获验证机会;验收深度反升(缺口 39→17) | **keep**(runner-first 路径待 F8 修复后才有实测数据) |
| runner v1 | 平台 11e26b2+8dc9074 | M2 分母 65% 自动执行 | M2 复验(实战) | **实战归零**:登录不带 X-Workspace-ID(runner/local.go doOnce 仅有 token 时设头,/auth/login 恒不带)→ 强制头 Runtime 403 → 192 用例全 skip;且仅实现 action/report/runtime 三族 | **平台批 5 P0 靶点(F8)** |

**下一轮**:①平台批 5 修 F8(登录/无 token 请求也带 X-Workspace-ID)随 v0.0.8-main 部署;②下次 benchmark run 合并裁决 opt-25/26 + 平台批 4(契约左移×5、runner v2、增量证据失效)+ F8 修复实战;③实现段仍是最大头(mtime 桶 6966s),等 opt-25 的 agent 实时 stages.json 上线后才有干净归因。

## M2 合并复验(m2-fieldservice-e3881bed55da-01,2026-08-19)—— C2 减半至 100k,B1 三连满分,runner 实战 0→77,wall-clock 反升

一次裁决 opt-25/26 + 平台批 4 + 批 5 F8 修复实战。**结果:B1 = 23/23 = 1.0(三连满分),pass@1=true,A6=false;终态 done/passed_with_declared_gaps(177 用例 168 过/9 缺口/0 败,缺口 17→9 再减半);C2 = 100,790(−55%,首破 200k→100k);C1 = 18,978s(+37%)——token/缺口大幅改善,但 wall-clock 恶化,verify+acceptance 交错段 11,636s 占 61%,验收时长仍是最大痛点。** C5 首次来自 agent 实时 stages.json(requirements 561/model 1288/apply+implement 5012/verify+acceptance 11636)。runner 机械执行 77 例 0 失败(F8 修复实战确认)+ 自建断言 91 + 缺口 9;concurrency_conflict 族 0 缺口(runner v2 CAS 探针使其可证,上轮 7 例不可达)。探针参数全自动派生,第三轮形态适配折回派生器/探针(集合级减免、后缀槽位、DISPATCH_FIELDS、FIELD_TYPES 等)。时长上升主因:8 个新平台发现排查回环 + runner 14 轮增量 + 91 例自建仍占大头。

| 批次 | commit | 假设 | 跑过的评估 | 关键指标变化 | verdict |
|---|---|---|---|---|---|
| opt-25 | main@03cf9ed | 无前端时 16 条前端项收口为 3 条机器判定 + 前端 finding-only + 证据工具产出 + stages.json → 消空转证据、C5 可归因 | M2 复验 | 各段单条 frontend_not_present 机器证据收口(上轮 15 条细项+5 空转证据→0);stages.json 全程实时维护,C5 来源首次为 agent-stages.json;C2 减半的主要贡献者之一 | **keep** |
| opt-26 | main@1e75c5b | 演化后 stale-report 增量重录(禁全量)+ harness rebind → 消 572 份全量重录类灾难 | M2 复验 | 模型演化后按 stale-report 只重录 stale+missing;终检 0 stale/0 missing、168 例 carry-forward 哈希证明结转;无一次全量重录 | **keep** |
| 平台批 4 | 565985f..6da528b | 契约左移×5 + runner v2 并发机械化 + 增量证据失效 | M2 复验(实战) | IF-1/2/3/EX-A/EX-C 类"validate 放行运行时死"零复发;concurrency_conflict 7 缺口→0(CAS 探针);carry-forward/stale-report 链路实战走通 | **keep** |
| 批 5 F8 | main@bd9cc32 | runner 全请求带 X-Workspace-ID → runner 实战解锁 | M2 复验(实战) | runner 执行 0→77 例(43.5% 分母),failed 0,merge/增量 14 轮正常 | **keep(确认)** |

**下一轮(对齐用户"验收太长"的痛点,按耗时收益排序)**:①**runner 覆盖扩展**——skip 的 100 例(workflow/scheduler/export/SSE/restart 族+带业务 payload 的 action 变体)是验收段最大剩余杠杆(平台批 6 候选);②**分母机制级去重**——idempotency_key_required 等纯信封族按机制证一次+action 级抽查(估 −30~40 例);③**重启分批**——按 restart_sensitive 集合一轮重启验一批;④F-01..F-08 契约对齐。

| opt-27 | main@c75b029(skill hash c49f24b72de0) | 源契约门前移:`project check --scope actions`(finalize 同款分析器的本地只读版)从 SKILL.md 的 finalize 后命令区挪到 finalize 前 + TODO implement 段新增前置门条目 → 丢弃 error/违禁 metadata 键在写码现场暴露,消除 finalize 拒收回环(前两个 M2 run 各付一次,~5min/次) | 静态:cmd 锚点测试、todo-check、gates 测试全绿 | 实证依据:e3881bed55da-01/-02 均有一次 backend_technical_contract 类 finalize 拒收;工具本就存在,纯站位问题 | 待复验(注:在 -02 run 验收段进行中提交,该 run 的 implement 段已按旧文档走完,不影响其 e3881bed55da 版本标识;行为复验在下一 run) |

## 2026-08-21 M2 MySQL 分阶段优化新基线

本系列固定使用 `gpt-5.6-sol/high`、本地 MySQL（`127.0.0.1:3306`），先比较测试前阶段。后续每一轮遵循：单一优化假设 → 针对性验证与 M2 分阶段复评 → 独立 commit/push → 在本节记录完整 commit SHA；出现劣化时回滚到上一条 `keep` 提交。

| 批次 | template commit | 假设/范围 | 跑过的评估 | 关键指标/状态 | verdict |
|---|---|---|---|---|---|
| pre-opt baseline | `skill_v2@06387965264192c71916edc3ce3262298c3cc979` | 冻结 `verdent-template` 当前代码；作为后续所有优化轮次的共同起点 | `m2-fieldservice-e45461c80f2e-mysql-pretest-01`（MySQL、测试前阶段） | requirements 358s；model 1788s；apply 41s；implement 779s；阶段合计 2966s。model validate 15 次（10 fail/5 pass）；10/10 handlers；project check 第 2 次通过；source finalize 首次通过。模板仓库全量 `go test ./...` 存在已记录红灯，按基线保留 | **baseline** |
| opt-01 | `skill_v2@01e76833af320f4854ba06295c28c0742805d5cc` | 原子完整模型校验：禁止对残缺 inventory 校验，首轮前做跨资源预检，按完整诊断批修复，模型一旦 valid 即冻结 | `m2-fieldservice-fc706dc393be-mysql-pretest-opt1-01`（全新 agent、MySQL、测试前阶段） | requirements 282s（−76）；model 1095s（−693/−38.8%）；apply 81s（+40）；implement 459s（−320/−41.1%）；合计 2017s（−949/−32.0%）。validate `30→1→0`，3 次（2 fail/1 pass，调用数 −80%），valid 后零回退；project check/finalize 均首过。模型 inventory 比基线更紧凑，行为等价留待周期性全链验证 | **keep（pre-test）** |
| opt-02 | `skill_v2@8932b2e4e8cb3e0b752fa43fd38072083d3cbc0f` | 严格嵌套形状与双向行为所有权预检：把 opt-01 首轮的菜单、校验、报表 metrics、关系读取、导出链与 owner mismatch 诊断压到 5 条以内 | `m2-fieldservice-6bd4a3a28483-mysql-model-opt2-01`（从同一 opt-01 requirements-complete 检查点独立派生、全新 agent、空 MySQL、仅 model） | 目标 7 类诊断全部消失；主校验轨迹 `1→6→0`，但首轮完整聚合仍 6 条（目标 ≤5 未达），并暴露 Report `value.key`、`join_cardinalities`、SQL LIMIT 上界三类契约缺口。证据门禁重复执行后有效调用为 validate 4 次/plan 2 次。Agent 自报 model 1093s，但延迟 306s 才写阶段起点；按进程外层口径 1399s，较 opt-01 1095s **+304s/+27.8%**。实验输出仅留档，不晋升检查点 | **rework** |
| opt-03 | `skill_v2@334688f33f93220258dee5149a8413daea216320` | 精确 Report 作者契约：emission `value.key` 双写、Object SQL `join_cardinalities={alias,cardinality}`、字面 `LIMIT 1..10000`，目标消除 opt-02 的 Report 错误并首轮 valid | `m2-fieldservice-43c91fec9277-mysql-model-opt3-01`（从同一 opt-01 requirements-complete 检查点独立派生、全新 agent、空 MySQL、仅 model） | 新 Report 预检被真实执行，opt-02 的 Report 三类诊断全部归零；但整体主校验轨迹劣化为 `1→29→35→0`（4 次），有效调用 validate 5 次/plan 2 次，新增错误集中在 Action payload/output `config`、身份/Workflow shape 及一次过宽机械修复。Agent model 1156s，按外层口径 1215s；较 opt-01 keep **+120s/+11.0%**，较 opt-02 −184s/−13.2%。117 commands、13.47M input tokens。实验模型只留档，不晋升检查点 | **rework** |
| opt-04 | `skill_v2@5076164830312046517996ddd3cce8e868f7c646` | 显式冻结上游的 stage-continuation fast path：先开阶段计时，复用 resolver/PRD 路由，跳过全链文档重载；目标 model <900s 且 validate ≤3 次 | `m2-fieldservice-687fbd48e7c5-mysql-model-opt4-01`（从同一 opt-01 requirements-complete 检查点独立派生、全新 agent、空 MySQL、仅 model） | fast path 被采用，stage 起点延迟降至 26s；命令 47、input 8.39M，主校验 `8→4→0`（3 次）。但 Agent 仍读通用模板/7 个 pattern，并加载 **24 categories/190 operations**，省略的上下文又以 6 条 Report 契约诊断返工；长生成/推理区间使 Agent model 2016s、外层 2042s，较 opt-01 keep **+947s/+86.5%**。目标严重失败，实验模型不晋升 | **rollback** |
| opt-04 revert | `skill_v2@3e9a500c9d3b64a59d2c1a067b3ddfe0ab7c6bf3` | 线性回滚 opt-04，保留候选与反向提交审计链 | 未重复评估（机械 `git revert`） | 已推送远程；工作树恢复到 opt-04 之前内容，`50761648` 不再生效 | **rollback applied** |
| opt-05 | `skill_v2@b224bf3a0d7f3401f8bddfcc1ef1958666ac93bc` | 批量 Action implementation packet：`project source prepare` 一次返回全部 8 个 Action 的去重 coding context，公共 Runtime 文档只携带一次；同批实现禁止逐 Action 重取 context | 候选 `m2-fieldservice-b6f4fe96721f-mysql-implement-opt5-01`；父版本公平对照 `m2-fieldservice-43c91fec9277-mysql-implement-control-02`（均从同一 Opt-01 `post-apply@e55c6472` 完整快照、全新 Agent、全新 MySQL、仅 implement） | 静态 packet 249,093B→172,258B（−30.8%）。候选/对照 implement 645s/757s（−112s/−14.8%），外层 733s/826s（−93s/−11.3%），input 4.224M/5.198M（−18.7%），Action context 0/17；首次 check 问题 1/3，最终均 valid 且 finalize 成功。`control-01` 因 `git clone` 漏掉忽略的 materialization receipt，在 prepare 前失败，明确排除 | **keep（implementation checkpoint）** |
| opt-05 stability repeat | 同一提交 `b224bf3a0d7f3401f8bddfcc1ef1958666ac93bc`（无代码变更） | 验证同一 batch packet 路径在全新 Agent/项目/MySQL 下是否稳定复现 | `m2-fieldservice-b6f4fe96721f-mysql-implement-opt5-02`（prompt SHA 与候选首轮相同） | implement 555s（相对首轮 645s 为 −14.0%，落入预设 ±15%）；外层 679s（−7.4%）；input 4.104M（−2.8%）；首次 check 0 问题、finalize 成功。但 CLI 仅把 172KB packet 输出到 stdout，第二个 Agent 未像首轮那样自行落盘，随后执行 13 条 `backend/model`/generated `go doc` 查询，违反 packet-only 冻结协议 | **timing stable / protocol unstable；不晋升基线** |
| opt-06 | `skill_v2@93d20d1bb833c805e9fd80474ef36b4541b24ca4`（skill `8b146f6da346`，CLI `acc4a297…`） | CLI 原子持久化 content-addressed implementation packet，stdout 只返回小 envelope；消除 Agent 手工落盘分叉并恢复 packet-only 协议稳定性 | 隔离有效样本 `m2-fieldservice-8b146f6da346-mysql-implement-opt6-02` / `-03`（同一 post-apply、prompt SHA、`gpt-5.6-sol/high`、空 MySQL；独立 `CODEX_HOME` 防其他 task 替换 Skill）。`-01` 因全局 Skill 在 Agent 启动前被外部 task 替换，明确排除 | 两次均：prepare=1、相同 packet SHA/172,704B、mode 0600、stdout 3,242B（较 174,849B −98.1%）、Action context=0、model/generated 越界查询=0、首轮 check=0、finalize 成功。implement 669s/550s，外层 744s/657s，input 4.415M/4.786M；聚合最新基线 **550–669s，均值 610s**，较 Opt5 协议有效样本均值口径 −5.5%。样本间阶段差 17.8% 超严格 15%，故不采用单次 550s 点值，保留方差披露 | **keep；晋升聚合 implementation 基线（协议稳定，时间方差待继续压缩）** |
| opt-07 | `skill_v2@7230082c6f6625354b63257b543e260b7973b818`（父提交 `93d20d1bb833c805e9fd80474ef36b4541b24ca4`；skill `c1ed2bd40246`，CLI `4bd16658…`） | 在任何 Go test 前用真实离线 Go 编译器执行 Action 生产源码门禁，finalize 复用同一不变量；把生产编译错误从 panic/测试阶段前移 | `m2-fieldservice-c1ed2bd40246-mysql-test-opt7-01`（从 Opt-06 frozen implementation checkpoint 继续，仅到 focused-test；MySQL） | 编译门禁在测试前找到 13 条生产错误并修复；autonomous `verify.started→exit` 270s，较 Opt-06 381s −111s/−29.1%。但 Go 默认 `too many errors` 使 11→2 两轮；首次 package test 又被陈旧 scaffold panic 中止，需 8 次隔离测试盘出 6 panic+2 旧断言。Agent 首次退出后 finalization receipt 漏记 9 个测试文件变化，需 1 次 evaluator correction；有效最终 checkpoint 为 973s wall、845s active、12.69M input、12 次 Go test | **keep（compile gate）；晋升当时最新 diagnostic-node baseline，陈旧测试 scaffold 为下一靶点** |
| opt-08 | `skill_v2@2ee614ea4191100f622a66482d6ba4a9c6b35d06`（父提交 `7230082c6f6625354b63257b543e260b7973b818`；skill `eb0a9cf99f79`，CLI `21a3bfdb…`） | 对交付绑定的 canonical Action 测试做纯 AST 陈旧脚手架门禁：已实现 Handler 仍配 nil Execution / `*.not_implemented` 时，在首次 Go test 前一次返回完整稳定诊断；新 scaffold 带 marker，兼容精确旧模板形状 | `m2-fieldservice-eb0a9cf99f79-mysql-test-opt8-01`（生产源码 compile-valid，只恢复 8 个旧测试；`gpt-5.6-sol/high`、空 MySQL、仅 focused-test） | 首次 check 一次列出 8/8；1 次测试批修后 check valid+finalize；首次且唯一 `go test ./actions/...` 8/8 通过，0 test failure/0 post-test repair/0 rerun，autonomous pass@1、0 evaluator correction。相对 Opt-07 autonomous：Go test 11→1（−90.9%）、input 4.872M→2.975M（−38.9%）、全 continuation 636→579s（−9.0%）；工作前移使 pre-verify 366→429s，但 verify→exit 270→150s（−44.4%）。独立审计 receipt 21/21 hash current；未改 requirements/model/生产 Handler。残余主要是 Handler/能力接口读取与 evidence gate 重复绑定 | **keep；晋升最新 focused-test diagnostic-node baseline** |
| opt-09 | `skill_v2@9729495f2d9b0005175acd4d52b5dfd839e1cc23` + replay repairs `0a047c83211f187626ab0fab27516e588b898785`、`7063d25de408d674c52497f2e09c38ce40434bd8`（skill `c0bee6da129c`，CLI `b35cd757…`） | check/finalize/focused test 首次真实执行即由 Gate runner 产出并绑定专属 command receipt；期望非零 check 支持精确 contract/state/code inventory；test Gate 禁止复用 finalize receipt。两次真实回放分别补齐 valid `diagnostics:null` 与 canonical `local composition is finalized` label 契约 | 有效样本 `m2-fieldservice-c0bee6da129c-mysql-evidence-opt9-03`；失败回放 `m2-fieldservice-533fc071139c-mysql-evidence-opt9-01`、`m2-fieldservice-49d7d293fcfd-mysql-evidence-opt9-02` 明确排除 | 有效样本 check/finalize/Go test 严格 `1/1/1`、均首过、各自 receipt、0 attach/0 重复/0 receipt 替代；Go test 1.487s；冻结 backend tree/requirements/PRD 不变，MySQL 0 表、无 SQLite。外层 186s，而三产品命令合计仅 2.687s（1.44%），约 183s 仍耗在全量 Skill/guide/template 读取、TODO 建立与解释收尾；因此证据正确性与确定性提升成立，但 wall-clock 提速未获证明 | **keep（correctness）；晋升 latest focused-test evidence-node baseline；下一靶点为冻结检查点 continuation context** |
| opt-10 | `skill_v2@62f57edd7812134ec62c96ab731919cb569e5312`（父提交 `7063d25de408d674c52497f2e09c38ce40434bd8`；skill `a0f7eabea110`，CLI `7a62d698…`） | 显式 `source-finalization-continuation` profile：只在调用方授权且当前 finalization/source identity 有效时，一次 resolver 原子创建三 Gate compact TODO、同步 IDs 并返回精确 run recipes；不加载 whole-project guide/template/authoring bundle，不手写 TODO，不独立 sync/list | `m2-fieldservice-a0f7eabea110-mysql-continuation-opt10-01`（同一冻结 checkpoint、`gpt-5.6-sol/high`、全新空 MySQL） | profile/resolver=1，独立 sync/list=0/0，guide/template reads=0/0；check/finalize/Go test 仍严格 `1/1/1`、各自 receipt、3 Gate 全过，冻结 backend/requirements/PRD 不变，无 SQLite。相对 Opt-09 等价节点：外层 186→98s（−47.3%），input 501,507→173,294（−65.4%），首次 check 前约 116→56s（−51.7%）；验证深度不变 | **keep；晋升 latest focused-test continuation baseline** |
| opt-11 | `skill_v2@c7259cc4a2958b262308cd23cfffeb77faeda0e8`（父提交 `62f57edd7812134ec62c96ab731919cb569e5312`；skill `7caf15326730`，CLI `6e37e70c…`） | 将 whole-project authority 从 Host 必读入口移入强制完整加载的 development guide；`SKILL.md` 保留路由、安全不变量与显式 continuation 自足路径，目标缩短冻结节点的必读上下文且不削弱正常开发契约 | `m2-fieldservice-7caf15326730-mysql-routing-opt11-01`（同一冻结 checkpoint、`gpt-5.6-sol/high`、全新空 MySQL） | Skill 305 行/46,698B→80 行/10,505B（−77.5%）；resolver=1、独立 sync/list=0/0、guide/template=0/0；check/finalize/Go test 严格 `1/1/1` 且 3 Gate/receipt 全过，冻结 backend/requirements/PRD 不变，无 SQLite、MySQL 0 表。相对 Opt-10：外层 98→71s（−27.6%），input 173,294→114,370（−34.0%），首次 check 前约 56→35s（−37.5%）；验证深度不变 | **keep；晋升 latest focused-test continuation baseline** |
| opt-11 downstream canary | 同一提交 `c7259cc4a2958b262308cd23cfffeb77faeda0e8`（无候选代码变更） | 从 focused-test checkpoint 继续到 verify→package→Runtime→单条最高风险语义 canary，不跑 acceptance；盘点后续节点问题 | `m2-fieldservice-7caf15326730-mysql-canary-opt11-01`（同一 Agent session 两轮；本地 MySQL） | 首轮 verify 仅因 4 个生产文件 gofmt 失败；授权纯格式修复后 check/finalize/focused test/verify/package 均一次通过。Runtime clean bootstrap 在 `idx_audit_event_record_cursor` 触发 MySQL Error 1071（3072-byte key limit），J06 未执行，Runtime stopped；失败建库留下 125 表、目标索引 0，无 SQLite。两轮 active 824s、input 10.250M，产品命令仅 20.859s；另暴露 downstream whole-project context 膨胀、format 门过晚及 finalize evidence identity 易失效。需 Opt-12 修 Runtime 后从 package/Runtime 节点续跑 | **blocked；不晋升基线** |
| opt-12 | `skill_v2@431d5b53743b90d879fadcac6b5e342b2eb557d0`（父提交 `c7259cc4a2958b262308cd23cfffeb77faeda0e8`） | 修复 Runtime MySQL audit cursor 复合索引超 3072B：仅 Runtime 自有 `id/created_at` 使用 `VARCHAR(191) ASCII/BINARY`，业务过滤列保留完整 utf8mb4；补半建 schema normalization，不用 prefix index | template focused/broad persistence、完整 bootstrap integrationtest、真实 MySQL 9.5 clean bootstrap/半建恢复/中文精确过滤/同时间戳分页；隔离 local Delivery `0.0.0-local.20260822.opt12`、module `v0.0.0-source-e235a3d6e4fb5b47` 完整 HTTP closure smoke | 旧 record/actor 最坏 3820/3056B→2674/1910B；clean bootstrap 与 125 表失败现场原地恢复均通过；完整索引 `SUB_PART` 为空。独立 commit 已普通 fast-forward 推送。新 AD manifest `bbdef1ed…`、module zip `ac22d2d…`，8284 可解析；发布期间首套临时 signer 泄漏候选已撤销/轮换，最终 signer/trust 已重建。M2 正式 rebind 尚被后续 Workflow coverage 门阻塞 | **keep（Runtime/MySQL correctness）；M2 canary 待续** |
| opt-12 rebind probe / opt-13 blocker | Opt-12 Delivery（无模型候选提交） | 从格式修复后的 M2 checkpoint 通过正式 evolution audit/rebind 消费新 Runtime module，继续 Runtime/J06 | `m2-fieldservice-e235a3d6e4fb-mysql-rebind-opt12-01`（新项目、新空 MySQL） | 首次 apply 67ms 在写入前报 `model.capability_lock_drift`；一次只读 validate 74ms 后唯一诊断为 record-created `warranty_waiver_approval` 无 executable coverage，22 项其余 unchanged。现有正向 Action 已声明 create 精确 trigger object；validate 与 acceptance prepare 均漏识别该真实入口。Opt-13 两个 project-visible `gpt-5.6-sol/high` task 均在执行前被账户额度上限拒绝（恢复时间 2026-08-26 22:15），无代码/commit | **blocked；Opt-13 未开始，不晋升基线** |

本轮起启用分阶段检查点：`requirements-complete → model-valid → post-apply → source-finalized`。后续批次声明最早受影响阶段，只复用其上游 `keep` 检查点；同阶段 A/B 从同一父检查点独立派生，每个派生 run 使用新的空 MySQL database。检查点哈希与内部 Git commit 记录在 `runs/m2-fieldservice-fc706dc393be-mysql-pretest-opt1-01/checkpoint-manifest.json`。

## 2026-08-22 M2 Opt36 MySQL 最新基线

固定环境为 `gpt-5.6-sol/high`、本地 MySQL fresh bootstrap、Plane `v0.18.0-opt36.1ebe449`。正式分母为 122 个用例，连续三轮结果均为 `122/122`；验收时长依次为 `73.42s / 67.65s / 69.81s`，均值 `70.29s`、中位数 `69.81s`、极差 `5.77s`。formal acceptance check 为 `passed`，异步导出跨 Runtime 重启恢复成功，`attempts=2`、`resumed=true`、`duplicate_effects=0`。

| 批次 | template commit | 范围 | 复验结果 | verdict |
|---|---|---|---|---|
| opt-36 baseline | `skill_v2@1ebe449fdb8eccf24e2d073b3eedc1ee90deebf4` | 导出 artifact/MySQL LONGTEXT、scheduler durability/reschedule、portal notification acceptance fixtures、验收身份约束下强制 async export；保留每轮独立提交链 | fresh MySQL；全量 acceptance 连续三轮 `122/122`；`73.42s / 67.65s / 69.81s`；正式检查通过 | **keep；晋升 latest M2 full-acceptance baseline** |

完整身份哈希、三轮明细和 template commit 链记录在 `scorecards/m2-fieldservice-opt36-mysql-baseline.json`。未复制 Runtime bundle、packet 或大体积 acceptance evidence。

## 2026-08-22 S1 MySQL 普适性分阶段验证

M2 三连基线之后，以独立案例 `s1-ticketing-opt44-mysql-generality-02` 验证优化是否具备普适性。每轮均由 `verdent-template` 独立 Codex task 在干净 worktree 修改、单独 commit 并 fast-forward push；评估侧使用全新本地 MySQL schema，失败 cohort 通过目录改名归档，不复用数据库。

| template commit | 优化节点 | fresh MySQL 实证 | verdict |
|---|---|---|---|
| `73cce2db11611f347e59b081d59764c315c66cf1` | stable state root 改为唯一目录契约，移除旧目录兼容分叉 | 后续 cohort 均按新目录启动与归档 | **keep** |
| `7ee89b98d746cd496ba11d11735cb1e5a5ec13ed` | 删除公开 `--skip-dependency-resolution`，`model apply` 强制解析依赖；未知参数 fail-closed | CLI/Skill 回归通过，后续 apply 无绕过入口 | **keep** |
| `5c90131b3081dbca1cc468b690e9e6076462ed89` | state-chain runner 读取模型 `default_value`，不手写 Runtime-owned lifecycle 字段 | 失败原因从 runner 默认投影推进至 Runtime 授权节点 | **keep** |
| `65978c69bea6cdbab07750a6dcda71252905f433` | Runtime 对 create 的可写性校验绑定原始输入，不把系统默认注入误判为调用方写入 | 默认生命周期值可以由 Runtime 合法注入 | **keep** |
| `4dcf381600cb9bac0a153168e68e1f10fb0ec013` | state-chain CRUD fixture 身份在并行 case 间唯一 | S1 标准分母由 `28/65` 提升至 `44/65`，新增通过 16 项，failed=0 | **keep** |
| `6d086a949a111e3ba9629409aac278dbbf30042d` | 标准 runner 实现通用 Runtime `object_create` family | S1 由 `44/65` 提升至 `51/65`；8 项中 7 项通过，暴露整表 persistence diff 的并发污染 | **keep；待证据修复** |
| `cce671d1597fae4b6b1de5f0352e30cbcfe85980` | `object_create` persistence oracle 改为 recordID + 本 case 提交身份的 keyed projection；正向/replay/conflict/denied 精确绑定 record、receipt、audit | Opt56 + fresh MySQL `domainry_s1_opt56_generality_14`、`--parallel 4`：`52/65`、not_passed 13、failed 0；原 `mechanism.idempotent_replay.operations.support_agent` 通过，其他结果无劣化。结果 SHA256 `c658002f7ba9e48905bd98606cb575d3329c5d60e3708bd41a633655bd66862b` | **keep** |
| `39d85c96e909770cef3cc9a055d747025b2fa967` | 标准 runner 实现通用 Runtime `object_update` 5 类证据，并给 Runtime update audit 增加幂等 key 哈希绑定 | Opt57 + fresh MySQL `domainry_s1_opt57_generality_15`：5 个 update 项中 4 项通过，但总结果 `54/65`、failed 3。实证同一 record 先被 `object_create` 创建、随后被并行 `object_update` 选中改写；`runtimeRouteFootprint` 未声明 create/update 对象表，污染旧 Action denied 与 create replay 证据，且一个 update 返回 500 | **rework；保留功能提交，下一提交补调度 footprint 后复验** |
| `14df37271c4a4cbf036cda7c3eb6072f56edc271`（父提交含并发外部 `eb47300f511758c8372f7a2a02575480512d3c86`） | 从 typed Runtime acceptance seed binding 推导 create/update 业务对象 footprint；同对象 CRUD/Action 进入同一 component，不同对象继续并行；无法解析写集进入 exclusive global | Opt58 + fresh MySQL `domainry_s1_opt58_generality_16`、`--parallel 4`：`57/65`、not_passed 8、failed 0；5 个 `runtime_object_update` 全过，Opt57 的 3 个交叉污染全部消失，旧 52 项无退化。结果 SHA256 `1ab8c8227ebe3e4d8755bdd301cd973cbde9a4c9bedcf1c8e9e094354067029a` | **keep** |
| `1ecb8351fb643d5016f362dca2d1cafbfe6beb6a` | concealment oracle 接受 Runtime 正式 typed 契约：HTTP 404，或 HTTP 403 且精确错误码 `backend.record.outside_scope`；其他 403、空 code、2xx、5xx 继续拒绝，并要求持久化无变化 | Opt59 + fresh MySQL `domainry_s1_opt59_generality_17`、`--parallel 4`：`59/65`、not_passed 6、failed 0；`resolve` 与 `start_processing` 两个 `data_scope_concealed` 均通过，既有 57 项无退化。结果 SHA256 `9e5aa3cc1d5cca845eef3ed896343dc3a829cea04c858b8682422f131d968612` | **keep** |
| `ea84242077283179a4582829d79eebb9414eebfe` | 标准 runner 实现通用 `business_audit_event_list`：按 case 写入当前 principal 可见事件与同 workspace 不同 principal 控制事件，经真实 HTTP 精确验证 actor/role/workspace/event/record，并复核持久化与 foreign-workspace 拒绝 | Opt60 + fresh MySQL `domainry_s1_opt60_generality_18`、`--parallel 4`：`61/65`、not_passed 4、failed 0；`runtime_business_audit_event_list` 的 `success` 与 `data_scope_visible` 均通过，既有 59 项无退化。结果 SHA256 `91dfe2861b74a1532be3cd1ab565053802e3d9f6177c51da08d3b30509d59bd0` | **keep** |
| `a4f6c274a67692cd6f49ec49e1eb06c57aa30e8a` | 将 portal-only notification fixture 一次性重构为 business/portal 共用 inbox fixture；business probe 使用真实 `limit/cursor`，排序事实修正为 `updated_at DESC, id DESC`，两条同时间戳可见行强制证明 ID tie-breaker，并以 recipient/surface 双控制行证明作用域 | Opt61 + fresh MySQL `domainry_s1_opt61_generality_19`、`--parallel 4`：`63/65`、not_passed 2、failed 0；`runtime_business_notification_list` 的 `bounded_page_boundary` 与 `stable_cursor_traversal` 均通过，既有 61 项无退化。结果 SHA256 `7aed891b37f9ebcaef95d68ea2eb798a37183879f5bf2886c6b4b85954b3a046` | **keep** |
| `5fe5434f06fbd7b2158c07ce0a8c0afcecad5e1c` | 从 Runtime 正式 canonical Action kind 与 Handler 显式写操作统一投影 `MutatesObjects`；report stale-cursor 执行器与并行 footprint 共用同一 source mutation candidate 集合，真实调用后以 source snapshot 变化确认已提交，无变化时继续尝试下一候选 | Opt62 + fresh MySQL `domainry_s1_opt62_generality_20`、`--parallel 4`：完整 `65/65`、skipped 0、failed 0；两条 `report_ticket_status_summary` stale-cursor 均通过，原有 63 项无退化，formal acceptance check=`passed`。分母 SHA256 `46a479468ba828c354e84928877e957c19d09b52f37a28ea8831713466c8fa88`，结果 SHA256 `4510b9efe0ad23ebc41a6e981aef32f808971ec226259fcb4aeb1ac409e4acff` | **keep；S1 full acceptance baseline** |
| `7e43fe6f821bf561b6f4101ce012261483c5fee2` | 从当前源码按正式 release 约束重建仓库跟踪的 Builder Skill CLI，修复后续 `skill update` 把已删除参数带回预编译分发产物的问题；不改源码、Runtime 或业务语义 | 连续两次构建 SHA256 均为 `177bae770e7801e9c2ec498246a141c09cb49d9a2642d73ce3827354a48424d6`；help 与本地/远程 binary strings 均无 `--skip-dependency-resolution`；CLI + internal/builder 回归通过，远程 `skill_v2` 已核验 | **keep；分发产物一致性基线** |

S1 已完成完整标准验收 `65/65`。下一阶段不再围绕 ticketing 调整，改从评估仓库选择至少两个业务形态不同的案例，以 fresh MySQL 逐节点运行并审计当前 Skill 的跨案例普适性。

## 2026-08-22 M1 CRM 普适性分阶段验证

以 `m1-crm-opt63-mysql-generality-01` 从独立 requirements-only Git 根开始，不复用 M2/S1 模型或交付物。候选 Agent 固定 `gpt-5.6-sol/high`，Skill/Plane 基线为 `skill_v2@7e43fe6f821bf561b6f4101ce012261483c5fee2` / `v0.18.0-opt63.7e43fe6`。

| 节点 | 当前实证 | 归因 / 下一步 |
|---|---|---|
| requirements / PRD | 纯耗时 `768s`；输入 token `1,955,419`（cached `1,847,808`），输出 `34,896`，reasoning `14,876`；PRD `49,120 bytes / 239 lines`，SHA256 `a4385bf2d8aa0cd55010b93889f058fc1c8b70ff7116b9afca549cdb45bd7b38`；requirements Gate `7/7` | Skill 将 11 个未指定细节均升级为 open，并声称 D-001–D-008 阻塞模型。评估审计确认其中多数是 Runtime 契约发现、保守安全默认、确定性技术选择或验收 fixture 设计，而非缺失的业务事实；当前最大普适性问题是“关键业务歧义”边界过宽，导致结构化需求也无法自主进入 model。下一轮只修通用分类规则，不写 CRM/ticket/fieldservice 特例。 |

| template commit | 优化节点 | 验证 | verdict |
|---|---|---|---|
| `4ba5d4902f46de7f4a47c1516f378e4038660034` | 以 development guide 为唯一权威，将未决项分成 `business_blocker` / `contract_discovery` / `safe_implementation_decision` / `product_follow_up`；只有改变可观察业务结果、权限、金额含义或业务状态的第一类阻塞 model；隐私默认最小权限/敏感/不导出，验收对照身份不推导业务基数 | 独立审查无 benchmark/业务特例；routing + identity + release contract `28/28`，实际 packaging smoke 通过；仓库全量 release gate 的既有生成字节/frontend materialization/architecture marker 基线故障不在本轮文件 | **keep；待 M1 checkpoint 增量实证** |
| 同一提交 `4ba5d4902f46de7f4a47c1516f378e4038660034`（Opt64 增量实证） | 从原 requirements-complete 检查点重分类 D-001–D-011，不进入 model/DB/Runtime | Agent 将 blocker 从 8 个降至 4 个，PRD `53,789 bytes / 240 lines`，SHA256 `d89050635a8f5506295cd7efe4eb0f89829751c6a89e6ec621987d8ad1a16ec6`；原始 requirements SHA256 仍为 `e0efeb60…`。但仍把未要求的 currency/range、approval 附加 lifecycle、customer read actor、timezone/holiday calendar 判成 blocker；金标准只要求 exact-decimal+阈值、独立 pending 审批且 lead 状态不变、任何角色 customer update/delete 被拒、工作日 cron。执行 `1,282s` 后因 requirements-only Gate `--bind` 猜测和临时 regex 验证器连续误判而人工终止；最后可用累计 token：input `2,812,685`（cached `2,683,136`）、output `43,425`、reasoning `11,813`；无正式 Gate 通过声明 | **rework；不晋升 checkpoint，继续收窄 blocker，并修 requirements-only Gate 标准路径/fail-closed 验证** |
| `27103834c3c5ee91d3ba32d7f048910caffd4e9e` | blocker 必须存在至少两个互不兼容且会改变明确可观察结果的选择，并只阻塞最小切片；补 exact-decimal/独立审批 pending/不可变资源无 read actor/工作日调度缺 timezone 等通用非阻塞规则；requirements-only Gate 新增 requirements 绑定，shell pipeline 强制 pipefail | 项目 task 回归 `74/74`、packaging 两次一致；独立回归所选 routing/gate/identity/release `67/67`。独立审计发现 requirements identity 初版只哈希 PRD，权威 `requirements.md` 单独变化不会 stale，故不直接晋升 | **keep blocker 规则；Gate identity 需 follow-up 后复验** |
| `14874be3467a90932c3eebf3a90fb552c5ea775a` | 将 requirements identity 扩展为确定性需求证据闭包：必需 PRD、存在时根 `requirements.md`、确有 frontend source 时过滤依赖/构建/cache/本地产物后的完整 `frontend/**`；相对路径排序，symlink 越界 fail-closed | 项目 task 完整回归 `78/78`，packaging 两次一致；独立 diff/远程 SHA/业务特例审计通过。构建 Plane `v0.18.0-opt65.14874be`，Application Delivery/Skill artifact SHA256 `09d9bee4…`，隔离安装 CLI `6ab39c06…`、Skill tree `71b29502…` | **keep；进入 M1 Opt65 requirements checkpoint 复验** |
| 同一提交 `14874be3467a90932c3eebf3a90fb552c5ea775a`（Opt65 M1 增量实证） | 从与 Opt64 完全相同的原始 requirements checkpoint 重做 D-001–D-011 分类，只运行 requirements/domain-truth/done，不进入 model/DB/Runtime | Agent 有效修订 `752s`，进程 wall `984.20s`；input `6,384,073`（cached `6,185,472`）、output `43,623`、reasoning `9,918`。原始 `requirements.md` SHA256 保持 `e0efeb60…`；PRD 从 `49,120B` / `a4385bf2…` 变为 `55,710B` / `4272da5d…`；分类为 `business_blocker=0`、`contract_discovery=1`、`safe_implementation_decision=6`、`product_follow_up=4`；requirements `9/9`、domain truth `7/7`、done `4/4`、TODO `20/20`。相较 Opt64 被终止的 `1,282s`，有效修订时间少 `530s`（−41.3%），且成功进入 model-ready。独立审计同时发现 PRD 虽声明后续 fresh local MySQL，J11 仍残留 `SQLite query profile`；Skill verification/technical gates/reports/TODO/harness 多处硬编码 SQLite，现有 Gate 未发现 driver 冲突 | **分类与 requirements identity keep；数据库 driver 一致性 rework，暂不进入 model checkpoint** |
| `2a5d5ece939e9e4ec0de89fadcff66e367f3ad43` | 验收数据库改为 managed Runtime cohort 的 `database_driver` 驱动；query-profile dialect/plan format 与 sqlite/mysql/postgres 强绑定；Python harness 使用显式 DB-API connector、cohort marker 和 DSN/密码抑制，禁止 SQLite fallback；requirements-only Gate 解析 PRD 的显式 driver 并拒绝跨 driver 验收旅程 | 独立项目 task 修改 22 文件并快进推送；CLI 正式双构建确定性，父 `36,454,098B`、新 `36,454,194B`（+96B），Skill tar 双构建 `11,266,652B` / SHA256 `6f269184…`。task 回归 Python 57、相关 Go 两包、tar 3、release 分组 23+42+14+19 均通过；独立复验 Python `57/57`、`go test ./internal/builder/backendacceptance/...` 两包通过、diff-check 通过。仓库全量 Go/release gate 仍有 diff 外既有红灯（golden/frontend materialization/CLI literal/workflow timing 等）；Python 测试有一条未关闭 SQLite 连接 `ResourceWarning`，不影响结果 | **keep；下一步从 Opt65 post-PRD checkpoint 仅重跑 driver 一致性修正，再进入 model** |
| 同一提交 `2a5d5ece939e9e4ec0de89fadcff66e367f3ad43`（Opt66 M1 增量实证） | 从 Opt65 model-ready checkpoint 仅重跑 requirements database-driver 一致性节点，不进入 model/DB/Runtime | 新 Gate 在编辑前 fail-closed 指出 PRD 第 225 行与 `database_driver=mysql` 冲突；Agent 仅将 `SQLite query profile` 改为 MySQL `EXPLAIN FORMAT=JSON`。有效工作 `370s`，进程 wall `508.28s`；input `3,372,939`（cached `3,236,864`）、output `20,722`、reasoning `7,026`。独立 diff 证实产品 PRD 恰好一行变化，SHA256 `4272da5d…`→`c25c7882646be6febfb0e44f081919908e48081172375aa4beb5d5c8f51d062d`，`requirements.md=e0efeb60…` 与阶段账本 `3225bc45…` 均未变；分类仍为 `0/1/6/4`；requirements `8/8`、domain `5/5`、done `4/4`、TODO `17/17`，database contract=`mysql` | **keep；M1 requirements checkpoint 晋升，下一节点 model** |
| 同一提交 `2a5d5ece939e9e4ec0de89fadcff66e367f3ad43`（Opt66 M1 model 自然基线） | 从晋升的 requirements checkpoint 运行 capability discovery、完整 model、validate、plan，不进入 apply/DB/Runtime | active `1646s`，wall `2100.11s`；input `18,336,839`（cached `17,959,168`）、output `73,254`、reasoning `22,307`。category index 先因缺 SDK 失败 1 次后成功 1 次，17 个所选 packet 无重复。自制 preflight 两次报 0，但正式 validate 共 15 次、8 个唯一批次 `1,1,1,1,8,14,6,0`、累计 32 diagnostics；其中 7 次是 Gate 不保留诊断正文导致的直接重复。最终 validate=valid、plan=`27/0/0`。独立语义审计发现拒绝原因被替换为 `$record.id`、D-001 未指定 currency 被固定为 CNY、漏斗 SQL 不产生缺失状态桶、委托创建的 scope owner/recipient 仍未证明、model-only TODO 被记成 done | **rework；不晋升 apply，先做通用 no-HTTP model preflight + compact diagnostic artifact，再从 requirements checkpoint 重跑 model** |
| `08e24832a7d66857722b8122dd2387781aad1613` | 新增公开无 HTTP `model preflight`：复用正式 model/SQL loader、strict item contract、Ledger graph、进程内 authoring validator 与确定性 Runtime manifest compiler；CLI 原子落盘完整诊断，stdout 只返回小 locator；Skill 先 bootstrap Runtime Client，再做 category index；model-only TODO 使用 `--expected-stage model`；不增加 bypass/兼容参数 | 独立项目 task 从父 `2a5d5ece…` 单提交快进推送，相关 Go/vet 与 release/Skill/Gate/context/TODO 101 项 Python 回归通过；旧 `--skip-dependency-resolution` exit 1、stdout 0B。独立复验提交/远程/工作区/CLI 与定向 Go 测试通过；故意将 Plane 指向不可达地址时，对 M1 结构合法模型副本 0.3s 返回 local `valid`、artifact 2630B、stderr 0B。构建并健康启动 Plane `v0.18.0-opt67.08e2483`，隔离安装 CLI SHA256 `ec321096…`、Skill tree `e0a4e7ef…` | **keep implementation；下一步从同一 accepted requirements checkpoint 重跑 M1 model，实测 diagnostic/validate 次数与业务语义，不以本地 valid 代替语义晋级** |
| 同一提交 `08e24832a7d66857722b8122dd2387781aad1613`（Opt67 M1 model 实证） | 从相同 accepted requirements checkpoint 重跑 capability/model/preflight/validate/plan，不进入 apply/DB/Runtime | wall `2793s`，live model `2525s`；input `16,950,454`（cached `16,420,096`）、output `94,889`、reasoning `35,954`。22 个所选 capability packet 均只加载一次。preflight 共 7 次：首轮漏 `--json` 为命令契约失败，6 个有效批次 `32,29,3,44,0,0`；canonical validate 从 Opt66 的 15 次降至 2 次，均 0 diagnostics；plan 一次=`33/0/0`。独立复验 preflight/validate/TODO 全绿，但语义审计确认两个 blocker：`lead.status` 无 `default_value:new`；Runtime 已产生 `approval_comment`，authoring validator 却不允许 `$workflow.approval_comment`，导致拒绝分支用固定文案替代实际原因 | **preflight keep；模型不晋升 apply。下一轮优先修 post-approval variable authoring contract + 默认状态语义闭环；`--json` 冗余参数另做独立 commit** |
| `73769154b8cb372c592ec989ba960b2bfbe57a69`（Opt68，父 `08e24832…`） | 通用默认状态与审批上下文语义闭环：generic create 的明确初态必须落为合法 `default_value`；仅在所有入口路径都经过真实 approval decision 且处于 approved/rejected/returned 分支的 Action 开放 `$workflow.approval_comment` / `$workflow.approval_decision`；skip/bypass/preapproval 继续 fail-closed | 独立 task 相关 authoring/definition/workflow/ledger 包全绿，31 项 Skill routing/identity/release 回归通过；全仓既有 frontend/golden/architecture/旧断言红灯不归本提交。Application Delivery `v0.18.0-opt68.7376915` 构建并以专属 signer 启动，Plane health 9/9。远端 `skill_v2` 后续出现两条并发大提交，故本轮严格冻结并只评估该 exact commit，不把并发 Runtime 改动混入候选 | **keep；进入 M1 exact-commit model 复验** |
| 同一提交 `73769154b8cb372c592ec989ba960b2bfbe57a69`（Opt68 M1 model 实证） | 从同一 accepted requirements checkpoint 重跑 model 节点，验证两项修复是否由新 Agent 自然产出且降低收敛成本 | wall `1593s`，live model `1364s`；input `13,011,408`（cached `12,721,664`）、output `69,290`、reasoning `25,196`。category index 1 次，21 个 packet 各 1 次；preflight `2,5,0,0`（4 次、累计 7 diagnostics），validate `0,0`，plan `37/0/0`；17/17 Gates、TODO expected-stage model 通过。独立复验 preflight/validate/Plane health 全绿；`lead.status.default_value=new` 与拒绝分支 `$workflow.approval_comment` 均自然出现，授权/状态机/全桶漏斗/受控导出/两部门 fixtures 审计无 blocker。相对 Opt67 live time `-46.0%`、input token `-23.2%` | **keep；M1 model checkpoint 晋升，下一节点 model apply（仍需 fresh MySQL 全链证明）** |
| `d47b16913dfc047763224f178a4cb15c242dfb7f`（Opt69，父 `73769154…`，远程 `codex/opt69-remove-model-preflight-json`） | `model preflight` 只有 JSON 输出，删除无选择价值且易漏传的 `--json`；不做兼容层，形成唯一正确调用 | 独立 task：无参调用成功并保持 JSON；旧 `--json` exit 1 且明确 `flag provided but not defined: -json`；CLI/help/Skill/Gate/context 示例和内置 binary 同步；相关 Go 4 包、Builder Python `62/62`、真实打包 CLI Gate、diff-check 全绿；独立核验 commit 父链、工作树、远端 SHA 一致 | **keep implementation；不混入正在运行的 Opt68 M1 checkpoint，待下一 Application Delivery/跨案例节点采用** |
| 同一提交 `73769154b8cb372c592ec989ba960b2bfbe57a69`（Opt68 M1 apply 实证） | 从已晋升的 M1 model checkpoint 只运行一次 canonical validate 与一次 model apply，不重跑失败命令，不进入实现/Runtime/数据库 | Agent wall `644s`、apply stage `314s`；input `3,361,354`（cached `3,217,664`）、output `27,203`、reasoning `12,515`。validate `250.345ms`、0 diagnostics；apply `897.268ms`、exit 1，本地 Ledger 原子同步 `37 writes/0 deletes` 后在 Project Contract publication 前失败，未产生 delivery/materialization/source skeleton。独立 recovery 请求取得权威错误：`domainry_plane.project_delivery_projection_failed`，`lead.lead_lifecycle` 的 `qualified→converted` 边重复；这证明 Opt68 preflight/validate 与 publish projection 存在验证缺口 | **blocked；不进入 implement。下一轮补本地重复边诊断及通用 Project Contract projection preflight** |
| `255f12b1f1327a546deac430387d55c6041ea604`（Opt70，父 `d47b169…`，远程 `codex/opt70-state-machine-edge-validation`） | 复用 Project Contract `(from,to)` 权威判重，不因 `action_key/workflow_key` 不同放过重复边；本地 authoring 干净后再运行确定性的 Project Contract projection，兜住其他“validate 绿、publish 必败”边界 | 独立 task 14 文件、相关 Go/vet、Skill packaging/routing/context/Gate/TODO `78/78`、`make skill-test`、Definition parity、diff-check 全绿；4 类扩展红灯均在父提交复现。真实 M1 冻结副本：`model preflight` 无 `--json` 在 `0.27s` exit 1，`model validate --json` 在 `0.30s` exit 1；均只报 `behavior.transition_edge_duplicate`，`ledger_path=backend/model/20-crm-objects.json`、第二边 index 4、第一边 related index 3。相对 apply Agent `314s` 才暴露，错误左移约 `313.7s` | **keep；M1 进入最小模型修复并重新 apply，随后使用 exact Opt70 Delivery** |
| 同一提交 `255f12b1f1327a546deac430387d55c6041ea604`（Opt70 M1 最小模型修复） | 从失败模型副本只修 preflight 指出的重复状态边，不重跑 requirements/model 全链 | wall `723s`、live model `456s`；input `7,375,777`（cached `7,125,504`）、output `27,782`、reasoning `9,434`。产品命令合计仅 `1.076s`：preflight `1 diagnostic→valid` 两次、validate 一次 `248.542ms` valid、plan 一次 `255.716ms`=`0/1/0/36 unchanged`。只删除第二条 `qualified→converted` 关联，两个业务 Action、审批 Workflow、授权和幂等契约保留；最终 model identity `78f8c62f…`、Blueprint `7c073573…`。约 `455s` 花在局部修复仍重载 whole-project guide/template | **模型修复通过；局部 continuation context 为后续通用性能靶点** |
| 同一提交 `255f12b1f1327a546deac430387d55c6041ea604`（Opt70 M1 apply/materialization） | 从修复模型仅运行 preflight、validate、一次 apply；不重跑失败 apply | Agent wall `674s`、apply interval `517s`；preflight `323.851ms` valid，validate `248.856ms` valid，apply `1742.242ms` exit 1。apply 已完成签名发布和物化：delivery `sha256:83ea2c5b…`、37 items、98 files（59 generated backend、9 Handler、9 tests、0 frontend）；自动 finalization 对 9 个未实现 Handler fail-closed，`8 passed / 1 failed / 1 skipped_dependency`，无 DB/Runtime。产品命令共 `2.315s`，其余主要为身份/Gate/证据编排 | **发布/物化通过；按节点进入 9 Handler 实现，不把预期 finalization fail 误判为 publication fail** |
| 同一提交 `255f12b1f1327a546deac430387d55c6041ea604`（Opt70 M1 implementation） | 在同一冻结 delivery 实现 9 个 Handler 与测试，只做 actions 范围验证，不进入 finalize/Runtime/DB | 18 个 project-owned Action 文件完成，两个包测试首次均通过：CRM wall `1.81s`、reporting `0.58s`；requirements/PRD、model/report、generated/domain、delivery/contracts、materialization/build identities 全部 byte-identical，无 SQLite/DB。实现节点从 `18:28:28Z` 到最晚证据闭合 `18:53:41Z` 为 `1513s`。桌面 exec session 丢失后原 Agent 实际仍运行，误启动 resume 造成两个同 session Agent 并发；合计 input `25,148,715`（cached `24,608,768`）、output `145,863`、reasoning `39,648`，且同一 actions check 被两个 Agent 各执行一次。两次均 stdout 0B/stderr 498B，收据只存 hash/bytes 无正文；同时 Gate-owned Go test 被 source-finalization 前置条件拒绝，形成实现检查闭环 | **业务实现通过、样本编排无效；Opt71 修 session/gate 互斥、测试/终结依赖及 bounded failure evidence 后，从该冻结副本恢复 check** |
| `e117a0a065eb9de062c60a3f92d7d3d66d90eee9`（Opt71） | 将 implementation Gate 收口成可恢复状态机：同一 session/round 互斥；测试不再错误依赖 source finalized；失败 CLI 的有界 stderr/结构化诊断由 CLI 原子持久化并进入 Gate evidence；终态 Gate 禁止复用 | 独立 task 完成相关 Go/Python/Gate/Skill/release 回归并快进推送。隔离安装与 Plane 健康验证通过；M1 从冻结 delivery 开新 session 后，首次失败 Gate 保留完整 3 条结构诊断，不再出现 stdout 0B 无正文，也未重复执行同一 Gate | **keep；实现恢复链可审计** |
| 同一提交 `e117a0a065eb9de062c60a3f92d7d3d66d90eee9`（Opt71 M1 Action recovery round 1） | 只修 canonical Action check 首批 3 条结构问题，不运行 apply/finalize/Runtime/DB | Agent wall `690s`；input `3,823,171`（cached `3,682,560`）、output `30,304`、reasoning `14,802`。产品命令：`gofmt 0.01s`、CRM tests `1.446s` 通过、actions check `0.195s`；修复 unbounded query 与 discarded capability result 后，剩余唯一诊断 `project.action_capability_loop_io`，定位 stale-reminder 循环内 notification create。需求、模型、delivery、generated source 与测试均冻结 | **缺少合法批量通知能力；停止 workaround，转 Opt72 平台能力闭环** |
| `d9d0874496adbbd89e90f59a8582f7b3b88d3530`（Opt72，父 `e117a0a…`，远程 `codex/opt72-action-bounded-batch`） | 为授权 Action facade 增加通用 `ExistsBatch` / `DispatchBatch`（复用既有 `CreateBatch`）：输入 `1..200`、顺序保持、结果一一对应、错误无部分结果；继承 workspace/principal/grant/data-scope；mutation 与 notification 保持一个 Runtime-owned Action transaction；notification 全批预检与重复键拒绝；checker 继续禁止循环内任何 capability I/O，并新增直接/间接递归检测 | 独立 task 25 文件 `+436/-122`；相关 Go、Skill packaging `91` 项、完整 `verify_builder_release.sh`、Delivery golden/parity、notification atomic/order/staging 均通过。临时通用证明项目中旧循环 Handler 被拒，改为合法 batch 后 actions check `valid/0` 且 focused Go test 通过；SDK/domaincodegen 升至 v22。全仓另有 3 个父提交可复现的无关测试红灯。Plane `v0.18.0-opt72.d9d0874` 与隔离 Skill 安装健康，CLI SHA256 `3d3b5eb5…` | **keep implementation；需在真实 M1 delivery 迁移中验证旧 test double 的 v22 接口升级成本** |
| 同一提交 `d9d0874496adbbd89e90f59a8582f7b3b88d3530`（Opt72 M1 v22 migration probe） | 在真实冻结 M1 上仅做 unchanged-model Application Delivery 升级探针；先取得正式 evolution audit，再做一次 audit-bound 原子迁移，不修业务源码、不进入下游 | Agent 进程 wall `875.43s`（pre-final usage snapshot `796s`）；input `8,137,652`（cached `7,887,872`）、output `33,336`、reasoning `12,085`。产品命令仅 `4.308s`：preflight `301.028ms`、validate `229.879ms`、audit checkpoint apply `1622.082ms`、audit-bound apply `2154.842ms`。审计 `4d8cb9d5…` 证明 Blueprint/project contract/runtime API 不变、96 个交付侧预期 diff、18/18 project-source 冲突保留；v22 在 staging 物化 126 文件且依赖已解析，finalizer 唯一诊断仍为 `project.action_capability_loop_io`，promotion 未发生，live 产品/生成/domain/contracts/receipts byte-identical | **平台能力在真实案例可达；下一节点批量化 stale-reminder Handler/test doubles 后重新原子迁移。另记录局部 whole-guide/TODO/Gate 收尾固定开销约 871s** |
| 同一提交 `d9d0874496adbbd89e90f59a8582f7b3b88d3530`（Opt72 M1 batch repair + promotion） | 将 stale-reminder 的 per-item `Exists/Create/Dispatch` 改为一次 `ExistsBatch/CreateBatch/DispatchBatch`；全量内存校验、严格 cardinality/identity、零长度保护、稳定 per-lead/business-date source identity；补 v22 test doubles，并以 Go overlay 对 immutable staged v22 facade 做预晋升测试 | Agent outer wall `1159.40s`，session snapshot `1092s`；input `7,231,663`（cached `7,017,728`）、output `46,248`、reasoning `17,347`。5 个 project-owned Go 文件；staged-v22 CRM test `2.109s`；fresh audit `4ba97df2…` 证明 37 model items 与 protected identities 不变；audit-bound apply `4.571s` 成功，live delivery `sha256:4d249113…`、materialization `f63ae295…`、atomic finalization `c195d0b4…`。Gate-owned active 共 `8.672s` | **keep；真实 M1 完成 v22 原子晋升。whole-project light batch 暴露 TODO 自失效、预期 evolution-review 状态表达与 audit predicate 过严三类通用编排开销** |
| 同一提交 `d9d0874496adbbd89e90f59a8582f7b3b88d3530`（Opt72 M1 compact source-finalization continuation） | 显式 compact profile，只执行 resolver 返回的 `Actions check → source finalize → ./actions/crm test` 三条 recipe | outer wall `138.55s`；resolver 1 次 `0.276s`，三 Gate 首次通过、零重试，active `1.991s`，合计 `2.267s`；Actions check `297.600ms` valid/0，finalize `153.116ms`，CRM test `1540.696ms`。finalization receipt `a7e0cec1…`，source tree `fa63fcbc…`，remaining source gap=none | **keep；相对 whole-project repair outer wall 降 88.0%，证明局部 continuation 应优先由 resolver 直接给出封闭 recipe** |
| 同一提交 `d9d0874496adbbd89e90f59a8582f7b3b88d3530`（Opt72 M1 canonical project verify） | 冻结已 final source checkpoint，只运行一次 canonical `project verify`，不进入 package/Runtime/DB | outer wall `506.54s`；Agent 报告有效区间 `431s`，input `4,724,375`（cached `4,542,464`）、output `17,063`、reasoning `4,902`。产品 `project verify` 仅 `5.992s`，10/10 passed、0 failed、0 skipped，verification receipt `c2bdefe3…e081`；resolver/version/Gate/TODO 控制进程合计约 `6.51s`，其余约 7 分钟用于重复读取 whole-project guide、两份 verify authority、Gate runner 源码和身份整理 | **验证正确但编排 ROI 很差；下一通用优化应提供 compact verify/package profile 与封闭 recipe，避免 Agent 重新发现 Gate 用法** |
| 同一提交 `d9d0874496adbbd89e90f59a8582f7b3b88d3530`（Opt72 M1 canonical project package） | 冻结 verification checkpoint，只运行一次 canonical `project package`，不重跑 verify、不进入 Runtime/DB | outer wall `415.94s`；Agent 有效区间 `372.240s`，input `2,320,379`（cached `2,214,144`）、output `15,070`、reasoning `5,068`。产品 package `7.009s`、exit 0，生成 darwin/arm64 签名包，package receipt `3bd62d3f…fbd0`、manifest/package identity `a464d36e…d622`、runtime binary `822456f7…44da`；冻结 source/finalization/verification 身份不变 | **package 正确但编排约为产品命令 53 倍；compact verify/package profile 是当前最大的通用 token/时间优化项** |
| 同一提交 `d9d0874496adbbd89e90f59a8582f7b3b88d3530`（Opt72 M1 Runtime start 首轮） | 使用 fresh local MySQL schema，仅计划一次 managed start + 一次 status | outer wall `494.02s`；Agent 有效区间 `469.901s`，input `2,704,702`（cached `2,585,344`）、output `18,927`、reasoning `8,583`。schema `domainry_m1_opt72_runtime_01` 创建一次 `0.02s` 且 0 tables；Agent 阅读/重读 guide、Gate/TODO authority 并反查约 600 行 Gate runner 后，仍在 start Gate 命令漏传 `--bind source`，runner pre-execution exit 2：`run requires valid identity bindings`；实际 Runtime start/status 均 0 次，19091 未监听、无 process receipt | **通用编排缺陷：标准 Gate recipe 仍由 Agent 手拼且易漏参数；从空 cohort 新 session 做 compact recovery，不重建 DB/package** |
| 同一提交 `d9d0874496adbbd89e90f59a8582f7b3b88d3530`（Opt72 M1 compact Runtime recovery） | 显式给出带 `--bind source` 的完整 start/status recipe，复用 0-table、未消费 MySQL cohort，不重跑上游 | outer wall `230.16s`；产品 Runtime start/status 仍为 `0/0`。runner 在 `0.000002s` pre-execution 拒绝：`managed Runtime start/status requires its dedicated start or current-health Gate`；Agent 生成的语义等价 label 使用 `executes exactly once`，但 runner 只识别字面短语 `managed runtime start executed once`。19091 未监听、无 process receipt、数据库无新动作 | **确认第二个通用根因：Gate kind 依赖自由文本字面匹配。Opt73 应用机器可读 Gate kind/CLI-owned compact runtime profile，禁止继续堆 label 兼容别名** |
| `440b5fbf8962a2ab89fd956d7d3a1277ff6d6eb8`（Opt73，父 `d9d0874496adbbd89e90f59a8582f7b3b88d3530`，远程 `codex/opt73-runtime-gate-profile`） | Runtime Gate 攄为 machine `runtime_start/runtime_status` kind；新增 CLI-owned `runtime-process-continuation` profile，固定 packaged CLI、bundle、loopback address、Gate IDs、argv 与 `source/runtime/runtime_cohort` bindings；generic run/attach/mark 不再是 Runtime 第二路径 | Skill/Gate/context/routing/identity 76 项、Application Delivery/release 23 项、acceptance 15 项及相关 Go/CLI/Runtime 测试通过；两类历史 pre-execution 失败均回归并保持产品计数 0。CLI SHA `ac6dec4d…9800`、Skill tree `c01a3110…74c5`。交付时一次 launchd 环境误打印导致 signer 轮换；旧 secret/launch jobs 已销毁/注销，新 trust chain 健康 | **机器 kind 与完整 recipe 方向正确；独立代码核验发现 fresh session 仍预设 TODO 存在，继续 Opt74 让 profile 原子拥有 TODO/state/profile** |
| `9a7f0d27d334b807d1bc0f53f35b3e8bdc87b989`（Opt74，父 `440b5fbf8962a2ab89fd956d7d3a1277ff6d6eb8`，远程 `codex/opt74-runtime-profile-owned-todo`） | Fresh Runtime continuation 由 resolver 原子创建 canonical 两 Gate TODO、Gate state 与 profile；调用方只给 project/session/numeric loopback address，不传 label/kind/Gate ID/argv/binding；partial/symlink/non-owned/conflict/rollback/幂等/终态均 fail closed | 相关组 77 passed、release 23 passed、acceptance 15 passed、相关 Go/semantic/Skill packaging 全绿；父环境 `frontendcomponentcontract` 两红灯在父 SHA 同样复现。CLI `0.74.0-opt74.9a7f0d27d334` SHA `49e6873b…754b`、Skill tree `b444ed26…dee1`、package `817e7730…365c`；Plane PID 54986、8283 唯一监听、health 9/9 | **进入真实 M1 空 MySQL cohort：只执行 resolver 返回的 start→status recipes，验证产品计数与 outer wall** |
| 同一提交 `9a7f0d27d334b807d1bc0f53f35b3e8bdc87b989`（Opt74 M1 compact Runtime profile） | Fresh session 不手写 TODO/label/kind/argv/binding；只读 SKILL，resolver 原子落盘并返回 start→status 两 recipe；复用原 0-table MySQL cohort和 Opt72 package | 首次 harness 因隔离 CODEX_HOME 缺 auth 在模型启动前 401，`32.19s`、产品/解析器均 0，排除 Skill 结果；修正后 outer `216.31s`。resolver 1 次 `1.109s`；start 1 次 active `3.888s`，status 1 次 active `0.162s`，resolver+产品 host wall `5.838s`；产品 2/2 首次通过，PID 57252、receipt `1b36cc90…adb7`、MySQL cohort current。未读 whole guide/authority/runner source，未跑上游/canary/acceptance | **compact 编排成功；但独立 OS 核验发现 receipt 假绿：请求/记录 127.0.0.1:19091，实际 netstat/lsof 为 `*:19091`，日志为 `legacy-all address=:19091`。已 managed stop，转 Opt75 修真实 bind + proof** |
| `cb7b562b52b518492298ec1f05c2cc6f2fd08d59`（Opt75，父 `9a7f0d27…`，远程 `codex/opt75-runtime-loopback-bind`） | Managed Runtime 精确传播 numeric loopback host，并用本轮结构化 listener 日志、PID/时间边界、日志片段哈希、HTTP health 与非 loopback 不可达性证明实际监听；wildcard、错误 host/port、旧/伪造/多 listener 均 fail closed 并清理子进程 | 相关 Builder/Runtime/Skill/release 回归通过；旧签名 bundle 可由新 CLI 真实绑定。CLI `0.75.0-opt75.cb7b562b52b5` SHA `95d4954e…7f9`；Plane 在 8283 唯一监听且 health/trust 通过。全仓仅遗留与本轮无关的旧 frontend component 测试红灯 | **keep；修复 Opt74 receipt 假绿与 wildcard 暴露。随后确认 Builder 不应承担任何项目侧前端物化，转 Opt76 清理责任边界** |
| `837b6ae7bbecfcbb681596e81165c60f9b6a6b7d`（Opt76，父 `cb7b562…`，远程 `codex/opt76-remove-project-frontend-materialization`） | 彻底删除 Builder 项目侧 Runtime Client/frontend 物化：移除 CLI 命令、identity、fetch/cache、plan/receipt/staging/recovery/evolution、project seed/template、frontend contract/check/acceptance/package 入口和 Skill 指引；capability discovery 改为 CLI 编译时绑定契约，项目根不再是输入 | 95 文件 `+528/-7545`。空项目与 backend-only 项目直接返回相同 61 个 capability，source=`compiled_cli:c7bd00…a77ba`，目录零写入；旧命令 unknown/exit 1。Targeted Go、Builder release gate、Builder Python `107 passed`、Release Python `27 passed`、Brand Node `10 passed`、Application Delivery HTTP/signature/trust 全绿；旧 `frontendcomponentcontract` 红灯随死链删除。全仓另有 4 个未改 Runtime 断言/预算红灯。Skill 包 SHA `db36aa94…8724`，CLI SHA `d1e5a303…724d`；Plane `0.76.0-opt76.837b6ae7bbec` 在 8283 唯一健康监听 | **keep，作为下一次 M1/M2/跨案例续跑的新基线；Builder 从此只负责后端，平台前端发布可独立存在但不进入业务项目物化或后端 Gate** |
| `27adbf657569eebfb99b3b917341d928f968aa4f`（Opt77，父 `837b6ae…`） | 新增 machine-owned `post-apply-source-finalization-continuation`，把 fresh apply 后仅 Action placeholder 失败的合法状态收口成固定 `actions check → source finalize → focused tests` recipe | fail-closed resolver、routing/identity/release 回归通过；首次 M1 实证暴露 failure snapshot 被错误要求等于 materialization seed 集合，故由 Opt77.1 修正后晋升 | **rework → Opt77.1** |
| `780c92d7391331576afd924dc3b40836ef1acd1b`（Opt77.1，父 `27adbf6…`，远程 `codex/opt77-post-apply-source-finalization`） | 由 Go owner 验证 failure snapshot 完整闭包，materialization-owned 文件仅是必须一致的子集；允许既有 tracked report，仍拒绝非 Action 漂移、伪造与 stale identity | M1 clean backend-only apply 后，18 个 Action 文件从冻结 checkpoint 恢复；compact continuation outer `99.13s`，resolver+三 recipe `3.616s`，全部一次通过；canonical verify outer `289.36s`，产品 `3.673s`，10/10 通过。Skill SHA `00745df9…7ea6`，CLI SHA `10a9a2b8…036` | **keep；M1 source-finalized/verified checkpoint** |
| `3775045f56e9be3ed3d63ab4ccc275440dc99a5a`（Opt78，父 `780c92d…`，同远程分支） | 清除 Builder 残余前端所有权：Project Source Seed 仅允许后端源码；项目不再缓存完整 Application Delivery manifest，改写后端专属 binding；不删除 Plane 面向独立前端 Skill 的共享 SDK 发布 | backend-only 新增前端/SDK=0；已有前端输入的文件集合、mode、SHA 完全不变；Builder 对 SDK endpoint 请求=0；focused Go/CLI、23 release contract、54 Gate、10 context、5 identity、14 routing、Plane/acceptance 全绿。Skill SHA `f6505247…f221`，CLI SHA `8d8b71b7…fef8`；Plane `0.78.0-opt78.3775045f56e9` PID 82234，`127.0.0.1:8283` 唯一监听 | **keep；最新 Builder 边界基线** |
| `f0b9508f9cd83381e118b4a4e3fc2a71a11f22af`（Opt79，父为正式 Opt78 merge `59baea7…`，远端 `skill_v2`） | 新增两个独立、machine-owned、fail-closed 的 `project-verification-continuation` / `project-package-continuation`；Go 固定 requirements/model/source/materialization/finalization/Runtime/backend binding/current receipt checkpoint，Python 只原子编排单 Gate 与固定 recipe；不加载 whole guide/TODO template/verification authority/Gate runner source | 定向 Go/CLI/架构、Gate/context/routing 与 Skill/Application Delivery/Runtime release 共 113 项通过。正式 Skill package `6f67fc47…9d75`、CLI `65a8214b…214`、Skill tree `ad05d093…7618`；Plane `2.4.0-opt79.f0b9508f` PID 1307，8283 唯一 listener、health 9/9 | **keep；进入 M1 compact verify/package 实证** |
| 同一提交 `f0b9508f9cd83381e118b4a4e3fc2a71a11f22af`（Opt79 M1 compact verify/package） | 从 Opt78 backend-only binding + current finalization checkpoint 逐节点运行 verify，再从 current V6 verification 运行 package；每个节点 resolver=1、产品命令=1，不重跑上游 | verify outer `67s`、产品 `3.590s`、10/10，input `121,636`（cached `100,864`）、output `2,242`、reasoning `882`，receipt `98a638a9…5274`；package outer `93s`、产品 `3.950s`，input `190,950`（cached `159,488`）、output `3,538`、reasoning `1,555`，receipt `5395ed0a…a989`、manifest `0e63ddec…e22d`、Runtime binary `822456f7…44da`。合计 outer `160s`，相对旧 `289.36+415.94=705.30s` 下降 `77.3%`、净省 `545.3s`；frontend/SDK 均 0 | **keep；通用编排目标达成，继续 Runtime/MySQL 节点** |
| 同一提交 `f0b9508f9cd83381e118b4a4e3fc2a71a11f22af`（Opt79 M1 Runtime start probe） | fresh local MySQL `domainry_m1_opt79_runtime_02`（起始 0 tables）与 `127.0.0.1:19092`，machine Runtime profile resolver 1 次，只执行 start 1 次，失败即停且 status=0 | outer `56s`；resolver `70.241ms`；start active `5056.133ms`。Runtime 实际绑定 loopback、`/ready`=200 并迁移 158 tables，但 proof fail-closed 后杀进程：自有 Zap listener timestamp `2026-08-23T11:58:53.522+0800`，proof 错用 RFC3339Nano（要求 colon offset），报 `listener event timestamp is outside the current process launch`。Gate receipt `f3768586…57c`，无 listener 残留，cohort 标记 `bootstrap_incomplete`，不复用 | **通用产品缺陷；Opt80 将 proof 严格绑定自有 Zap ISO8601 单一格式，不加兼容/fallback** |
| `c5de15358f7ef8b255eb89c98e39a56bbd5096db`（Opt80，父 `f0b9508…`，远端 `skill_v2`） | 将 Runtime listener proof 时间契约严格绑定自有 Zap ISO8601 `2006-01-02T15:04:05.000Z0700`；无 fallback/双格式；StartedAt 继续独立使用 RFC3339Nano | 真实 `+0800`、负 offset、`Z` 通过；colon offset、非三位毫秒、尾随、malformed、过早/未来均拒绝；PID/boundary/listener/address/surface/offset/hash/tamper/wildcard 安全语义保持。Builder/CLI/Control Plane/Runtime Go、Python 129、release 23 及 signed Delivery/trust 全绿。Skill package `18877b20…ddc8`、tree `da356522…b4ac4`、CLI `4bc0d6f7…daa85`；Plane `2.4.0-opt80.c5de1535` PID 10061，8283 唯一、health 9/9 | **keep；从 M1 已初始化 cohort 恢复 Runtime proof** |
| 同一提交 `c5de15358f7ef8b255eb89c98e39a56bbd5096db`（Opt80 M1 Runtime recovery） | 复用前一 proof 失败前已正式迁移并发布 cohort marker 的同一 MySQL binding，以 fresh session/port 只跑 machine start→status，不重跑 package 或上游 | 正确恢复 outer `132s`；resolver=1；start `1.139s`、status `0.259s`，均一次通过；PID 12243，实际/请求 listener `127.0.0.1:19094`，listener event `2026-08-23T12:15:03.671+0800`、proof SHA `7343d7ae…d694`，health 200、cohort current，process receipt `2426b6b0…f910`。input `196,699`（cached `163,584`）、output `4,865`、reasoning `2,304`。一次试图改绑全新 `_03` 的样本在 Runtime 启动前 `0.523s` 被 same-DSN 状态机正确拒绝，schema 保持 0 tables，排除性能样本 | **keep；M1 Runtime 节点成立并保持运行，下一节点最高风险 semantic canary** |
| 同一提交 `c5de15358f7ef8b255eb89c98e39a56bbd5096db`（Opt80 M1 J07 semantic canary 首轮） | 当前 Runtime 上只执行一条最高风险审批转换 canary，不跑 broad acceptance | outer `752s`，input `5,263,232`（cached `5,045,760`），44 条 shell 命令；真实 Gate active `0.855s`。脚本错误使用默认 identity context，并覆写 canonical secret persistence，导致三名首次登录账号轮换后密码丢失；第一个业务读取 403，未触及 Handler。污染 cohort 托管停止并完整归档，不作为产品结论 | **harness rework；同时暴露 whole-guide/路由发现/脚本生成固定成本约 12.5min** |
| 同一提交 `c5de15358f7ef8b255eb89c98e39a56bbd5096db`（Opt80 M1 fresh clean Runtime） | 从同一 package checkpoint 建立新 0-table local MySQL cohort，只跑 compact start→status | outer `112s`；resolver `89.199ms`、start `3516.253ms`、status `296.613ms`，各一次通过；PID 18237、`127.0.0.1:19095` 唯一 listener、health 200、database identity `11b1a578…7672`、process receipt `dab22891…bb52`；上游 package/verify/finalization 不重跑 | **keep；干净 cohort current** |
| 同一提交 `c5de15358f7ef8b255eb89c98e39a56bbd5096db`（Opt80 M1 J07 canary recovery-02） | 复用薄脚本，改为 canonical Sessions、0600 cohort-bound secret store、Runtime-returned workforce selector | outer `353s`，input `1,495,509`（cached `1,408,512`），Gate active `0.621s`；仍 403。独立 HTTP/Runtime log/MySQL 只读归因证明 Action list、director approval list、director lead detail 均 200；失败实际发生于脚本用 sales_rep 读取 approval/customer closure。PRD D-003 明确 customer 无业务角色读权限，故不是角色绑定缺陷；账号/role/workforce assignment 数据库关联完整 | **harness oracle rework；不得给 customer 增读权限** |
| 同一提交 `c5de15358f7ef8b255eb89c98e39a56bbd5096db`（Opt80 M1 J07 canary recovery-03） | director HTTP 读取 approval/lead，requester 只做 denied/Inbox；customer 改由 canonical AcceptanceDatabase + 显式 PyMySQL 只读持久化闭包 | outer `518s`，input `2,031,477`（cached `1,909,504`），Gate active `0.105s`；在任何 HTTP/session/业务 mutation 前失败：Agent 将 Runtime 正式 Go-style MySQL DSN 当 `mysql://` URL 解析，canonical redaction boundary 报 `external acceptance database connector failed without exposing its DSN`。业务断言 0 次。现有 core 要求 callback 却不提供正式 DSN 适配，迫使每个 Agent 重写连接器 | **通用产品/Skill plumbing 缺口；Opt81 提供唯一严格 canonical Go-MySQL DB-API connector，禁止 URL/fallback/业务特例** |
| `2893aeb086ee1c82b5df99be93c79b3350599dd0`（Opt81，父 `c5de153…`，远端 `skill_v2`） | canonical acceptance core 内建严格 Go-style MySQL DSN→lazy PyMySQL adapter；`AcceptanceDatabase.from_runtime_state(project,state)` 在 MySQL 不再要求 callback；PostgreSQL 高级 callback 与 SQLite 边界不变；异常链/stdout/stderr/artifact 统一脱敏 | 19 harness tests、完整 `verify_builder_release.sh`、Go acceptance/cohort、23 release、56 Gate、Skill packaging/routing/identity 全绿，无父提交红灯。版本 `2.4.0-opt81.2893aeb0`；package `1cc8de43…bea1`、Skill tree `ef5c5ed4…faa0`、CLI `4b36f2de…8dae`、core `a9e24b0d…ab96`；Plane PID 30538、8283 唯一、health 9/9、trust/signer closure 通过 | **keep；从 recovery-03 checkpoint 删除自制 connector 后重跑同一 canary** |
| 同一提交 `2893aeb086ee1c82b5df99be93c79b3350599dd0`（Opt81 M1 J07 canary recovery-04） | 复用 recovery-03 薄脚本，仅删除自制 DSN 解析/connector，改用 `AcceptanceDatabase.from_runtime_state(project,state)`；不重跑上游 | outer `273s`；input `1,109,223`（cached `981,248`）、output `10,890`、reasoning `4,736`，20 条命令；Gate outer `0.157301s`、pure harness `0.074923s`。canonical MySQL 连接已建立，但在任何 HTTP/session/mutation 前报 `external acceptance database cohort differs from managed Runtime`。只读证据证明 DB marker `77972316…e589`，receipt identity `11b1a578…7672`；Builder 按 `contract+driver+DSN identity+marker` 派生 receipt，core 却直接比较 marker，测试假设错误 | **通用 cohort parity 缺陷；Opt82 与 Go 公式统一，SQLite 语义不动** |
| `e4f44975741a5640806f866b77d435e9e662fac4`（Opt82，父 `2893aeb…`，远端 `skill_v2`） | canonical acceptance core 对 external cohort 使用与 Builder 相同的 `sha256(contract + driver + DSN identity + marker identity)` 派生公式；SQLite、PostgreSQL callback、strict MySQL DSN 与身份 fail-closed 边界不变 | focused harness/cohort、release、Gate、routing/identity 与完整 Builder release 验证通过；隔离 Skill/CLI 安装完成，Plane 同端口升级并保持 health 9/9 | **keep；修正 external MySQL cohort 的通用身份比较错误** |
| 同一提交 `e4f44975741a5640806f866b77d435e9e662fac4`（Opt82 M1 J07 canary recovery-05～08） | 从 recovery-04 checkpoint 逐点修正 evaluator launcher、information_schema 大小写、Action optimistic token 与 canonical DB read；每轮失败即停，不重跑上游 | recovery-05 因缺 auth / 丢失 DB env 均在有效产品评估前排除；recovery-06 outer `245.38s`，暴露 PyMySQL information_schema 列名为大写；recovery-07 outer `170.75s`，正式会话与 denied 不变成立，正向 Action 因缺 `expected_updated_at` 返回 400；recovery-08 加 current token 后正向审批、线索转换、客户创建均成功，但同一 canonical PyMySQL 连接仍读不到已提交客户。根因为默认 `autocommit=False` + MySQL repeatable-read 快照，已消费 cohort 归档，不复用 | **通用 canonical read 缺陷；Opt83 令 acceptance 只读连接每次看到其他 Runtime connection 的最新 commit** |
| `ce9342d1ec20d3a3540af3bbbbd72208e6a5a87f`（Opt83，父 `e4f44975741a5640806f866b77d435e9e662fac4`，远端 `skill_v2`） | canonical MySQL acceptance adapter 显式 `pymysql.connect(..., autocommit=True)`，让同一 harness connection 的相邻只读查询看到 Runtime 其他连接的最新 commit；无 transaction reset、fallback 或项目特例 | 两个真实 MySQL connection 的跨连接 commit 集成测试通过；focused harness `23` + real gate `1`，release/etc `43`，完整 `verify_builder_release` 全绿。Skill tree `5bb935ac…b163`、CLI `779e8c50…357d`、package `a66758da…357f`、core `79b83ea5…b897`；Plane `2.4.0-opt83.ce9342d1` PID 55162，8283 health 9/9 | **keep；fresh cohort 复测 canonical committed read** |
| 同一提交 `ce9342d1ec20d3a3540af3bbbbd72208e6a5a87f`（Opt83 M1 fresh Runtime + J07 recovery-09） | 新建 0-table MySQL `domainry_m1_opt83_canary_05`，compact Runtime start→status 后只跑一次 J07；canary 脚本相对 recovery-08 仅替换 session/evidence/core path | Runtime outer `174.74s`，resolver 1，start `3638.333ms`、status `325.136ms`，PID 56544、`127.0.0.1:19096`、health 200、cohort current。canary outer `527.73s`，真实 Gate `0.713s`、pure harness `0.641s`：前 6 个 checkpoint 通过，Opt83 已立即读到审批/转换/唯一客户；第 7 个 Inbox 立即查询失败，后两项阻塞。只读 MySQL 后验确认 event 与 Inbox 均正确，worker 在 commit 后约 `0.455s` 物化；失败是 harness 缺少 eventual-read polling，不是业务/Runtime/Opt83 DB 劣化 | **harness plumbing rework；Opt84 增加 core-owned bounded eventual-read，禁止项目脚本手写 sleep/retry** |

## 2026-09-09 全流程提速批次(Project Builder 前端优先链,基线 ~/pioneer-lab v1)

目标:压缩 domainry-project-builder / static-product-ui / domainry-builder-v1 端到端墙钟,不降验收强度。基线归因(两份专家子会话转录):后端 115 min(思考 88/执行 27)、前端 111 min(思考 93/执行 18,其中 ~18 min 为后台等待)。

| 批次 | commit | 假设 | 证据(基线转录时间戳) | verdict |
|---|---|---|---|---|
| speed-01 plane | plane@31f0285 | `project check` 一次列全 inventory 问题+packet 发布观测词汇表 → 6 连拒→1;`high_risk_assurance_required` 带消息;harness v2 通用 helper → 17 KB support_test.go 不再自写 | 14:55–15:00 六次单键拒收+二进制 grep;14:54 support_test.go 4.9 min+6 次修订 | 待 v3 复测 |
| speed-02 builder-v1 | plane@dffd7ef | v18 模型检查清单/级联删除契约/identity 交付默认值/evolution 一次性 recipe/`dev-runtime.sh`/`inventory-sync.py` → model plan 5 连拒、级联 purge 3 轮、identity 2 轮、Runtime 启动脚本自写 12 min 消失 | 14:08–14:10、15:02–15:31、14:59–15:12、7 次 evolution 门 | 待 v3 复测 |
| speed-03 PB+static-ui | plane@04bd3c5 | `scaffold-acceptance` 生成 config/fixture/CJS package.json/stubs;ui-check/backend-check 结构化失败摘要;nonce 作用域/页大小/CORS 代理/contract_version 文档;vite 模板代理 → 脚手架 14 min、CORS 11 min、翻日志 7 min、遗留数据 7 min 消失 | 16:06/16:10/16:35 生成、16:50 CJS、17:05–17:16 CORS、26 次日志检查 | 待 v3 复测 |

## 后端单独复测裁决(backend-bench-01,2026-09-09)

固定输入 = v4 的产品请求 + 冻结计划(16 需求 / 31 后端绑定)+ 已批准前端;后端 Skill 从零重建(删掉 backend、.domainry/builder 与上一轮 PRD),Plane v0.3.34-42-ge0aded6。参照组 = v4 后端段(同一 PRD、同一 skill 的上一版)。

| 里程碑(自后端开始) | v4 基线 | backend-bench-01 | 变化 |
|---|---|---|---|
| 到第一次接口验收 | 54.6 min | 55.5 min | 持平 |
| 接口验收循环 | 78.0 min | 16.3 min | **−79%** |
| finalize | 2.6 min | 2.9 min | 持平 |
| 最终 verify | ~10 min | 9.9 min | 持平 |
| **总计到 verified_and_stopped** | **149.4 min** | **84.6 min** | **−43%** |

质量门槛:`verified_and_stopped`,31/31 acceptance_required 接口在 initial 与 restart 两阶段全过(独立复跑 verify 二次确认)。断言未削弱;复测还额外抓出两个真实产品缺陷(staff_account 泄露 pin_hash/pin_salt;事务内 List 看不到刚建的 family_member)。

**speed-01..04 全部 keep**。归因:
- 收益全部落在接口验收段。harness v3 全键 `<object>.<verb>` 让 v4 那次"37 个接口一次全挂 auth.permission_denied"零复发;Runtime 行为速查(子对象读权限、`__in`、错误码优先级、logout 空体)使该段返工从 6 轮降到收敛。
- 前半程无净收益:需求+建模快约 6 min(v18 检查清单 + 保留字段键前置拦截,能力名重复零复发),但被 handler/接口测试编写吃回。
- `inventory-from-plan.py` 让 inventory 段 14.3 → 6.1 min,且 `project.interface_acceptance_invalid` 单键连拒(v4 六轮)零复发。
- PB 三道标识闸未被触发(本次后端严格实现冻结标识,无改名),属预防性。

本轮新暴露:①`inventory-from-plan.py` 读包路径优先级错误导致规则回退(已修 plane@33dbae5,无功能影响——回退表与包内规则逐字节一致);②冻结计划某条 oracle 与前端权限矩阵矛盾(FAPI-RESULT-DELIVER),属计划撰写期缺口,建议 freeze 增加 oracle 与前端契约的一致性提示。

## 同模型对照(backend-bench-02,Fable,2026-09-09)——拆开模型换代的混淆

bench-01 跑在 Opus 上而基线 v4 跑在 Fable 上,数字不可直接归因。bench-02 用与基线**同一模型(Fable)**、同一固定输入(v4 的请求+冻结计划+已批准前端)、优化后 Skill(含 fakes 生成器)重跑。

| 阶段 | v4 基线(Fable,旧) | bench-02(Fable,新) | bench-01(Opus,新) |
|---|---|---|---|
| 需求 | 8.7 | 9.8 | — |
| 模型到 model plan 通过 | 8.2 | **16.3** | 8.9 |
| apply | — | 1.1 | 0.4 |
| 单测替身 | ~9-11(并行手写)+4 轮返工 | **0.02(生成器)** | 手写 |
| handler | 24.2 | 29.4 | 26.1 |
| PRD + inventory | 14.3 | **0.9** | 6.1 |
| 接口验收循环 | 78.0 | **20.1** | 16.3 |
| finalize | 2.6 | 0.8 | 2.9 |
| 最终 verify | ~10 | 7.8 | 9.9 |
| **合计** | **149.4** | **104.5(−30%)** | **84.6(−43%)** |

**净归因**:同模型下 Skill 改动值 **−30%(45 分钟)**;Opus 相对 Fable 再快约 20 分钟。
收益来源:接口验收 78→20.1(−74%,与 bench-01 的 16.3 同量级,证明该收益属 Skill 非模型);inventory 14.3→0.9(`inventory-from-plan.py`);单测替身 ~10 min + 4 轮返工 → 0.02 min(`generate-capability-fakes.py`,8 个 fakes_test.go 100% 生成器产出)。
**反向**:model plan 段 8.2→16.3,新增的保留字段键/系统列前置校验与检查清单让建模阶段变重,吃掉约 8 分钟。这是下一轮的靶点。
质量:`verified_and_stopped`,**37/37 接口 initial+restart 双阶段全过**(独立复跑 verify 二次确认,148 条 check 全 passed)。断言未削弱;本轮又抓出一个真实审计缺陷(硬清除后患者编号被重发,`patient.enroll` 现按 deletion_record 取最大序号)。

本轮新暴露:①`apply compose` 的 `project.action_conditional_mutation_unguarded` 比 `project check --scope actions` 更严,同一份代码前者拒后者过(检查一致性缺陷);②`project.action_capability_unused` 语义未文档化;③`dev-runtime.sh check-env` 不接受 `--project/--address`;④对象级 Action 返回 `created_records[]` 而非 `record`,与前端契约文档矛盾,harness 缺对应 helper。

---

## 2026-09-09 晚 · bench-02 转录归因(speed-05):上一节的回归归因是错的

对 bench-02 后端转录(`agent-a1bb382955a7901fb.jsonl`,1298 行,16:52:00Z→18:38:03Z)做逐调用取证,只读 `tool_use`/`tool_result`/`text`,不读思考块。结论推翻了上一节"新增的保留字段键/系统列前置校验让建模变重,吃掉约 8 分钟":

- `metadata.field_key_reserved` **全程一次都没触发**,该字符串在转录中不存在。
- `model plan` 只跑了 2 次,诊断共 2 条(都是 `model.empty_value_forbidden`,空 `parameters`/空 `input`),修复用 2 行 `del`,**全部修复耗时 16 秒**。
- 新的建模检查清单只被读了一次,模型在一次生成里写完 10 个文件后直接 `model plan`,**没有发生任何预防性重构**。Object SQL 清单反而是净收益:两个 `.sql` 一次通过。

那 16.3 分钟的真实去向:

| 去向 | 分钟 |
|---|---|
| **上下文自动压缩(2 次)** | **5.6** |
| 一次无工具调用的静默推理(17:06:00→17:09:11) | 3.2 |
| 读 Skill 文档 | 3.2 |
| 写 `backend/model/*.json` + `reports/*.sql`(单次生成 110 秒) | 2.1 |
| 读产品输入 / Ledger 探索 | 2.0 |
| **`model plan` 与诊断修复** | **0.3** |

全程 8 次压缩合计 **18.4 分钟**,是本轮最大的可回收整块;第 3 次压缩还逼得 `backend-model.md` 又被重读 3 遍、前端契约重读第 3 遍。驱动因素是 `model capability` 强制的 **21 个文件 / 218KB** 阅读清单(代理严格照读,未多读一个文件),叠加手写的 100KB PRD、28KB 冻结计划、27KB 契约与 90KB Ledger dump。

### 本轮五项修复(均已推 domainry-plane main)

| # | 提交 | 内容 | 依据(实测) |
|---|---|---|---|
| 1 | `ed464c3` | object 型 Action 返回**没有** `record`/`record_id`,只有 `created_records[]`;harness v4 加 `actionRecord`/`actionRecordRef`/`actionRecordRefs`,`verification.md` 补事实 | 该契约全 Skill 缺失,IA 第一轮 37 个测试经同一个 fixture 全挂,18:08:00→18:14:30 = **6.5 min** |
| 2 | `ed464c3` | 业务序列号必须扛硬清除:改为 `max(活,已清除)+1` 并在 handler.access 声明 `deletion_record:["list"]`,规则进建模检查清单 | 重启阶段 `TestFAPIDeletionRecordList` 失败 18:17:25 → 重新 apply → 转绿 18:28:04 = **10.6 min** |
| 3 | `ed464c3` | `dev-runtime.sh` 参数对称化 | 两次参数报错 18:11:29 / 18:11:34 |
| 4 | `00c3864` | **阅读清单分阶段**(model/implement/verify),read_order 按阶段分组 | 建模窗口 218,216 → 149,630 字节(**−31%**) |
| 5 | `2f78755` | `inventory-from-plan.py` 解除"先有鸡后有蛋":它本就能打印 PRD §3/§12 表,却因缺 PRD 直接退出 | `missing PRD` 16:53:47 → 手写 100KB PRD 16:57:06→17:01:53 = **4.8 min** |
| 6 | `6aad51f` | 新增 `generate-acceptance-skeletons.py`,按 inventory 每行生成可编译 IA 测试骨架,业务内容留 `TODO(business)`;`--check` 守住"测试集 == inventory 分母" | IA 撰写 17:49:35→18:08:00 = 18.4 min,其中 38 个证据块 / 37 组观测与行 1:1 对应 |

**修正一条旧指引**:`verification.md` 原文教测试作者"purge 用例不要断言序号有跳号",即容忍编号重发。bench-02 证明重发是真实审计缺陷(同一个 `PMP20260909024` 对应 3 条删除记录),该指引方向错误,已改为定性为产品缺陷并给出模型层修法。

**关于第 4 项的安全性**:延后读 `verification.md` 之所以安全,是因为第 1、2 项已先把"模型必须知道"的两条事实搬进 `backend-model.md` 检查清单。守护测试 `TestEveryReadingProfileFrontLoadsInterfaceAcceptanceEvidenceBeforeFinalize` 原本只检查成员资格,名不副实;已改写为如实断言 evidence 文档 staged 为 `verify`,并新增一条测试要求每个条目都带已知 stage 且顺序已分组。

**验证状态**:五项均通过 plane 全量单测与 PB/兼容 selftest;生成器另用 bench-02 真实 37 行清单验证(gofmt/vet 干净、仅靠 v4 harness 即可编译、输出字节确定、改名能被 `--check` 抓出两侧)。**上表的分钟数是归因出的"该环节曾经耗时",不是已兑现的节省**;是否兑现要等下一轮同夹具复跑(bench-03,Fable,对照 bench-02 的 104.5 min)。

### 更正:"apply compose 比 project check 更严"未能复现,真实原因是静态检查看不穿辅助函数

上一节(`483f5d8`)把 `project.action_conditional_mutation_unguarded` 记为"同一份代码 `apply compose` 拒、`project check --scope actions` 过"的检查一致性缺陷。追代码后**这个差异复现不出来**:两条命令汇聚到同一份实现(`ValidateUserSourceAt` → `buildComposition` → `validateBusinessSources`),该函数全仓只有一处定义、三处调用,不存在第二条策略路径。更可能的解释是两次调用之间工作树变了。**不再把它当平台缺陷登记。**

真实原因是另一回事,而且更值得写进 Skill——我直接探测了分析器,没有靠推断:

- `project.action_capability_unused` 只认**导出 Handler 函数体内**的直接 `caps.<Object>.<Method>(` 调用。把调用交给辅助函数就不算数,**放在同目录、同 package 也不算数**。
- `project.action_conditional_mutation_unguarded` 同理:守卫必须出现在 `ConditionalUpdate` 的参数链或其声明语句里,helper 组装出来的 mutation 即使守卫了也报未守卫。

两者都是文件局部静态分析的能力上限,不是被拒代码真有缺陷,但闸门就是闸门。这条限制此前在 Skill 里**一个字都没有**,bench-02 为它耗掉若干轮返工。

一个过程性教训:我起初写的文档说"放在同目录的兄弟文件里也可以",探测直接证伪了它,**在发布前改掉**。涉及闸门行为的断言必须实测,不能读代码推断。

已提交 `7b7f8e7`:`references/project-mutation.md` 补规则,并加回归测试 `handler_capability_locality_test.go` 钉住四种情形(同目录 helper / 另一 actions 目录 / domain owner 下 / Handler 体内直调),让文档与代码不能再悄悄漂移。**该提交尚未部署**:bench-03 正在用 v0.3.36-7 复跑,中途替换已安装 Skill 会毁掉对照。

### bench-03 复跑:Fable 轮被路由容量打断,改 Opus 干净重跑

**Fable 不可用**:两次恢复 + 一个零工具探针全部 429(`Fable is momentarily at capacity on this router`,非用量上限)。放弃同模型续跑。

**不做 Fable/Opus 混合跑**——那样总耗时既不能比 bench-02(Fable,104.5 min)也不能比 bench-01(Opus,84.6 min),只剩质量结论。改为 Opus 干净重跑,对照 bench-01。**这个对照比原计划弱一层**:bench-01 既无 fakes 生成器也无 speed-05,差值是两者之和;fakes 的贡献虽在 bench-02 单独测过(~10 min + 4 轮返工 → 0.02 min),但那是跨模型测量,只能作量级参考,不是精确扣除。**真正干净的同模型计时仍欠一轮**,等 Fable 有容量再跑。

**Fable 半程存档** `~/backend-bench-03-fable-partial`(22:34:44→23:24:58,断在 Handler 测试阶段;`outages.csv` 记录 6.0 min 窗口)。中断发生在后半程,**前半程无缺口、同模型、同夹具**,可直接比 bench-02:

| 阶段 | bench-02 | Fable 半程 | 差 |
|---|---|---|---|
| requirements → model-start | 9.8 | 8.4 | −1.4 |
| model-start → model-plan-valid | 16.2 | **12.2** | **−4.1** |
| model-plan-valid → apply-ok | 1.1 | 0.5 | −0.6 |
| 前半程合计 | 27.2 | 25.8 | −1.4 |

建模段 −4.1 min,方向与分阶段阅读清单(建模窗口 −31% 字节)一致。**但这是 n=1 半程数据,只算初步信号,不是结论。**

**主动记录一处对照瑕疵**:重建 bench-03 夹具时删掉了 v4 遗留的 `.domainry/development/<session>.md` TODO(它会让代理"恢复"一个过期阶段),而 bench-02 开跑时该文件在。上表因此有轻微不一致。

**部署**:Opus 轮前把 `7b7f8e7`/`9152bf5` 一并装上,基准测当前 HEAD `v0.3.36-9-g9152bf5`,非过期构建。对照工具 `~/.claude/handoffs/tools/bench_phase_table.py`(缺失事件留空不插值,中断时长单列、不自动扣进任何阶段)。

### bench-03 裁决(Opus,85.5 min):质量通过,计时持平;暴露六项摩擦并已修复

**质量:通过,且经我独立复核。** 我自己跑了一次 `verify --json --project ~/backend-bench-03 --address 127.0.0.1:18097`(注意 `verify` **不接受** `--environment`,我第一次传错参数导致命令立刻失败,而我误以为它在运行——已更正):

```
state = verified_and_stopped
initial  接口 37/37  检查 37  未通过 0  缺失=无
restart  接口 37/37  检查 37  未通过 0  缺失=无
```

逐个 FAPI ID 与 inventory 分母对齐,无缺失。代理自己也跑了两次 `verified_and_stopped`。

**计时:85.5 min vs bench-01(Opus)84.6 min,持平。**

| 阶段 | bench-02(Fable) | bench-03(Opus) |
|---|---|---|
| 需求 | 9.8 | 3.7 |
| 建模到 model-plan-valid | 16.2 | 7.1 |
| apply + fakes | 1.1 | 0.7 |
| Handler | 29.4 | 17.3 |
| inventory | 0.9 | 0.6 |
| **IA 用例撰写** | **18.4** | **28.0** |
| IA 验收循环 | 20.1 | 18.3 |
| finalize | 0.8 | 3.0 |
| 最终 verify | 7.8 | 6.8 |
| **合计** | **104.5** | **85.5** |

**但这个"持平"含 ~43 min 偶发事故**:货币/float 返工 ~25 min、级联删除排查 ~18 min。两者现均已修复,所以单次运行的噪声远大于我原先假定 —— 85.5 与 84.6 之间**分不出胜负**。

**一处我自己的测量错误,已收回**:我曾称"生成器证据块被 37/37 采用",依据是 `passedCheck("target", ...)`。该写法在 bench-02 手写代码中同样存在,**不是生成器特有标记**,结论不成立。代理明确说骨架被它删除重写,理由是"编辑 37 个 `TODO(business)` 块比手写更慢"。

**六项摩擦修复(`65d0a10`,已推)**

| # | 问题 | 实测代价 | 修法 |
|---|---|---|---|
| 1 | `project check` 因清单不完整而短路,源码闸门(含 float 禁令)根本不跑,直到 `apply compose` 才 16 条齐爆 | **~25 min** | 清单诊断改为非终止,继续跑完源码/通知/编译闸门;后置闸门硬错误时回落报清单结论。**新测试在旧代码上失败,症状与报告一致** |
| 2 | 级联删除无法经 Role 授权(`action_only` 子对象无 CRUD 权限键),`403` 不指明任何对象/权限/字段 | **~18 min** | `backend-model.md` 写明症状(有子记录 403 / 无子记录 200)与 `handler.access` 闭包,并补姊妹坑:自删子记录会让级联重复规划,提交撞 `409 version_conflict` |
| 3 | harness `idempotencyKey` 不含 run nonce,而 `nonceValue` 含 → 同阶段第二轮同键异载荷,撞 `409 key_reused` | 一次循环 | harness **v5** 纳入 `harnessRunNonce`;进程内不变,同轮重放断言不受影响 |
| 4 | `dev-runtime.sh ia` 拒绝 `backend-runtime.md` 明文宣传的 `-run TestX` | 一个完整失败周期 | 接受透传参数;`start` 补 `--phase`;其余子命令仍拒绝未知参数 |
| 5 | `action_query_unbounded` 要求"1–200 的字面量"却指着值为 200 的具名常量,读作误报 | — | 改为明说必须内联写数字、具名常量不被读取 |
| 6 | `apply-model.sh` 必需的 `--go-module-path` 未出现在 apply 阶段该读的 `project-mutation.md` | 一轮 | 补入该文档 |

**骨架生成器按证据降级**:`--check` 保持无条件使用(代理评价"最廉价的分母守卫",用了两次),骨架改为可选,文档如实写明实测结论。另给 `--check` 加"行与固定 Runtime 契约矛盾"检查——即那条被误标为 `authenticated` 的 `auth.logout` 行,它曾被忠实放大成无法满足的必需观测项;已用变异数据验证该检查会指名报出。

**下一轮 bench-04** 起于 2026-09-10T02:18:33Z:同 Opus、同夹具、同起点,对照 85.5 min。任务书同时修正了我上一轮自己的两处错误(顺序不可能成立的 `skeletons-generated` 事件;未提醒 `verify` 不接受 `--environment`)。

#### 更正:bench-03 的总数是 92.2 min,不是 85.5

上一节写"bench-03 = 85.5 min,与 bench-01 的 84.6 持平"。**这个数字不完整。**

bench-03 的时间线里有**两条 `verify-ok`**:代理发现自己写错了 PRD §12(37 行"唯一 Go 测试路径"全部指向不存在的文件名),修正后重跑了一次 verify。

- 到第一次通过 verify:**85.5 min**
- 到运行真正结束:**92.2 min**

我当时只读了第一条。而对比工具 `bench_phase_table.py` 用字典存事件,后一条**静默覆盖**前一条 —— 两种读法都错:一个漏掉真实耗时,一个虚增总数(若只取最后一条,阶段行 `finalize-ok -> verify-ok` 会显示 13.5 而非 6.8)。

**修正后的裁决**:bench-03 实际 **92.2 min**,比 bench-01(Opus,84.6)**慢 7.6 min**,而非持平。结合该轮 ~43 min 的偶发事故(货币/float 返工 ~25、级联删除排查 ~18)与 PRD §12 返工 ~6.7 min,这轮的额外耗时基本都能落到具体事件上。

工具已改:保留每个事件的**第一次**时间戳,并在表尾显式打印重复事件与其延迟,不再静默覆盖。

### bench-04(Opus,73.3 min):计时结论作废 —— 覆盖缺失 6 个真实接口

**质量(在其自称范围内):通过。** 我独立复跑 verify:`verified_and_stopped`,初始 31/31、重启 31/31,零未通过。

**但计时不可比,结论作废。** bench-04 的 inventory 只有 **31 行**,bench-03 是 **37 行**。缺的 6 个是:

`auth.logout`、`expense.list`、`patient_visit.list`、`result_template.list`、`supplier_payment.list`、`test_result.get`

它们**不是**被标为 `frontend_only`,而是**根本不在清单里**——从未进入分母,自然也不会失败。73.3 min 里有一部分是少做了事换来的。

#### 一次我先说反了的判断,记录在案

我最初断言这 6 行是 `inventory-from-plan.py` 宽松匹配的**假阳性**,理由是"全前端只有一处 `queryRecords('lab_test')`",并据此推论 **bench-03 多验了 5 个不存在的接口**。

**这个结论是错的。** 我的 grep 写成 `queryRecords(\s*'[a-z_]*'`,而前端实际写法是 `recordClient.queryRecords<ExpenseData>('expense', ...)` —— 方法名与括号之间夹着泛型参数,整类调用被我的模式漏掉。改用脚本自己的正则重跑源码后结果相反:**6 个全部真实**,bench-03 的 37 是对的,bench-04 **漏验**。

教训与之前"同目录 helper"那次相同:**涉及匹配行为的断言必须用真实模式跑真实源码,不能用手写 grep 近似**。这次的修复(下述扫描器)因此直接复用脚本自己的调用模式,而不是另写一套 grep。

#### 根因是结构性的,不是代理疏忽

`inventory-from-plan.py` 只能从 `acceptance.backend` 绑定派生,而计划只绑定 31 个。前端调用但计划未绑定的接口对它**完全不可见**,它只在 docstring 里写了一句"需手工添加"。bench-03 的代理补了(记为 D-16),bench-04 的没补,**两种情况都不报错**。

#### 修复(`6edc185`,已推)

脚本本就规定"有行无调用点 = 硬错误";现在补上对称的另一半:扫描前端实际调用的操作(对象/记录 Action、含泛型形式的 `queryRecords`/`listRecords`/`getRecord`、报表 `query`、登录、登出),**只要有调用没有对应行就拒绝 `--write`/`--print-json`**,逐个列出调用点,并说明计划无法派生它们、该补成 `acceptance_required` 还是 `frontend_only`。

双向验证:bench-04 的清单恰好报出那 6 个并退出 1;bench-03 完整的 37 行零报错。中途一次假阳性(report 模式的 `\bquery\w*` 把 `queryRecords` 也算作报表查询)已收紧为精确 `\bquery`。

#### bench-05 起于 2026-09-10T03:51:32Z

同 Opus、同夹具、**强制同覆盖**,对照 bench-03 的 92.2 min。任务书新增三条:覆盖强制(且不许删行让脚本通过)、时间线只追加不改写(bench-03 两条 `verify-ok` 曾差点漏算 6.7 min)、CLI 参数例外(`model capability` 拒绝 `--environment`,`verify` 只收 `--project`/`--address` —— 上一轮我在任务书里笼统要求"所有 Plane 调用加 `--environment`",代理照做后撞错)。

**已知混淆项**:应用户要求同步了 domainry-runtime `cdba4e8` → `288b630`(含 Identity/Notification 升级),而本基准大量使用 Identity。因此 bench-05 相对 bench-03 有两个变量,计时归因据此打折。

## bench-05～bench-12 汇总(Opus,同夹具 pioneer-lab-v4 前端,2026-09-10～11)

前面各轮裁决当时只写在会话里,这里统一补记。所有轮次质量均为 `verified_and_stopped`、37/37 initial+restart 双阶段,且由 evaluator 在另一端口独立复跑 `verify` 确认。

| 轮次 | 墙钟 (min) | 变量 / 备注 |
|---|---|---|
| bench-05 | 82.1 | 强制同覆盖 37 行;同步 runtime 288b630(混淆项) |
| bench-06 | 83.3 | 修复循环 22.6→11.4 min,总时长持平(噪声内) |
| bench-07 | 80.6 | |
| bench-08 | 92.9 | 最贵一条摩擦 ~35 min |
| bench-09 | 94.1 | 单行聚合 Report `ORDER BY` 假豁免首报 |
| bench-10 | **70.1** | 最佳;骨架生成器之前的包 |
| bench-11 | 79.2 | v0.3.47 + 骨架生成器首轮;收割拒绝码含平台前置校验遮蔽的码,丢一个 IA 周期(已修 ffc8ce5) |
| bench-12 | 83.8 | aca9df4 八条摩擦修复前的包;代理把生成的 88KB 骨架整个删了,只留拒绝码清单/路由选择/evidence 块 |

**结论**:bench-09→10 无 skill 大改仍摆 24 min,总墙钟噪声≈信号,单看总时长不能归因。bench-12 transcript 剖析:84 min 里模型思考 68(81%)、工具执行 16;CLI 全程只 19 次(修复循环这条线已解决)。两轮对骨架生成器的直接证据一致:留下的永远是拒绝码清单、路由/helper 选择、evidence 块,扔掉的永远是 payload 渲染 → 生成器方向错了,改做减法(`8213f5b`)。

## bench-13(Opus,skill 0.3.49,2026-09-11)——减法版骨架生成器:总时长持平,思考量降 8 分钟

**改动**:`8213f5b` 骨架生成器不再渲染 payload 占位值、`requireField` 块和 `acceptance_actors_test.go`,各换成一行契约注释(输入键+线型 / 输出保证字段 / 拒绝码分流)。在途版本曾删掉 `PLATFORM_REQUIRED_CODE` 而自检仍过,跑真实项目 NameError——自检现在完整渲染一个 case。夹具、brief、模型、端口规则与 bench-12 相同(仅补一句 `project check` 不接受 `--environment`)。

**墙钟**:04:25:51Z → 05:50:31Z = **84.7 min**,对 bench-12 83.8 **持平**。

**分阶段剖析**(`~/.claude/handoffs/tools/bench_phase_profile.py`,按每次工具调用触碰的路径归阶段;think = 调用前的思考间隔,exec = 工具执行;单位 min):

| 阶段 | bench-11 think | bench-12 think | bench-13 think | 13 exec |
|---|---|---|---|---|
| model | 3.7 | 11.3 | 5.5 | 0.4 |
| handlers | 13.1 | 15.7 | 14.7 | 0.2 |
| inventory | 1.1 | 5.7 | 0.9 | 0.0 |
| acceptance | 20.8 | 18.6 | 15.6 | 12.4 |
| check_verify | 0.5 | 0.5 | 0.6 | 9.2 |
| skill_docs | 1.3 | 0.8 | 3.1 | 0.0 |
| other | 22.3 | 11.7 | 9.0 | 0.2 |
| **思考合计** | 74.2 | 68.2 | **59.9** | |
| **工具等待合计** | 5.2 | 15.6 | **22.6** | |

思考总量 68.2 → 59.9(−8.3 min),其中 model −5.8、inventory −4.8、acceptance −3.0;但工具等待 +7 min(IA 与 verify 跑了更多轮),两者抵消,总墙钟不动。注意 skill_docs 一项三轮都在 1～3 min:上一节"读文档占 9.2 min"用的是另一套归类,按本脚本复现不出来,以后只用本脚本比。

**骨架生成器判据(直接证据)**:生成文件被删,但契约注释行保留进 9/10 个手写文件(25 处),路由调用形式和 evidence 块沿用;拒绝码菜单 0 处保留。代理原话:留下的是"声明输入契约的那行注释、Output contract guarantees 行、路由形式、evidence 块、只读 Action 不能 actionRecord 的提示";扔掉的是全部 TODO 体和单文件布局。三轮一致 → 生成器现在的形状就是它的终态,不再加东西。

**代理自报最贵摩擦**(自报分钟,已知会超发,只看排序):FAPI-AUTH-LOGOUT ~40(bearer 不吊销,而 inventory 规则强制 logout 行带 `durable_result_read_back`/`idempotency_required`/`transaction_required`,代理只能用"下次登录 session_id 变了"当读回);BusinessError.Message 被 code 覆盖、事实只能走 `params` ~20;`initial_credential` 是对象不是字符串 ~15;受管 Runtime 每 Object 一条 baseline 种子行落进 Object SQL Report 窗口、`LIMIT 2` 险些截断 ~15;packet 命令顺序 `full_tree` 排在 `apply compose` 前 ~5;`generate-acceptance-skeletons.py` 不认 `--write` ~1。前四条都是文档/规则缺口,下一轮靶点。

**独立复核**:evaluator 另起端口 `verify --json --project ~/backend-bench-13 --address 127.0.0.1:18210` → `verified_and_stopped`,initial 37/37、restart 37/37,零 failed,与代理自报一致。质量通过,计时持平。

## bench-14(Opus,skill 0.3.50,2026-09-11)——四条摩擦修在"交付会读的地方":70.7 min,追平最佳

**改动**(plane `e24c48f`):① `/auth/` 会话路由免 `durable_result_read_back`(project check、packet 规则文案、inventory-from-plan 及未绑定桩同步);② 骨架注释行加四条事实(message=code、事实走 params;initial_credential 是对象;baseline 种子行进 Report 窗口、LIMIT 留余量;logout 204 且 bearer 仍可读);③ 拒绝码收割支持 `reject("x.y.z", …)` 助手形式(bench-13 全用此形式,76 个码一个没收到);④ 修复循环改为"全量 initial 一次 → 修 → 只重跑修过的 → 直接 verify",dev 上不再跑第二遍全量与 restart。这四条按 bench-13 transcript 逐调用归因合计 ≤11 min(自报 90 min)。

**结果**:07:30:15Z → 08:41:17Z = **70.7 min**(bench-13 84.7,bench-12 83.8;历史最佳 bench-10 70.1)。质量 `verified_and_stopped` 37/37 双阶段,evaluator 另起端口 :18220 独立 verify 复核零 failed。首轮 IA 33/37,四个失败一起修。

| 阶段(think min) | bench-12 | bench-13 | bench-14 |
|---|---|---|---|
| model | 11.3 | 5.5 | 2.5 |
| handlers | 15.7 | 14.7 | 12.2 |
| acceptance | 18.6 | 15.6 | **12.0** |
| other | 11.7 | 9.0 | 24.4(含 verify 后台轮询) |
| 思考合计 | 68.2 | 59.9 | 61.6 |
| **工具等待合计** | 15.6 | 22.6 | **7.9** |
| 修复窗口(首轮 IA 失败→全绿) | — | 11.0 | **5.8** |

**四条修复的直接证据**:dev 上 restart 阶段未跑(IA 只两轮 initial,各 2 min);login/logout 行只有三项观测,报告零提及 logout;拒绝码菜单这次收到并被转成 31 条 live `mustReject`(bench-13 手写 29、bench-12 手写 27),代理称骨架"省了一个多小时"、shadowed 分流直接用上;message/params 事实读到了,但仍花 ~10 min 确认非自身 bug(前端契约与 Skill 说法相反,根治要 runtime 发布 Message)。骨架文件本身仍被删、拆成 10 个文件,契约注释行未保留(bench-13 保留 25 处)——留下的是断言不是注释。未完全照做"只重跑修过的用例",修完仍跑了一次全量 initial(2 min)。

**代理自报新靶点**(自报分钟,已知超发,只看排序):Object SQL v1 无字符串字面量/UNION/子查询,两个 Report 改为 append-only 账本 Object 双写 month/year 行 ~35;生成类型四个坑(relation 输入是裸 `schema.XID`、select 输入是值类型、可选 relation 需 `NewXIDReference`、mutation 内部不导出只能 `ValidateConditionalMutation`)~45;Object 字段默认全 Role 可读致 `pin_fingerprint` 泄漏,一行 `field_permissions` 因 evolution 门 + packet 被 compose 删掉花 ~12;`apply model` 返回 evolution_review_required 仍 exit 0;`inventory-sync.py` 无 `--write`;`dev-runtime.sh ia` 不复用 start 记录的地址。

**结论**:bench-13→14 −14 min,其中工具等待 −14.7 直接对应"去重复 IA";思考量持平。噪声带 ±10 仍在,但方向与分阶段信号一致。下一轮靶点按剖析定,不按自报。

## bench-15(Opus,skill 0.3.53 + Runtime v0.1.27,2026-09-11)——三项修复零摩擦,总时长回到 83.6

**改动**(plane `a385e13`/`e10650b`/`8a1f37e`,runtime `80439cc`=v0.1.27):① `apply model` 审核停止 exit 3、implementation packet 随当前回执保留(compose 不再删);② 字段 DSL `;sensitive` + 编译器按 Role 补关闭项 + `model plan` 诊断 `model.field_sensitive_default_open`;③ Runtime 字段级关闭(无精确命名该字段的 policy 一律拒)。用户原定这条夹具不再跑,后指示"修完继续评估",故仍用同夹具、同 brief。

**结果**:10:57:12Z → 12:20:45Z = **83.6 min**(bench-14 70.7,bench-13 84.7,bench-12 83.8)。质量 `verified_and_stopped` 37/37 双阶段;evaluator 另起端口 :18240 独立 verify 复核 initial/restart 均 `passed`。

| 阶段(think min / exec min) | bench-14 | bench-15 |
|---|---|---|
| model | 2.5 / 1.3 | 4.9 / 0.9 |
| handlers | 12.2 / 0.3 | 16.1 / 0.3 |
| acceptance | 12.0 / 4.8 | 14.4 / 11.0 |
| check_verify | 2.9 / 0.8 | 0.5 / 8.6(verify 前台) |
| other | 24.4(含 verify 后台轮询) | 13.7 |
| 思考合计 / 工具等待合计 | 61.6 / 7.9 | 59.8 / 21.2 |
| 修复窗口(首轮 IA 失败→全绿) | 5.8 | 9.2 |

里程碑(自首次工具调用起,min):首次 apply 13.9→11.2;首次 Handler 测试 29.5→25.8;首次起 dev Runtime 52.0→**59.3**;全绿 60.5→68.8;verify 起 61.4→72.3;结束 69.5→81.0。两轮各发生 2 次上下文压缩,条件对等。

**三项修复的信号(全部出现)**:`pin_fingerprint` 建模时直接写成 `"text;sensitive"`,没有逐 Role 条目、没触发诊断、没为它跑 evolution 轮(bench-14 为此花 3 min + 一整轮 plan/apply);建模段唯一一次再 plan 是代理自己后补 `visit_payment.patient_id` 撞上 `model.required_field_upgrade_rule_required`,`legacy=exempt` 后经 `apply-model.sh` 一次到 `implementation_ready`,packet 未丢,合计约 1 min(bench-14 的 evolution+packet 窗口 2.6 min);exit 3 由脚本消费,代理没有感知。

**+13 min 的落点**(transcript 归因,非自报):① 验收用例写作段 11:29→11:54 = **25 min**(10 个文件 37 例;bench-14 同段约 14 min)——每例更多 live `mustReject` 与最小权限 Role 矩阵(allowed/denied 都按 §2 矩阵取最小权限 Role 跑),属质量投入,非摩擦;② 全绿后代理又在 dev 上跑了整套 initial(168 s)+ restart(161 s)再 verify,**bench-14 去掉的重复这轮回来了**,≈5.5 min——SKILL 规则"只重跑修过的用例→直接 verify"没被遵守,是代理行为方差,不是缺陷;③ Handler 段 +4 min(自报 D5"40 min"的实测上限)。模型/PRD 段反而 −2。噪声带 ±10 仍在。

**修复窗口 9.2 min 的构成**(四个新缺陷,实测):D1 `identity.handler_delivery_initial_credential_output_occupied`(HTTP 500,`RegisterInitialCredential` 文档注释诱导返回空结构体而非 nil)0.8 min;D4/D10 `verify_pin` 在受管 Runtime 里种子 profile 绑定 bootstrap 管理员、`staff_account.read` admin-only 1 min;D3 `backend.report.page_size_invalid`(无 message、无上限说明,骨架注释又引导对齐 SQL LIMIT 500)+ D2 refusal `message` 被 code 覆盖 3 min;其余为两次全量 IA 执行等待。

**代理自报新靶点**(自报分钟已知超发,只看排序与可修性):D1 一句文档即可根治;D3 文档写明 page_size 上限并让骨架发合法值;D2 已知事实(bench-13 起),但前端契约要求"message 含 balance 与金额"与平台行为冲突,需在 Handler 参考里写"事实进 Parameters,Message 只进日志";D11 `inventory-from-plan.py` §12 三列占位符(自报 25,剖析 inventory 段 think 2.5);D6 `project check --json` 是 NDJSON 带尾行;D7 升级规则诊断不指明该用哪个修饰符;D8 裸 `go test ./...` 失败像坏交付;D9 gofmt 门在最后且不修;D5 `UpdateMutation` 无访问器。骨架约 60% 存活(输入/输出契约行、收割拒绝码、shadowed 列表、evidence 块),"denied Role 是产品决定"37 次被点名为最机械的残留——Role 授权矩阵已能确定。

**结论**:三项修复各自的窗口消失,方向成立;但被验收写作段变长(质量投入)与 dev 重复全量(行为方差)吞掉,总时长回到 83～85 带。下一轮若继续,先修 D1/D3/D2 文档三条(合计 ≤5 min 但都是首轮 IA 必撞),并把"修复后只重跑修过的用例"从文档规则提升为 `dev-runtime.sh ia` 的默认行为(例如 `ia --repaired` 读上次失败清单)。

## bench-16(Opus,skill 0.3.54,2026-09-11)——三条"首轮必撞"文档修复:修复窗口 9.2→5.2,总时长 75.4

**改动**(plane `349b707`):① 生成的 `<Action>InitialCredential` 注释改为"Handler 返回时该字段留 nil,非 nil 即 `identity.handler_delivery_initial_credential_output_occupied`(500)",identity-handler-delivery.md 正文与默认值清单各一条;② report 查询 `page_size` 1..200 默认 100、超出 400 `backend.report.page_size_invalid`(与记录列表钳制不同,与 SQL LIMIT 无关),写进 reports.md / verification.md / 骨架注释,packet 的 `module.report.queryReportObjectSQL` 分片加 Pagination 规则;③ refusal 事实进 `Parameters`、`Message` 不到客户端,写进 packet `summary.shared_constraints` 与 backend-runtime.md 习语段。

**结果**:12:49:19Z → 14:04:44Z = **75.4 min**(bench-15 83.6,bench-14 70.7)。质量 `verified_and_stopped` 37/37 双阶段;evaluator 另起端口 :18260 独立 verify 复核 initial/restart 均 passed。

| 阶段(think / exec min) | bench-14 | bench-15 | bench-16 |
|---|---|---|---|
| model | 2.5 / 1.3 | 4.9 / 0.9 | 4.2 / 0.6 |
| handlers | 12.2 / 0.3 | 16.1 / 0.3 | 15.9 / 0.3 |
| inventory | 1.3 / 0.2 | 2.5 / 0.0 | 5.7 / 0.5 |
| acceptance | 12.0 / 4.8 | 14.4 / 11.0 | 13.4 / 8.1 |
| check_verify | 2.9 / 0.8 | 0.5 / 8.6 | 0.3 / 7.3 |
| 思考合计 / 工具等待合计 | 61.6 / 7.9 | 59.8 / 21.2 | 57.2 / 17.1 |
| 首次起 dev Runtime(min) | 52.0 | 59.3 | 54.4 |
| 首轮 IA 通过数 | 33/37 | 0/3(引导即挂) | 30/37 |
| 修复窗口(首轮 IA→全绿) | 5.8 | 9.2 | **5.2** |

**三条修复的信号**:D1 消失——actor 引导一次通过,注册/登录/verify_pin 首轮全过(bench-15 首轮 0/3 全挂在 500 上);D3 消失——两个报表用例首轮通过,代理报告称骨架里的 page_size 说明"直接用上";D2 一半——Handler 侧按 shared_constraints 把余额/币种/单号放进了 `Parameters`,PRD §9 记了偏差,但验收断言先读了 `body["parameters"]`(线上键是 `params`),6 min。`;sensitive` 继续零成本采用。

**首轮 7 个失败全是新面孔**(实测 5.2 min 修完):4 个 `auth.permission_denied`——骨架建议用 `listFiltered` 回读 visit_item / visit_payment / family_member,而这些子对象前端从不单独列出、没有 Role 持有 `*.read`,改读父对象投影;2 个断言了被平台预占的 `arabic_name_required`(Runtime 先 trim 必填文本,`"   "` 直接是 `backend.validation.required`,骨架的 shadowed 列表只覆盖"缺字段",不覆盖"空白字符串");1 个即 D2 的键名。**dev 上全绿后再跑整套 initial+restart 再 verify(≈5 min)第三轮出现**,规则在文档里但三轮没有一轮遵守。

**代理自报新靶点**(排序看可修性):骨架按 Role 授权矩阵决定回读方式(无 Role 持 read 的子对象改读父投影);"Runtime 在 Handler 之前校验什么"一页(required/trim、coercion、select 域,含 `field_path`/`params.field`);记录级 Handler 的路由 id 在 `caps.Execution.TargetID()` 而非输入结构体;`result_schema` 拒绝文档承诺的 `decimal`(且未说明它嵌在 `object_sql_v1` 内);`dev-runtime.sh ia -run` 时 evidence 检查 36 条噪音;harness 缺 `refusalParameters` 助手;`inventory-from-plan.py` 无 `--project` 时静默写空清单退出 0;SKILL.md 30.8 KB 长行导致工具输出截断。

**结论**:三条文档修复直接命中首轮 IA,修复窗口 −4 min、总时长 −8 min,方向与分阶段信号一致;首轮失败换成了新一批"读回路径/平台预校验"问题。下一轮最值得做的两条:① `dev-runtime.sh ia` 默认只重跑上次失败用例(把三轮都没遵守的规则变成行为);② 骨架按授权矩阵生成回读与 denied Role 断言(bench-15/16 两轮都点名)。


## bench-17 — 2026-09-11,skill 0.3.55(`ia` 默认只重跑失败用例)

- 夹具:bench-11 复制(9592 文件,仅前端 + 冻结计划 + 前端接口契约);Opus;端口 18280;brief `/tmp/bench17-brief.txt`。参考目录全部 chmod 000。
- **墙钟 62.9 min**(子代理转录首末时间戳 15:03:45Z → 16:06:37Z;剖析脚本口径 61.4)。对照 bench-14 70.7 / bench-15 83.6 / bench-16 75.4。
- 自报:verify `verified_and_stopped`,分母 37(31 计划绑定 + 6 条计划未绑定但前端调用的操作,由 `inventory-from-plan.py` 报出),initial 37/37、restart 37/37。独立 verify(:18290):`verified_and_stopped`,initial 37/37、restart 37/37。
- 剖析(分钟,think/exec):skill_docs 0.1/0(bench-16 2.3);prd_docs 6.6/0(4.0);model 6.6/0.4(4.2/0.6);handlers 14.3/0.2(15.9/0.3);inventory 0.9/0.4(5.7/0.5);acceptance 8.7/3.0(13.4/8.1);check_verify 0.2/8.1(0.3/7.3);total think 49.0 / exec 12.4(57.2 / 17.1)。
- **本轮改动的信号**:`ia` 只跑了一次(`--all`,164 s),修完直接 `verify`,dev 上没有再跑整套 initial+restart —— acceptance exec 从 8.1 降到 3.0,inventory think 从 5.7 降到 0.9(inventory-from-plan 直接采用)。
- PRD 仍是手写:77.7 KB,prd_docs think 6.6 min —— 这是 0.3.56 `prd-from-plan.py` 的目标(本轮未部署)。
- 代理报告的缺陷(按其耗时):Object SQL v1 无法表达跨表汇总,靠写 Handler 追加预汇总 ledger 行绕过(≈45 min,已知);`project.action_conditional_mutation_unguarded` 只认字面写法(≈15 min);`BusinessError.Message` 上线即被 code 替换,事实只能放 params(≈10 min,文档已改);Action 动词以 `_test` 结尾 → Handler 文件名成了 Go 测试文件,静默不编译(≈10 min);`staff_account.register` 不能指定密码,计划的"旧密码失效"oracle 不可满足(≈10 min);**`/auth/logout` 返回 200 但 bearer token 继续有效**(≈8 min,Runtime 安全问题,新);`project.source_metadata_key_forbidden` 误匹配 Go 局部变量名 `objectKey`(≈5 min);verify 对 finalize 后改源码只报 "finalization receipt is stale",不提示重跑 `apply finalize`(≈3 min)。
- 代理建议:reports.md 写明"跨对象汇总 = ledger 需求"的配方;骨架生成器加 `--with-setup`(按 Action 关系输入生成 setup 链)和共享 `support_test.go`;把 `_test` 文件名、CAS 守卫写法、metadata 标识符三条 lint 提前到 `apply model` 生成 packet 时;logout 与 BusinessError 两条 Runtime 事实放进 Handler 文档。
- 观察:代理三次打开 `~/.claude/projects/...` 下的转录文件(给自己计时),brief 未禁止;mini-01 起已加禁令。

## mini-01 — 2026-09-11,PB 全流程验证(skill 0.3.56:prd-from-plan + 契约切片 + 生命周期 TODO)

- 目的:验证 Project Builder 全流程(contract → frontend → mock → backend → runtime → done)在三项改动后是否走得通,不是计时对照。需求 /tmp/mini-request.md(请假审批,7 条需求,经理/成员两角色,含 1 个报表),`review_policy: autonomous`,Opus,brief /tmp/mini-brief.txt。
- **结果:`done`,81 分钟**(16:09:33Z → 17:30:34Z)。mock 11 用例、runtime 11 用例覆盖需求 1～8;backend-check 分母 16 FAPI,initial+restart 各 16 通过;verify 235 s。阶段用时:contract 9:41(freeze 2:23 + 建模与 apply model 7:18),frontend 26:57(含 4 轮 mock 验收),backend 41:00,runtime 3:01。三次 `reopen --batch` 本身 2 分钟,但每次都拖一轮 frontend-install + mock 重跑。
- **生命周期 TODO**:全程与 `status` 无一次不一致,三次 reopen 后 Frontend 列即时退回 pending;agent 实际用到的是 Notes(跨阶段传决策的唯一通道,后端阶段照着写模型和 Handler)、Designed(要实现的 Action 身份)、Pending by stage;其余状态列信息量低。契约阶段的 Notes 记了每条需求的建模决策与对原始需求的偏离(如 Identity 不接受指定密码 → 系统生成一次性密码)。
- **契约切片**:流程够用(agent 直到 mock 通过进后端才读 builder-v1 SKILL.md),但只靠它写不出能过 `model plan` 的模型:字段 DSL 修饰符顺序、`field_permissions` 默认开、Object SQL 硬约束、报表参数不能带默认值,都得去读 backend-model.md / reports.md(阅读计划 model 段点名的,不算越界)。
- **prd-from-plan**:16 行 FAPI,路由/方法/call_sites/授权/观察项全对,无错生成;agent 补的是业务结果、拒绝码与拒绝方、D-01 决策、20 条清单。2 条计划未绑定行(logout、member list)的 `SET-THE-PRD-REQUIREMENT-NUMBER` 占位符没有文档提。
- **暴露的问题与处置**:
  1. Runtime records 列表 `page>=2` 一律 500(`backend.internal`,`{"operation":"list records"}`),游标 `after_id` 正常;交付的 record-client 没有 `after_id` 参数,前端只能做"窗口式翻页"绕过。根因两层:runtime `57b0f8d` 让 store 返 400,但领域服务 `recordInternalError` 把所有仓储错误重贴成 internal → **runtime v0.1.28 修**;record-client 加 `afterId`/`next_after_id`,Mock 后端同样拒绝无游标的 page>1(让翻页在 mock 阶段就失败)→ **plane `f4018bb`,0.3.57 部署**;三处 Skill 文档写明游标契约。
  2. mock 审计只查 Action 字面量,records/report 的对象键写成变量时后端阶段的 inventory 派生找不到调用点,只能 reopen → `audit_frontend_identities` 现在也要求 records/report 键以字面量出现在交付客户端调用形式里(**PB 修**)。
  3. 后端阶段禁止直接重跑 `ui-check --mode mock`,任何前端改动都得 `reopen --batch` → 放开 backend 阶段的 mock 重跑(它本来只作废 mock 证据)(**PB 修**)。
  4. `freeze` 直接把 stage 推到 frontend 而契约建模未做 → `status` 在快照缺失时报 `contract_stage_complete: false`、required_skill 指向 builder-v1 与 contract-stage.md,`record-skill builder-v1` 在此窗口被接受(**PB 修**)。
  5. `backend-check` 按计划 `test_path` 要求分文件,骨架生成器只出一个文件且 `--check` 不看路径,agent 在 finalize 后才撞上,多付一轮 finalize → 生成器按 `test_path` 分文件、`--check` 校验路径(**builder-v1 修,见下一条记录**)。
  6. 报表参数不能带默认值、Report 源 Object 不能挂 `backfill=`(报错文本无关:`report.definition.object_context_invalid: json: unknown field "upgrade"`)、`model plan` 失败轮次不落盘不可审计 → 前两条写进 contract-stage.md"现在就定"清单;后两条待平台侧。
  7. Identity audience:交付 admin 树的 `.env.example`/`api.ts` 写 `domainry-admin`,项目 Runtime 的 `IDENTITY_AUDIENCE` 是 `domainry-runtime`,不匹配只报 401 → 写进 static-product-ui 交接文档。
  8. 杂项:`frontend-install --manifest` 报错不给候选路径(**PB 修**:列出候选);Playwright 浏览器版本与脚手架安装的 `@playwright/test` 不匹配、npm 11 拦 esbuild postinstall(写进交接文档);导航编译器标记块只接受纯 JSON;`apply model` 撞 sum.golang.org 瞬时错误无重试。
- **三个 Skill 之间仍重复的劳动**(agent 报告):业务校验规则前端/Playwright/Handler 三写;Mock scenario 手抄后端模型(记录、字段、select 词表没有生成物);权限 key 在 `MockAuthGateway` 逐字重复;导航 key → 角色映射手抄;验收断言 mock/runtime 双写;计划 binding / PRD / inventory 三处描述同一接口。下一步候选:从契约快照生成 Mock scenario 骨架与权限表。

## 持续优化循环:基线(2026-09-11,用户 /goal)

目标:以 mini 项目为基线,在保证质量的前提下缩短三个 Skill 的执行时间与上下文 token 消耗;避免拟合单项目(交替两套需求:A 请假审批 /tmp/mini-request.md,B 设备报修 /tmp/mini-request-b.md);每轮评估环境隔离(新目录、其它项目 chmod 000、独立端口、禁读 ~/.claude/projects)。

度量口径(`~/.claude/handoffs/tools/pb_flow_profile.py <transcript> <stage-log>`):墙钟、模型调用次数、输出 token、**上下文体量**(每次调用处理的 cache_read + cache_create + input 之和,直接对应压缩次数与费用)、工具调用数、Skill 文档读取量(按提及次数 × 全文大小,是上界)、工具结果字节。质量门:PB `done`(mock + runtime ui-check、backend-check 两阶段)+ 独立复核。

| 轮 | 需求 | Skill | 墙钟 | 调用 | 输出 k | 上下文 M | 工具 | 文档 KB | 结果 KB | 备注 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mini-01 | A | 0.3.56 | 81 | 531 | 392 | 122.6 | 368 | ≤1285 | 868 | 3 次 reopen;翻页 500 绕行;契约 9:41 / 前端 27 / 后端 41 / runtime 3 |
| bench-17(仅后端) | 实验室 | 0.3.55 | 63 | 257 | 293 | 54.1 | 165 | ≤443 | 742 | 对照:单 Skill 后端交付 |

mini-01 分阶段:契约 9.7 min / 1.6 M ctx;前端 24.3 / 34.2 M;后端合计 41 / 74 M(含三次 reopen 的重跑);runtime+done 6.6 / 9.5 M。最常被重复读取的文档:verification.md(53 KB,7 次提及)、backend-model.md(46 KB,7 次)、builder-v1 SKILL.md(33 KB,6 次)——压缩后重读是上下文体量的主要来源之一。

## mini-02 — 2026-09-11,skill 0.3.58(生命周期 TODO + 契约阶段切片 + prd-from-plan),需求 A

- 隔离:新目录 `~/mini-02`,其余项目目录 chmod 000,端口 18580/18590/5472/4472,禁读 `~/.claude/projects`;brief `/tmp/mini02-brief.txt`。
- **墙钟 83.8 min**(stage-log 17:54:03Z → 19:17:53Z;转录首末 87.8)。契约 9.3 / 前端+mock 27.6 / 后端 25.6 / **runtime 21.2**。对照 mini-01:81 min,契约 9.7 / 前端 24.3 / 后端 41(3 次 reopen)/ runtime 6.6。
- 剖析:模型调用 476(mini-01 531),输出 400 k(392),**上下文 104 M(122.6)**,工具 307(368),文档读取 ≤832 KB(≤1285),结果 969 KB(868)。
- 质量门:mock 10 用例 / runtime 10 用例;backend-check 分母 9,initial 9/9、restart 9/9;独立 verify(:18790)`verified_and_stopped` 9/9 + 9/9。**零 reopen**(mini-01 3 次)——契约阶段把报表参数、游标分页写进 Notes 后,后端阶段没有再改契约。
- 后端阶段 41 → 25.6 min、上下文 74 M → 41 M:prd-from-plan 生成 PRD(39 个 AUTHOR 格)、骨架按 test_path 分文件、生命周期 TODO 的 Designed/Notes 列直接被后端用作对账表。
- **runtime 阶段 6.6 → 21.2 min 是本轮唯一恶化**:5 轮 runtime ui-check(前 4 轮失败)+ 5 次配套 mock 重跑。四个失败全部是脚手架/校验器自身缺陷、且只在 runtime 才暴露:
  1. `helpers.ts` `readback(page, path)` 先经 `/` 离开再回来,而角色落地路由就是 `path`(`/` 重定向回去),`waitForURL(pathname !== path)` 永远不成立 → 120 s 超时;mock 模式不执行回读分支,所以 mock 永远绿。
  2. `quality.spec.ts` 改页容量后同步读行数(`count() <= smallest`),Mock 客户端同步所以绿,真 Runtime 一次往返后才刷新 → 13 > 10。
  3. `runtime.spec.ts` 的 `[PB:runtime-unavailable]` 切断的是 app origin 的 `/auth`、`/report`,而 `playwright_outcomes` 要求 **runtime_origin** 上有一次真实失败传输;10 用例全绿却整轮判失败,报错不说是哪个用例。
  4. hosted Runtime 的工作区管理员带 `must_change_password`:token 签发成功但业务路由一律 403 `auth.password_change_required`;脚手架 `signInInDocument` 只有一个口令;产品自身也在改密前拉业务数据,两条 403 控制台错误被 quality baseline 抓成失败。
- 平台缺陷(未改平台):字段 `legacy=exempt` 触发 `report.definition.object_context_invalid: json: unknown field "upgrade"`(报错指向报表,真因在对象字段);`identity_handler_delivery` 建出的 profile `owner_user_id` 是创建者(经理),成员 `member.read;owner` 读不到自己 → 改 `;org`;重复邮箱 `member.enroll` 返回 500 `backend.identity.user_email_exists`(应为 4xx);`project check --scope all` 把导航缺件重复报成 `project.actions_invalid`;`Page(page, pageSize)` 页容量必须内联整数字面量(常量也拒),packet shared_constraints 未列。
- 文档错:builder-v1 SKILL.md 第 48 行的 `--write` 被读成 `generate-acceptance-skeletons.py --write`(不存在);backend-model.md 说 `project check` 不查导航,实测查;prd-from-plan 把前端 `logout()` 调用点生成为计划外的 `FAPI-AUTH-LOGOUT` 且标 `authenticated`,skeleton `--check` 又说必须 `public`;lifecycle-todo 头部 `Stage: frontend` 与 `contract_stage_complete: false` 并存。
- 三 Skill 重复劳动(agent 报告):需求文本四写(plan outcome / PRD / Notes / 用例标题);接口清单两次推导口径不同;identity 字面量审计前后端各一次、报错时机差一个阶段;同一业务规则三层断言、测试数据搭建两套;mock scenario 是后端的一次性影子;改密流程实现三遍。
- 下一步:修脚手架四缺陷 + `ui-check --mode runtime` 在 mock 证据过期时自动先跑 mock;playwright_outcomes 报错带用例标题;prd-from-plan 对计划外行给出对账提示并沿用 identity 授权级;文档三处更正;补 must_change_password / profile 归属 / Page 字面量三条事实。

## mini-03 — 2026-09-11,skill 0.3.59(runtime 阶段脚手架修复 + 链式 mock 重跑),需求 B(设备报修,首轮)

- 隔离:新目录 `~/mini-03`,其余项目目录 chmod 000,端口 18680/18690/5473/4473;brief `/tmp/mini03-brief.txt`;Opus。
- **墙钟 104.8 min**(stage-log 19:32:57Z → 21:17:45Z;转录 105.7)。契约 14.9(含 1 次 reopen:GAP-1 行级数据范围)/ 前端+mock 20.1(含第 2 次 reopen:分页 FAPI)/ 后端 40.6(起于第 3 次 reopen:prd-from-plan 发现未绑定 auth.logout,与 mini-02 同一坑)/ **runtime 27.8**(4 轮 runtime ui-check,前 3 轮失败)。
- 剖析:模型调用 574,输出 410 k,**上下文 129 M**,工具 379,文档读取 ≤908 KB(verification.md 5 次 × 53 KB 占最大头),结果 963 KB。
- 质量门:mock 13 用例 / runtime 13 用例;backend-check verify 两阶段全绿;独立 verify(:18990)`verified_and_stopped`,initial 19/19、restart 19/19(FAPI 分母 19,含 GAP 绕行的 action_only 列表与分页接口)。
- 需求 B 与 A 的差异暴露了平台表达力缺口:**GAP-1** 行级数据范围只有 all/owner/org/org_child/target_org,owner 恒为创建者(调度员),"维修工只看指派给自己的工单"无法用 Role 数据范围表达 → 用 action_only 列表 Action 绕行;GAP-3 分页接口单列绑定。
- runtime 阶段三轮失败的共同形态:quality baseline 的"零控制台错误"在真 Runtime 上抓到 `Failed to load resource: 401/403` 与一条 CORS(报表直连 Runtime 源而不是走 app-origin 转发器),外加 3 条业务缺陷(分页两页重复、统计页错误态、开始处理后状态未刷新)。agent 没有放宽断言,而是修产品(session 未登录不拉数据、报表走转发器、分页 afterId)。**Mock 永远不产生这些信号**(Mock 不发 HTTP、不按角色拒绝、没有 CORS、没有强制改密),所以它们只能在 runtime 阶段以 4-5 min/轮的代价暴露——这是 A、B 两个需求共同的结构性瓶颈,不是单项目拟合。
- 0.3.59 修复的信号:readback 无超时;`[PB:runtime-unavailable]` 首轮即满足 runtime_origin 判据;链式 mock 重跑(runtime 轮之间没有单独的 mock 命令轮次)。
- agent 报告要点:契约阶段只读了 contract-stage.md("够用,精准命中报表参数/游标分页两个坑");`model plan` 契约阶段 2 次失败(`indexed` 修饰符用在 relation 字段;Handler access 引用不存在的 `deletion_record`)+ 后端阶段 1 次(GAP-6);prd-from-plan 的 AUTHOR 格分布同 mini-02,并**正确报警**了未绑定的 auth.logout 调用点(但发生在 mock 通过之后,已在 0.3.60 提前到 mock 审计)。
- 新平台缺陷:**GAP-7 `/report/*` 与 `/auth/*` 响应不带 CORS 头**(preflight 有,真响应没有;records 有)→ 报表只能走同源转发器,mini-02 同样;**GAP-6 `max_length` 按字节计数且 Action input 上不生效**(300 字 → 汉字 100 个就拒;900 ASCII 进 Handler)→ 模型放大三倍 + Handler 按 rune 判;**GAP-8 报表 `datetime!` 参数必须带时区**,文档未写;**GAP-5 password 登录无刷新凭据 → logout 不吊销、SPA 刷新掉线**,且 verification.md("204 + Set-Cookie 清 cookie,重放被拒")与实现包 v15("logout 什么都不吊销,断言该契约")互相矛盾;脚手架 nonce 是每次运行一个而非每用例一个 → Runtime 下第二个用例撞邮箱,一轮挂 9 个用例;`backend-check` 要求先 `record-skill` 但 next_action 没说;`project check --project` 传 `backend/` 时报"snapshot root must equal the Git worktree root";`dev-runtime.sh start` 把 go 的 `go mod tidy` 建议原样打出;`ia` 默认 `go test` 10 min 超时不可见;冻结时 oracle 写"错误消息包含 X"无人提醒(Message 到不了客户端)。
- 三 Skill 重复劳动(agent):[PB:n] 与 TestFAPI* 证明同一批规则、oracle 同文两写(建议由 plan oracle 生成两侧骨架);"建维修工 + 派工单"前置链三写(scenario / journey / Go fixture);业务规则四处表述;平台缺口四处登记;CORS 绕法前端阶段发现一次(/auth)运行时又一次(/report)——**Mock 对传输层全盲**。

## mini-04 — 2026-09-11,需求 A(请假审批),skill 0.3.60(Plane 9b2e53b,runtime v0.1.30)

- 隔离:新目录 `~/mini-04`,端口 18880/18890/5573/4573,brief `/tmp/mini04-brief.txt` 禁读 mini-01..03 与 `~/.claude/projects/`;参考目录 chmod 000;Opus。
- **墙钟 98.9 min**(阶段日志口径 93.7:21:45:35Z → 23:19:15Z)。对照 mini-02(同需求 A,0.3.58)83.8 min。
- 自报 + **独立复核一致**:PB `done`;mock/runtime ui-check 各 10 条全过;backend-check 17 个 FAPI,initial 17/17、restart 17/17;独立 verify(:19090)同样 `verified_and_stopped`,两个 phase 各 17/17。零弱化。
- 剖析(`pb_flow_profile.py`):

| 阶段 | min | 调用 | 输出 k | 上下文 M | 工具 | 文档 KB | 结果 KB |
| --- | --- | --- | --- | --- | --- | --- | --- |
| contract | 6.0 | 37 | 29.2 | 3.6 | 25 | 412 | 239 |
| frontend(首轮) | 23.8 | 133 | 123.8 | 35.5 | 86 | 172 | 198 |
| backend(首轮,撞 oracle 冲突) | 3.4 | 26 | 15.5 | 10.7 | 18 | 199 | 131 |
| reopen → 重新冻结 → mock 重跑 | 1.4 | 6 | 5.2 | 2.6 | 6 | 0 | 1 |
| backend(Handler+17 FAPI+finalize) | 29.7 | 175 | 107.8 | 32.5 | 123 | 262 | 301 |
| runtime | 26.3 | 97 | 48.5 | 30.2 | 67 | 12 | 88 |
| done | 4.9 | 21 | 22.7 | 7.6 | 15 | 20 | 15 |
| **合计** | 98.5 | 520 | 365.4 | **125.7** | 357 | ≤1094 | 998 |

- 与 mini-02(同需求)对比:契约 9.3→6.0,前端 27.6→23.8,后端 25.6→33.1(FAPI 9→17,交付面本身翻倍),runtime 21.2→26.3,上下文 104→125.7 M。**契约与前端的减法生效,runtime 阶段反而变长,是本轮的主要归因对象。**
- reopen 1 次(上一轮已预告的两条 oracle:logout 不撤销 password bearer、降序业务排序不能配游标续页)。

### runtime 阶段 26.3 min 的构成(逐工具调用还原)

单跑一次 runtime 套件只要 52.5 s,26.3 min 里几乎全是查错:

1. **CORS 与交付 Identity 客户端互斥(≈8 min)**:客户端对每个 `/auth/*` 写死 `credentials: 'include'`,Runtime 回 `Access-Control-Allow-Origin: *` 且无 `Allow-Credentials`,浏览器拒发 → 10 条全挂在登录,而 `curl` 全绿。代理最后用客户端自带的 `fetch` 注入点绕过。
2. **`initial_credential` 生成类型是 `string`,Runtime 返回对象(≈7 min)**:`tsc` 全绿、Action 在 Runtime 上执行成功、后端验收全绿,只有页面什么都不显示。四条用例连环失败。
3. **改密永久生效这一事实没人写(≈5 min)**:代理按 run nonce 派生轮换口令,第一次跑完就把工作区管理员口令换成下轮无法复现的值,第二次必然全挂;且 runtime 轮"用谁登录"没有任何契约,环境变量名是代理自己起的。
4. **enrol 非幂等 + Playwright 失败后重启 worker(≈3 min)**:模块级 registry 被清空而 Runtime 里账号还在,`user_email_exists` 连环失败。
5. **nonce 规则倒逼产品加列(≈3 min)**:需求 §4 的列里没有"事由",但 nonce 只能写进事由,于是为了验收给产品加了一列。

### 本轮据此做的源码修复(全部进 0.3.61 / runtime v0.1.32)

- Runtime v0.1.32:CORS 回显请求方 Origin 并带 `Access-Control-Allow-Credentials`(`*` 只是开发配置,生产配置本就拒绝它);记录列表 filter 键必须命名对象字段,否则 `400 backend.validation.filter_field_unknown`,`{"id": ...}` 按 `id__in` 单值处理(过去是静默丢弃 → 返回整页,调用方以为读到了自己要的那一条)。
- Plane:identity-delivery 的 `initial_credential` 生成为 `{ initial_password, must_change_password }` 对象类型;packet 的 stage_boundary 写明 `apply model` 后要 `apply compose`;`apply-model.sh` 不再打印它自己不接受的 `--reason` 用法。
- PB:acceptance scaffold 增加 `RUNTIME_ADMIN`(读 dev-runtime 的 `DOMAINRY_MANAGED_RUNTIME_*` 导出)与 `rotatedPasswordFor()`(按 login id 派生,可跨轮复现),`prepareSession`/`switchAccount` 注释写明改密永久生效、enrol 幂等回落、worker 重启会丢 registry;runtime 的 `next_action` 改成先 `eval dev-runtime.sh env --with-secrets`;freeze 新增两条 oracle 警告(logout 撤销、降序+游标);所有权审计的 raw transport 消息说明如何把传输注入交付客户端。
- 文档:verification.md(filter 键契约、Runtime 用 `params.field` 而 Handler 用自己的 params)、backend-model.md(Action 入参上的长度修饰符是落库约束,不校验 Action payload)、两个前端交接文档(凭据对象形状、改密永久、enrol 非幂等、CORS 凭据)、batch-acceptance.md(nonce 标签要放进需求本来就渲染的字段,不要为验收给产品加列)。

## mini-05(skill 0.3.62 + runtime v0.1.32,需求 B 复测)

对照 mini-03(同需求 B,skill 0.3.59):**104.8 min / 129 M → 106.4 min / 96.7 M**。
时间基本持平,**上下文降 25%**;reopen **3 → 0**;独立 verify 全绿。

| 阶段 | mini-03 | mini-05 | 说明 |
|---|---|---|---|
| contract | 14.9 | **10.6** | `model plan` 2 轮(mini-03 是 3 轮 + reopen) |
| frontend | — | 23.1 | mock ui-check 一次过,28 s |
| backend | 40.6(19 FAPI) | **27.7**(16 FAPI) | backend-check 一次过 189 s |
| runtime | 27.8 | **41.6** | 3 次 runtime ui-check(133 s 失败 / 108 s 失败 / 113 s 通过)+ 2 次强制回跑 mock |
| 合计 | 104.8 | 103.2(阶段日志)/ 106.4(剖析口径) | 405 次工具调用,715 KB skill 文档 |

独立 verify(我在全新数据库上自己跑,不信代理自报):backend IA **16/16 initial + 16/16 restart**,
runtime 浏览器验收 **10/10**,mock **10/10**。抽查代理自称"绕过"的两处均非弱化:排序断言只把平台
自相矛盾的种子行 `WO-001` 排除,产品登记的行仍全量断"紧急程度降序 + 登记时间倒序";
`quality.spec.ts` 的零控制台错误基线原样保留。

### 三条预注册判定的结果(规则写在 /tmp/mini05-analysis-plan.md,开跑前落盘)

**1. 契约阶段文档:生效。** 按阶段归因转录里的文档读取:`verification.md` 契约阶段 **0 次**、后端 2 次;
`backend-runtime.md` 契约阶段 **0 次**、后端 1 次。这正是 0.3.62 把九条 Runtime 事实搬进
`contract-stage.md` 想要的效果。按预注册规则,**同样手法用到后端阶段**(那里仍整份读 54 KB 的
verification.md 两次)。
但契约阶段文档量反而从 412 KB 涨到 473 KB:`model capability` 的 `read_order` 本身要求读
`backend-model.md`(46 KB,**读了 5 次** ≈ 230 KB),这是契约阶段现在最大的单项。

**2. reopen:0(mini-03 是 3)。** freeze 新增的两条 oracle 警告本轮没派上用场,按规则**不把警告升级成硬拒绝**。

**3. runtime 阶段 41.6 min > 20 min → 按规则判定"归因错了"。** 需要说清楚它错在哪:
mini-04 归因的五条(CORS 凭据、`initial_credential` 类型、改密永久、enrol 非幂等、nonce 逼加列)
**本轮一条都没有复发**,修复都命中了。但 runtime 阶段反而更长,因为两条**新的平台自相矛盾**填了进来:

- **托管 Runtime 给 `action_only` 对象播种了产品路径不可能产生的行。** `work_order` 是 `action_only`
  (状态、工单号、`urgency_rank` 全由 Handler 派生),种子行却是 `urgency=low` + `urgency_rank=3`
  两者互斥。验收断"按紧急程度降序"必挂,而这行永远不可能由产品产生。
- **static-product-ui 交接文档的两条要求在全新数据库上不可能同时满足。** 它要求 `prepareSession`
  "先试轮换口令,失败回落一次性凭据",又要求静态质量基线"零控制台错误";全新库上第一次登录必然
  `403`,浏览器必然记一条控制台错误。

所以真正的结论不是"某几条事实没写进文档",而是:**runtime 阶段是整条流水线里第一次真正跨进程集成的
地方,任何平台侧的不一致都只能在这里被发现,再补多少文档事实也不会缩短它。** 减少它的唯一办法是让
不一致更早暴露(Mock 层做传输/权限仿真),以及把平台自身的不一致修掉。

### 本轮修在源码的(按实测代价排序)

代理报告里的流程问题共 10 条,按它实际付出的代价排:

1. `EnrollIdentityUserMutation.Status` 不写 `"active"` → 整条 identity 交付 `400
   backend.identity.profile_binding_target_invalid`,`params` 是 `null`,Runtime 日志零匹配;
   15/16 用例同时红。唯一写了这条的文档属于 model 阶段阅读计划,后端实现阶段根本不读它。
2. `dev-runtime.sh start` 对已运行实例复用**旧二进制**且只提示 `--fresh`,改完 Handler 重跑看起来像
   "修复没生效",浪费整整一轮。
3. `model capability` 内联的 `schema.object.ux.config` 机器契约缺 `cardinality` /
   `business_identity` / `default_visibility`,而文档正文是对的 —— 机器契约被明确要求"只用它返回的
   exact keys",却是三方里唯一错的一方,`model plan` 因此多返一轮。
4. 上面两条平台自相矛盾(种子行、交接文档)。
5. `project.navigation_invalid` 的"全有或全无"规则只在后端阶段暴露;交接文档写的是 "may author",实为 must。
6. `project.source_binary_float_forbidden` 拦的是标识符而非语义,而生成代码自己遍地 `float64`
   (`CompleteInput.ActualHours`),项目里也没有它建议的 `schema.NumberFromDecimalString`,只能靠不写出类型名绕过。
7. Runtime 日志 `http_request` 的 `path` 恒为 `"/"`,排障时无法定位是哪个路由被拒。

### 仍未动的结构性项

Mock 对传输与权限失明;同一条业务规则在四处重复表达(模型 roles → 前端 mock 权限数组手抄 →
导航 permission → PRD §7);验收断言前后端各写一遍;dev-runtime 生命周期知识散在三份文档且都不全。

## mini-06(skill 0.3.63 + runtime v0.1.33,需求 A 复测)

对照 mini-04(同需求 A,skill 0.3.60):**98.9 min / 125.7 M / 520 次调用 → 85.3 min / 106.6 M / 447 次**。
**时间 -13.8%,上下文 -15.2%,调用 -14%**;独立 verify 全绿。这是本目标第一次时间与上下文同时下降。

| 阶段 | mini-04 | mini-06 | 说明 |
|---|---|---|---|
| contract | 6.0 | 10.3(+0.5 reopen) | 5 次 `model plan` **全部首轮 valid** |
| frontend | 23.8 | 24.9 | mock ui-check 21 s 一次过 |
| backend | 29.7(17 FAPI) | **37.7**(16 FAPI) | 其中约 19 min 是授权模型的发现循环 |
| runtime | 26.3 | **7.8** | 4 轮 ui-check,3 轮失败全是 mock/runtime 真实差异,无产品逻辑错 |
| 合计 | 98.9 | 85.3(剖析)/ 81.2(阶段日志) | 761 KB skill 文档 |

独立 verify(全新数据库,我自己跑):backend IA **16/16 initial + 16/16 restart**,
runtime 浏览器 **10/10**,mock **10/10**。抽查代理自述的两处绕法均非弱化:`readback` 在"该 principal
只有一个目的地"时回落为整页 reload —— 丢弃全部 SPA 状态并重新取数,比"离开再回来"更强;
`quality.spec.ts` 的零控制台错误基线原样保留。

隔离核对:代理确实读了 `~/.claude/projects/.../tool-results/` 下三个文件,但三者都是 harness 把
**它自己**的超长工具输出落盘后的回读(时间戳 03:58/03:59/05:02,全在本轮窗口内,内容是它自己的
model 文件、自己 cat 的 Skill 文档、自己的 Go 测试输出)。禁区约束没有被破坏,但任务书里
"不要读 ~/.claude/projects/" 这条在当前 harness 下无法严格成立,下一轮改为"只允许回读本轮自己的
tool-results 文件"。

### 三条预注册判定的结果(规则写在 /tmp/mini06-analysis-plan.md,开跑前落盘)

**1. 总时长 < 88 min:达成(85.3)。** 但省下来的钱不在预期的地方:runtime 阶段 -18.5 min,
backend 阶段 +8.0 min。规则写的后续动作是"把减法用到后端阶段的文档量",而实测后端的成本**不是**
文档量(281 KB,与 mini-04 同量级),是授权模型的发现循环。规则的动作与数据不符,按数据走。

**2. runtime 阶段 < 15 min:达成(7.8,mini-05 是 41.6)。** 这确认了 mini-05 的结论:
runtime 阶段变长的主因是平台自相矛盾(`action_only` 播种、交接文档打架),不是"文档事实不够"。
该方向收束,不再往 runtime 阶段补文档。

**3. 两条修复各自命中:达成。** 全程 5 次 `model plan` 全部首次提交即 valid(mini-04 同需求返工多轮),
`backend.identity.profile_binding_target_invalid` 一次都没出现。`ux.config` 契约补全与 `Status` 默认
`active` 两条可以标记为已关闭。

### 本轮暴露的新的最大单项:授权规则没有单一来源

后端阶段 37.7 min 里约 19 min 消耗在同一个环路:改授权 → Runtime 403 → 探针定位 → 改模型 →
`plan/apply/compose/重启/重跑`(每轮约 8 min)。两个根因:

- **`backend.record.outside_scope` 的 `params` 是 `null`**,不说是哪个 Object、哪个字段。代理只能自己
  写探针脚本逐调用定位。这是可以在 Runtime 源码里修的:拒绝时把对象键与字段键放进 params。
- **关系字段目标的可写性走的是调用者对目标 Object 的读授权,不是 Action grant 的 scope**。
  `actions-and-transactions.md` 写的是 "`all` adds no data-scope predicate",照此理解必然踩坑;
  `identity-handler-delivery.md` 还把一条走不通的方案("通过 identity 关系解析调用方 Profile")
  与可用方案并列,代价是一整轮。

同一条授权决定要改 6 处:`backend/model` roles、`navigation-role-menus.json`、前端 `navigation.ts`
的 `permission`、`App.tsx` 的 `<Protected>`、mock 的 `demoAccounts.permissions`、以及 Go 与浏览器两侧
的断言。漏改任一处都在不同检查点以完全不同的形式失败。代理自己给出的首选建议与此一致:
由 `backend/model` 的 roles 生成前端可消费的权限清单,同时喂导航校验与 mock 账户。

### 代理报告里其它值得修的(按代价)

`project check` 的 `project.source_call_result_discarded` 与 `backend-runtime.md` 明确写的豁免条款冲突
(四个 Handler 各中一次);`prd-from-plan.py` 生成的 §9 自相矛盾(同一张表一行说平台先拒、另一行要求断言
Handler code)、§10 表头分隔行多一列、§6 计算行只渲染 15 格而表头声明 18 列、§8 首格不是裸 `AUTHOR`;
`apply-model.sh` 的第二种停点(`project_source_conflicts`,把上一轮的实现文件记成 seed)没有任何文档;
`compile-project-navigation.mjs` 的必填参数与菜单 label 形状没写;`bootstrap-static-product.mjs` 与
`frontend-install` 的命令顺序互斥;`date` 类型在 Action 输出是 RFC 3339 而在 Report 列与 Mock 里是
`YYYY-MM-DD`(mock 绿、runtime 才炸)。

## mini-07(skill 0.3.64 + runtime v0.1.34,需求 B 复测)

对照 mini-05(同需求 B,0.3.62):**106.4 min / 96.7 M / 405 次 → 95.8 min / 100.7 M / 419 次**。
时间 **-10.0%**,上下文 **+4.1%**。独立 verify 全绿。

**分母变了,必须先说**:同一需求 B,本轮代理把它拆成 **23 条 FAPI**(mini-05 是 16 条),
ui-check 11 个用例(mini-05 是 10 个)。所以"时间降、上下文略升"是在多做 44% 接口覆盖的前提下发生的。
这是跨轮对照的一个真实噪声源:分母由代理的分解粒度决定,不由需求决定。下一轮的任务书要把
"FAPI 分解粒度"这件事显式约束住,否则总时长不可比。

| 阶段 | mini-05 | mini-07 | 说明 |
|---|---|---|---|
| contract | 10.6 | **14.7** | `model plan` 2 轮(第 1 轮被 `deletion_record` 拒) |
| frontend | 23.1 | **43.0** | 三次 mock:458 s 失败 + 28 s 失败(端口占用)+ 26 s 通过 |
| backend | 27.7(16 FAPI) | **26.6**(23 FAPI) | backend-check 一次过 241 s |
| runtime | **41.6** | **15.2** | 2 次 runtime ui-check:167 s 失败 + 149 s 通过 |
| 合计 | 106.4 | 95.8(剖析)/ 99.5(阶段日志) | 591 KB skill 文档(mini-05 是 715 KB) |

独立 verify(全新数据库,我自己跑):backend IA **23/23 initial + 23/23 restart**,
runtime 浏览器 **11/11**,mock **11/11**。`quality.spec.ts` 的零控制台错误基线原样保留。

### 三条预注册判定的结果(规则写在 /tmp/mini07-analysis-plan.md,开跑前落盘)

**1. 总时长 < 95 min:差一点没达到(95.8)。** 落在"部分成立"区间。但分阶段看方向是对的:
runtime 41.6 → 15.2,后端在分母 +44% 的情况下还略降。多出来的时间几乎全在 frontend(23.1 → 43.0),
而那一段的三次 mock 里,458 s 那次是**产品自身缺陷**(登录页在 `/` 上多调一次 `navigate("/")`,
与 Landing 的 `<Navigate>` 相互抵消,路由停在 `/` 渲染空白),28 s 那次是**代理自己的环境失误**
(上一次诊断留下的 vite 还占着 5774)。两者都不是 Skill 缺陷。

**2. runtime 阶段 15.2 min:落在 15–25 的"仍有剩余摩擦"区间,但性质已经变了。**
本轮唯一一次 runtime 失败不再是平台自相矛盾,而是 **Mock 保真度缺口**:
`@domainry/business-client` 的 `ReportRow` 只有 `dimensions` / `measures` 两个桶,**没有任何文档说
哪一列落在哪个桶**;代理按"聚合列 = measure"写产品并据此造 mock 数据,mock 11/11 全过,
真实 Object SQL 报表却把非聚合数值列 `actual_hours_tenths` 发布在 `dimensions` 里。
配合 mini-06(需求 A,runtime 7.8 min)看,**"平台自相矛盾"这一类可以结案**,
剩下的是 Mock 与真实 Runtime 的语义差 —— 也就是一直被推迟的那个结构性项。

**3. 授权发现循环:已关闭。** 全程没有 `backend.record.outside_scope`,没有探针脚本,
授权相关的模型返工 0 轮(`model plan` 的 2 轮里唯一一次失败是 `deletion_record`)。

### 本轮新暴露的(按代价)

- **`backend-model.md` 教的业务流水号写法会被 `model plan` 直接拒**:它让 `handler.access` 声明
  `deletion_record: ["list"]` 以免序号复用,而 `model capability` 根本不发布这个 Object,
  返回 `model.action_data_object_not_found`。文档与编译器矛盾,代价是一轮 plan。
- **`generate-acceptance-skeletons.py` 的"平台预检"清单不准**:它断言声明式输入契约的守卫在 HTTP
  上观察不到,点名让人改断 `backend.validation.*`;但 `object_field` 上的 `max_length` **不在**这层预检里,
  第 301 个字符是进到 Handler 才被拦。需要区分"必填/闭值域"(确实预检)与"长度/范围"(不预检)。
- **ui-check 不对验收套件做类型检查**:`frontend/tsconfig.json` 的 `include` 不含 `tests`,
  helpers.ts 里引用未定义的符号在 mock 轮全过(mock 分支不执行),到 runtime 轮才以 `ReferenceError` 炸。
  `scaffold-acceptance` 生成 tsconfig 时应把 `tests/acceptance` 纳入 typecheck。
- **工具链三连**:pnpm 12 的 `allowBuilds` 写法(Skill 文档停留在 pnpm 9/10)、runner 依赖未被 scaffold
  声明的 `playwright` 包、scaffold 钉的 Playwright 版本与机器缓存里的浏览器 revision 对不上。
- **`prd-from-plan.py` 把四条绑定了后端的路由一律写成 `frontend_only`**,需要人工改回 `backend_bound`。

## mini-08(需求 A 请假审批,0.3.66 + runtime v0.1.36,2026-09-12 08:03–09:17)

**78.9 min / 79.7 M ctx / 381 次工具调用 / 617 KB skill 文档。**
对照 mini-06(同需求,0.3.63 + v0.1.34)85.3 / 106.6 M / 447 次;
对照 mini-04(同需求,基线)98.9 / 125.7 M / 520 次。
**相对基线:时间 −20%,上下文 −37%,调用次数 −27%。**

| 阶段 | mini-04 | mini-06 | mini-08 | 说明 |
|---|---|---|---|---|
| contract | 17.5 | 10.3 | **8.9** | `model plan` 一轮过;两次 reopen 合计 41 s |
| frontend | 31.2 | 24.9 | **22.2** | 三次 mock 全过(21/22/22 s) |
| backend | 23.9(17 FAPI) | 37.7(16 FAPI) | **38.2**(12 FAPI) | backend-check 一次过 198 s |
| runtime | 26.3 | 7.8 | **4.5** | 1 次失败(产品自身用例缺陷)+ 1 次通过 |

独立 verify(全新数据库,我自己跑):backend IA **12/12 initial + 12/12 restart**(各 47 s),
runtime 浏览器 **10/10**,mock **10/10**。没有任何断言被放宽。

### 三条预注册判定的结果(规则写在 /tmp/mini08-analysis-plan.md,开跑前落盘)

**1. 总时长 < 80 min:达成(78.9)。** 按规则"继续沿当前方向做减法"。
可指认的计数:contract 少了一轮 `model plan` 返工,runtime 段从 2 次失败降到 1 次,
且那 1 次是产品自己的用例写错(切回成员时 `switchAccount` 登的是固定 member 账号),不是平台缺陷。

**2. FAPI 分母落在 12,预测区间是 15–18 —— 规则判"约束无效",但数据说的是另一回事。**
翻出 mini-06 的 inventory 对比才看清:mini-06 的 16 行里只有 **10 个互不相同的接口**,
`leave_request.submit` 一个接口被拆成 SUBMIT / SUBMIT-OVERLAP / SUBMIT-REFUSED 三行,
approve 拆两行,两个 Report 各拆两行。mini-08 的 12 行是 **12 个互不相同的接口**(比 mini-06 多 2 个)。
也就是说任务书里的粒度约束**生效了**,失效的是我那个 15–18 的预测区间 —— 它是拿"含场景重复的行数"当基准算的。
每行的观测数没降(5.2 → 5.0),越权、匿名、业务否决(重叠请假、空理由、超长理由、重复邮箱、超大分页)
全部还在断,只是从"一个场景一行"折进了"一个接口一个测试"。**覆盖没被削弱,分母被修正了。**

规则里"改为用机器检查"这一条照做了,而且它本来就不只是评估卫生问题:inventory 的行数是每次审计
对外报的分母("N of M live interfaces verified")。一个接口挂在多个 FAPI ID 下,会让交付报出
16 个已验证接口而前端其实只调了 10 个。plane 侧 `interface_acceptance.go` 现在拒绝第二行去认领
前一行已经认领过的前端 surface,并直接说明场景该折到哪里;两条不同前端路径打同一个 runtime 操作
(别名)仍然合法,因为那确实是前端真会调的第二个 surface。提交 8758bdc。

**3. Report 分桶:该类关闭。** 全程没有"mock 通过但 runtime 读到空值"这一类失败;
产品用了 0.3.66 脚手架里的 `reportValue` 跨桶读法。这是 mini-05 与 mini-07 两个需求各自唯一一次
runtime 失败的根因,两个需求现在都不再复现。

### 本轮新暴露的

- **验收用例里的"切账号"没有对象化**:唯一一次 runtime 失败是用例自己把 `switchAccount` 登成了
  固定 member 账号,而不是该用例新建的那个成员。mock 轮发现不了(mock 不区分身份)。
- **skill 文档读取仍有重复**:`verification.md` 读 2 次、`backend-model.md` 读 3 次、
  `domainry-builder-v1/SKILL.md` 读 2 次,617 KB 里约三分之一是重读。这是下一个可指认的上下文成本。

## mini-09(需求 B 设备报修,0.3.67 + runtime v0.1.36,2026-09-12 09:43–11:26)

**104.6 min / 256.0 M ctx / 898 次工具调用 / 901 KB skill 文档。**
对照 mini-07(同需求,0.3.65 + v0.1.34)95.8 / 100.7 M。
**这一轮是退步:时间 +9%,上下文 +154%,调用次数翻倍。**

独立 verify(全新数据库,我自己跑):backend IA **10/10 initial + 10/10 restart**(各 31 s),
runtime 浏览器 **10/10**(160 s),mock **10/10**(98 s),theme 门 `passed`、四个 token 无一留在默认值。
交付质量没问题,退步全在过程。

| 阶段 | mini-07 | mini-09 | 说明 |
|---|---|---|---|
| contract | 14.7 | **6.5** | `model plan` 2 轮,但没有 mini-07 那种反复 |
| frontend | 43.0 | **35.2** | 三次 mock(137/104/97 s),前两次失败都是产品自身缺陷 |
| backend | 26.6 | **30.1** | backend-check 一次过 170 s |
| reopen 标记 | — | **2.2** | 两次:`acceptance.backend.source` 词表、16→10 FAPI |
| runtime + check | 15.2 | **25.3** | runtime 轮 5 次:149/350/353/259/252 s |

### 四条预注册判定的结果(规则写在 /tmp/mini09-analysis-plan.md,开跑前落盘)

**1. 总时长 > 100 → 规则要求先查"登录页前置 / theme"这条唯一没被验证过的改动。查了,不是它。**
前端阶段反而从 43.0 降到 35.2。超时出在两处:runtime 轮跑了 5 次(mini-07 是 2 次),
以及我自己上一轮加的唯一性检查逼出的一次 full reopen。

**2. theme 门:通过,但顺序只对了一半。** `tokens_left_at_default` 为空,产品不再是起步调色板。
按文件时间:`shadcn-theme.css` 10:03、`brand.ts` 10:04,都在 `frontend-install`(10:04)之前 ——
**视觉体系确实先定了**;但 `LoginPage.tsx` 10:13、`AppShell.tsx` 10:28,都在安装之后。
即"先定调色板、后写登录页"。用户要的结果(别所有系统一个颜色)拿到了,而且现在是机器在守。
**不再为同一个结果加第二道顺序门** —— 那是把已经成立的结果再检查一遍。

**3. FAPI 分母:检查有效,但拦得太晚,而且文档在拆台。**
需求 B 的真实接口数是 **10**。mini-07 报了 23 行,mini-09 报 10 行 —— 两轮覆盖的是**同样 10 个接口**,
mini-07 只是把同一个接口按场景拆成了多行。mini-09 的 10 个测试里有 14 处 `mustReject`、12 处 `mustDeny`、
24 处 `mustOK`,位置冲突、301 字描述、非本人开始、已完成不可改、调度员不能代完成、超大分页全部还在断,
**场景是被折进测试体,不是被删掉**。
代价是一次 full reopen:`project check` 在 backend 阶段跑了 22 分钟后才拒,PRD 和接口测试都已写完。
而 `batch-lifecycle.md` 当时还写着"Multiple bindings may prove one requirement",
`inventory-from-plan.py` 也照样生成了 16 行 —— 文档、生成器、校验器三方打架,是我上一轮改动留下的口子。
已修:派生时就拒(`inventory-from-plan.py` 点名两个 FAPI ID 和它们共用的 surface),
文档改成"多条绑定指的是不同接口;同一接口的第二个场景属于那条绑定的测试内部"。提交 24462de。

**4. Report 分桶:在它原本出问题的需求上复验通过。** 全程没有"mock 通过、runtime 读到空值"这一类。
两个需求各自独立确认,该类关闭。

### 本轮暴露的两个真问题

- **runtime 轮里约 40% 的时间在复证一个没动过的 Mock 原型**:改一处只在 runtime 分支执行的前端测试,
  就要重跑 97 s 的整套 mock 验收,因为回执是按整棵前端源码树的哈希算的,不是按 mock 实际执行到的东西。
  5 次 runtime 轮里有 4 次付了这笔钱。**这是目前最大的一块可指认时间成本。**
- **我的隔离协议把 Plane 弄挂了**:`chmod 000 /home/ubuntu/domainry-plane` 之后 `apply model` 报
  `application_delivery_unavailable … permission denied`,因为 Plane 要从仓库里的 `.codex-run` 取交付件。
  代理只好把它改成 `chmod 100` 才能继续。核对过整轮 transcript:**没有读过 plane/runtime 的任何源码或文档,
  也没碰过其它 mini 目录**,只出现过 plane 日志与二进制的路径。已改为 `~/.claude/handoffs/tools/eval-isolate.sh`:
  只锁 `internal/`、`skills/`、`docs/`、`assets/`、`scripts/`、`cmd/` 这些"答案目录",仓库根保持可遍历。

## mini-10(需求 A 请假审批,0.3.68 + runtime v0.1.37,2026-09-12 11:47–13:08)

**86.4 min / 90.8 M ctx / 423 次工具调用 / 1132 KB skill 文档。**
对照 mini-08(同需求,0.3.66 + v0.1.36)78.9 / 79.7 M / 381 次 / 617 KB。
**时间 +9.5%,上下文 +14%,文档读入几乎翻倍。**

独立 verify(全新数据库,我自己跑):backend IA **10/10 initial + 10/10 restart**(各 41 s),
runtime 浏览器 **10/10**(172 s),mock **10/10**(26 s),theme 门 `passed`。
10 个接口、50 项观测,测试体里 20 处 `mustReject` + 14 处 `mustDeny` + 30 处 `mustOK`。

| 阶段 | mini-08 | mini-10 | 说明 |
|---|---|---|---|
| contract | 8.9 | **~10** | `apply model` 一次过;三次 reopen 的重入合计 2 min |
| frontend + mock | 22.2 | **~24.5** | mock 四轮各 23–28 s |
| backend | 38.2 | **~32.8** | backend-check 200–210 s,两轮 |
| runtime | 4.5 | **~13.8** | 两次失败 + 一次模型演进,全部出自同一个根因 |

### 四条预注册判定的结果(规则写在 /tmp/mini10-analysis-plan.md,开跑前落盘)

**1. 总时长 86.4,落在 80–90 的"持平"区间,规则要求指到具体阶段计数才下结论。指得到:**
后端段降了 5.4 min,runtime 段涨了 9.3 min,而 runtime 段的全部增量出自下面那个 `;org` 根因。
去掉它,这一轮与 mini-08 持平或更低。

**2. 上下文 90.8 M,落在 90–120 的"报事实"区间。吃掉它的是文档读入:1132 KB,mini-08 是 617 KB。**
按段看,前端构建段 30.2 M、后端两段 21.3 + 11.3 M。下一轮的减法目标就是这条。

**3. 接口唯一性:结案。** FAPI 10 行 = 10 个互不相同接口,**三次 reopen 没有一次是唯一性引起的**。
派生时就拒(mini-09 的修复)生效了 —— mini-09 那种"跑到 backend 22 分钟才被拒"没有重演。

**4. `readback` 与"只被提及的账号":两个症状都没再出现。** 但需求 A 的角色导航不止一项,
所以 `readback` 的 runtime 回退**没有被真正触发**,只能记为"未复现",不能记为"已验证"。

### 本轮最贵的发现:`;org` 对引导管理员是空集(约 15 min)

`contract-stage.md` 教的是"identity-delivery Action 创建的 Profile 归调用者所有,所以给 Profile 授 `;org`"。
实际行为:`;org` 比的是**记录的组织与调用者自己的组织**(identity SDK 里 `$subject.org_id`),
而 `target_organization: explicit_or_sole_authorized_store` 把 Profile 建在门店组织里 ——
引导工作区管理员挂在工作区根上,于是 `GET /records/member_profile` 对它返回 `total: 0`。
三个浏览器用例同时炸(成员列表、申请列表、月度汇总,后两个因为 Report JOIN 了 `member_profile`)。

**放大伤害的是 Mock 不施加任何 data scope**:mock 全绿、runtime 全红,而且后端接口验收也看不见它
(接口用例用的是产品自己开通的 manager,人格正确)。这是"平台自相矛盾"这一类的再次出现 ——
我在 mini-06/07 之后宣布它结案,结论下早了:**关掉的是那一批具体矛盾,不是这一类**。

已修(提交 7250048):`contract-stage.md` 在讲 `;org` 的那一段就地补上组织归属这件事,
并说明 Mock 看不见;顺带改正同一段里 `params.email` 这个 Runtime 根本不发布的键(实际是
`params.actual` + `params.field_path`),这条 mini-08 与 mini-10 两轮都观测到过。

### 另一条可机器化的返工

冻结时 `test_path` 只校验"在 `backend/` 下且以 `_test.go` 结尾",而 builder-v1 只编译
`backend/tests/interfaceacceptance/` 这一个包。代理按自然命名冻结了 `backend/tests/interface/`,
到后端阶段才发现,代价是一次 full reopen。已改成冻结时就要求那个目录(同一提交)。

## mini-11(需求 B 设备报修,0.3.69 + runtime v0.1.37,2026-09-12 13:30–15:48)

**143.1 min / 167.5 M ctx / 615 次调用 / 840 KB 文档 / 11 个接口。**
对照 mini-09(同需求,0.3.67 + v0.1.36)104.6 / 256.0 M / 898 次 / 901 KB / 10 个接口。
**上下文 −35%,调用 −32%;时间 +37%。**

独立 verify(全新数据库,我自己跑):backend IA **11/11 initial + 11/11 restart**(48 s / 52 s),
runtime 浏览器 **11/11**(142 s),mock **11/11**(20 s),theme 门 `passed`。11 行 = 11 个互不相同接口。

### 五条预注册判定的结果(规则写在 /tmp/mini11-analysis-plan.md)

**1. 文档读入:主改动成立。`verification.md` 从 5 次降到 1 次。**
总文档 840 KB,略高于 800 KB 的线,但这一轮多跑了 6 次 runtime 诊断轮,其它文档因此被反复回查
(`project-mutation.md` 4 次、`domainry-project-builder/SKILL.md` 4 次)。
**那句"每次进入都整篇重读"确实是驱动因素,改掉它就是 −4 次 × 55 KB。**

**2. 上下文 167.5 M,落在 120–180 的"部分改善"区间。** 从 256 M 降下来主要靠两件事:
文档重读减少,以及 runtime 诊断轮里不再反复回读同一份大文档。剩下的大头是 runtime 段本身。

**3. 总时长 143.1 min,超过 105 的上限。按规则先隔离 v0.1.37 —— 不是它。**
runtime 验收段单独占 **68 min(49%)**,6 次诊断轮 + 2 次完整跑失败。失败原因逐条都不是平台契约问题:
强制改密表单还没渲染就被探测、集成库是空的而用例假设有数据、`a[href="/technicians"]` 在响应式导航下
命中桌面与折叠两套、`switchAccount` 在已登录状态下走 `/login` 被重定向、以及 `readback` 在列表还在
加载时找不到回链**退化成 goForward 后一直等 URL 直到 120 s 超时**。

**4. `;org` 陷阱:文档修复生效。** 模型里 `technician_profile.read;all`,runtime 轮没有出现空列表这一类。

**5. `readback` 的 runtime 回退:验到了,但修得不全。**
需求 B 的维修工导航确实只有一项,`no in-app link leaves this route` 没有再出现(离开那一半修对了);
**但回来那一半根本没有回退** —— 找不到 `a[href=path]` 就 `goForward()`,然后 `waitForURL` 无超时,
整个用例挂死到 120 s。这一条单独吃掉了那次 468 s 的 runtime 轮。

### 本轮的修复(提交 9ccecbc)

- **接口唯一性再前移到 `freeze`**:mini-11 的 `freeze` 放行了 `work_order.register` 上的两条绑定,
  派生时才拒,赔了两次 reopen + 两次 mock 重跑。现在冻结时就按 (source, operation) 全计划去重。
  这条规则的位置终于回到我最初预注册时写的地方 —— 我把它放低过两级,每低一级就多赔一个阶段的返工。
- **`readback` 回来那一半**:先等回链挂载(5 s),再失败时 runtime 模式直接 `goto`,mock 模式抛出
  说得清的错;`waitForURL` 加 10 s 上限,不再靠测试超时兜底。
- **"集成库是空的"写进 helpers 既有的那条 nonce 规则旁边**:Mock 发的是预置场景,Runtime 从空开始,
  用例要断言的行必须自己造 —— 包括那些只被指派、从不登录的账号。mini-09 与 mini-11 两轮都栽在这里。

## mini-12(需求 A 请假审批,0.3.70 + runtime v0.1.37,2026-09-12 16:34–17:39)

**67.9 min / 87.1 M ctx / 405 次调用 / 1031 KB 文档 / 11 个接口。**
对照 mini-10(同需求,0.3.68)86.4 / 90.8 M / 423 次 / 1132 KB:**时间 −21%**。
对照此前需求 A 的最好成绩 mini-08(78.9 min):**−14%,是需求 A 至今最快的一轮。**

独立 verify(全新数据库,我自己跑):backend IA **11/11 initial + 11/11 restart**(各 28 s),
runtime 浏览器 **10/10**(64 s),theme 门 `passed`。
**另外我在同一个库上又跑了一次 runtime**(不 `--fresh`),仍然 10/10 —— 可重跑性成立。

| 阶段 | mini-08 | mini-10 | mini-12 |
|---|---|---|---|
| contract | 8.9 | ~10 | **7.1** |
| frontend + mock | 22.2 | ~24.5 | **24.0** |
| backend | 38.2 | ~32.8 | **22.9** |
| **runtime** | 4.5 | 13.8 | **9.4** |

### 四条预注册判定的结果(规则写在 /tmp/mini12-analysis-plan.md)

**1. runtime 验收段(主指标)= 9.4 min,落在 "< 10 min 算修复生效" 的区间。**
mini-11 是 68.1 min。三条修复(`readback` 回程、集成库从空开始、接口唯一性前移)直接打在这一段上。
本轮 runtime 轮 2 次失败 + 1 次通过,两次失败都是产品自身缺陷(过滤切换时旧行未被丢弃导致读到陈旧
`data-request-id`;成员表没有用 Alert 原语所以 `getByRole('alert')` 找不到),**没有一次是 helper 挂死**。

**2. 总时长 67.9 < 80,明显改善。** 后端段从 32.8 降到 22.9 是最大的一块。

**3. 文档 1031 KB、`verification.md` 读 3 次 —— 按规则"需求 A 的驱动因素与需求 B 不同",逐个文件看:
本轮最大的重读是 `domainry-builder-v1/SKILL.md` 读了 6 次(34 KB/次)。**
原因代理说得很清楚:`backend/config/navigation-role-menus.json` 是后端阶段的硬义务,
但它的 schema 只在 `SKILL.md` 正文的一句话里,实现包(`stage_boundary.before_finalize`)完全没提,
于是整个后端写完后才被 `project.navigation_invalid` 拦下,只能回头一遍遍 grep SKILL.md。
**下一轮的减法目标就是它。**

**4. 接口唯一性在 freeze:结案。本轮零 reopen。** 位置从 `project check`(24 min)→ 派生(2 min)→ freeze(0)。

### 本轮修复的平台缺陷(提交 60d9e3a)

- **`generate-acceptance-skeletons.py` 为 `/auth/change-password` 生成不能编译的 Go**:
  该路径不匹配任何路由模式,落到 `call_expression` 的默认分支返回裸名 `response`,于是写出
  `response := response`;同一个文件还对这一个变量既断 2xx 又断 401,证据 source 归到了 `runtime.records`。
  现在它是第三条 Identity 会话路由:单独分类、归到 `runtime.identity`、自己的代码块里点名该用哪个
  harness 原语发起请求。**用 mini-12 的 11 个骨架重新生成并 `go vet` 过整个包验证。**
- **常驻 Runtime 账号会把上一轮的行带进下一轮**,被产品自己的唯一性/重叠规则拒掉。
  nonce 规则原本只覆盖标签,现在覆盖业务键(登录名、日期区间)。

## mini-13(需求 B 设备报修,0.3.71→0.3.74,2026-09-12 18:03–21:0x)

**计时作废,不进时间序列。** 这一轮被两个平台歪斜打断两次,后端段里混着平台排障与清磁盘。
它提供的是质量证据和缺陷清单,不是速度读数。

独立 verify(全新数据库,我自己跑):backend IA **10/10 initial + 10/10 restart**(各 48 s),
runtime 浏览器 **11/11**(153 s),**同一个库再跑一次仍 11/11**(145 s),mock **11/11**,theme `passed`。

### 歪斜一:SDK 与 Runtime 模块的 runtimeext 契约哈希不一致(整轮 runtime 段报废)

Plane 生成 SDK 要求 `d9990bc8…`,而它用来构建项目 Runtime 模块的**本机 domainry-runtime 检出落后 8 个提交**,
仍发布 `d7d20947…`。于是它生成的每个项目都带着没有任何 Runtime 能满足的 SDK,
症状只有启动那一刻的一句 `domain SDK runtimeext contract hash mismatch`。

**这是我的判断失误,证据当时就在手上。** 开跑前 `go test ./...` 有两个失败,其中一个直接打印了
`runtimeext-v34/d7d20947…` —— 正是后来杀死这一轮的哈希。我把它判成"上游 main 坏了、只影响文件能力 codegen",
写进分析计划的"嫌疑变量"就开跑了。既不是上游坏了(拉一下就好),也不局限于文件能力。

已修:检出更新,重新打包;**打包时比对两边哈希,不一致直接拒绝并给出修复命令**(提交 1da5de4,反例验证过)。

### 歪斜二:交付物仍在登录体里发 `application_key`,而 Runtime 已经拒收

我自己复验:带该字段 → `400 backend.invalid_json`;不带 → `403 auth.invalid_credentials`(进到凭据校验)。
方向确认:项目 Runtime 自己从 `IDENTITY_AUDIENCE` 解析 Identity 受众(`identity_integration.go:21`)。
三处交付物还在发:交付的 `@domainry/identity-client`、接口验收 harness 模板的两个登录点、
实现包的 `verification.auth.login_fields`;`static-product-ui` 的交接文档还反过来要求产品必须发。
全部已修(提交 373176d),并解包 `domainry-frontend-product_0.3.74.tar.gz` 核对登录体里确实没有了。

### 本轮从代理报告里采纳的四条修复(提交 999cd1b)

- **链式加载的页面会骗过验收的"空闲"判断**:`/my-orders` 先解析登录者档案、再查该维修工的看板,
  两步之间没有 busy,于是"等 busy 消失"这一次就返回,取样到空列表 —— 而真实用户也会先看到
  "暂时没有指派给你的工单"。现在等到安静后**再看一眼**才认(helpers 的 `quiesce` 与 quality 的 `settle`)。
- **`dev-runtime.sh ia` 进入 finalize 之前的必做清单**:编译什么证据都不证明,而 finalize 之后每修一个用例
  都要重走整套 focused/compile/finalize。它在这一轮里自己付清了两次。
- **跨版本 `frontend install` 的拒绝不给修复动作**,现在写明:挪走 `frontend/domainry`、重装、重链依赖、
  并删掉 `frontend/node_modules/.vite` —— 那个预打包缓存会让重装后的新客户端静默不生效,
  源码 grep 看着是对的,浏览器里还在发旧字段,极易误判成"平台没修好"。
- **Runtime 输入校验先于 Handler**:声明契约已经守住的字段,Handler 自己的 `*_required` 码永远到不了网线上
  (空白必填文本是 `backend.validation.required`)。写进契约阶段那份 Runtime 事实清单。

## mini-14(需求 A 请假审批,0.3.75 + runtimeext `9d2996b3…`,2026-09-12 20:47–22:17)

**92.2 min / 108.8 M ctx / 474 次调用 / 627 KB 文档 / 12 个接口。**
对照 mini-12(需求 A 至今最快):67.9 / 87.1 / 405 / 1032 / 11。**慢了 24.3 min。**

独立 verify(全新数据库,我自己跑):backend IA **12/12 initial + 12/12 restart**,
runtime 浏览器 **10/10**,**同一个库再跑一次仍 10/10**,mock **10/10**,theme `passed`。
断言一条没动过。

### 阶段对照(两轮都用同一个剖析器)

| 阶段 | mini-12 | mini-14 | 差 |
|---|---|---|---|
| 契约 | 7.1 | 7.9 | +0.8 |
| 前端 | 24.0 | 24.6 | +0.6 |
| **后端** | **22.9** | **37.9** | **+15.0** |
| **runtime 验收** | **9.1** | **16.8** | **+7.7** |
| 收尾 | 2.7 | 3.5 | +0.8 |

**契约与前端持平 —— 这一轮变慢的全部在后端与 runtime 两段。**

### 四条预注册判定的结果

**1. 总时长 > 75,按规则先查 runtime 段有没有回涨:涨了(9.1 → 16.8),但更大的一块在后端。** 见下。

**2. runtime 验收 16.8,落在"指认是哪一次失败"的 10–20 带。**
失败是登录后的过渡路由:产品先跳 `/`(决策点)再跳 `/change-password`,
而测试助手把"离开 `/login`"当成已落地,于是跳过了强制改密,之后每条断言都在等超时。
**但真正值钱的不是这条失败,是它的单价** —— 见下面那节。

**3. 文档读入 627 KB(mini-12 是 1032 KB),`builder-v1/SKILL.md` 在本轮的读取清单里根本没出现**
(mini-12 读了 6 次,34 KB/次)。导航角色菜单义务从 SKILL.md 正文挪进实现包的
`before_finalize` 这条**决定性生效**,这一类结案。

**4. `before_finalize` 里新增的 `ia` 被照做了:** finalize 之前跑过,finalize 之后没有因为用例问题返工。

### 本轮最有价值的一条:会话准备的失败单价是普通断言失败的 7 倍

对齐两轮的 stage-log,同一件事看得很清楚:

| | mini-12 的三次 runtime ui-check | mini-14 的两次 |
|---|---|---|
| 每次耗时 | 80 s(失败)/ 93 s(失败)/ 61 s(通过) | **569 s(失败)** / 132 s(通过) |

mini-12 的失败是**普通断言失败**(驳回后行状态没刷新):断言立刻判假,几秒结束。
mini-14 的失败在 **`prepareSession`**:会话没准备好,于是**每一条 spec 都各自等满 120 s 的 test timeout**,
12 条并行跑下来就是 569 s。**一个登录路径的缺陷,代价比任何别的缺陷高一个数量级,
因为它的失败形态是"等",不是"判假"。**

我 53e8125 为这条加的是 `prepareSession` 里的一句注释(要等会话真正落定的路由,
而不是只等"离开 `/login`")。注释在 TODO 骨架里,只劝,不拦。
**下一轮的减法目标就是把这种"等"变成"判假"**:给骨架一个有界的
`awaitAuthenticatedRoute(page, routes, {timeout})`,超时就抛出点名当前卡在哪条路由、
以及三个候选原因的错误。12 条 spec × 120 s 会变成 12 × ~15 s,
而且抛出的那句话,正是代理在 22:09 花两次 `sed` 读 helpers.ts 才自己想明白的东西。

### 后端段 +15 min:一次 backend-check 占掉 13.6 min,其中有我可以省掉的部分

backend-check 21:45:34 发起,21:59:10 拿到结果。12 个 FAPI × 两个 phase 的真实
Runtime 验收本身就重(mini-12 是 11 个 FAPI、162 s),但这中间有 **6 次纯轮询调用**
(`ps aux | grep -c`、`wc -c` 输出文件、两次 `date -u; ps -eo etime`、一次 `echo waiting-for-backend-check`),
才终于改用 `tail -f --pid` 阻塞等待。这 6 次不产出任何信息,也不缩短等待。

### 本轮修复的平台缺陷

**叶子层的拒绝被发布成 500(runtime,本轮末尾自查发现,不是代理报的)。**
`GET /records/<object>?filters={"not_a_field":"x"}` 应当是 400
`backend.validation.filter_field_unknown` 并点名那个键,实测是
**500 `backend.internal`,`params: null`**,键被丢掉了。

原因链是完整的:foundation 把 `apperror.CodedError` 定义为"叶子边界上不带 kind 的稳定客户码,
由 Application 层赋予 kind";而 `apperror.KindOf` 对任何不是 `*AppError` 的错误一律回答
`KindInternal` —— `application/` 与 `transport/` 里**没有任何一处**做那个映射。
于是过滤校验的拒绝一路裸奔到 HTTP 边界,被默认成服务器故障。

**我上一轮(e9bf871)修错了位置。** 那次改的是 `recordInternalError`(仓储分支),
而过滤校验在仓储调用**之前**就返回了,根本走不到那个函数。
我当时没有端到端验证,是这一轮补做的探针把它证伪的。

现修:`recordClassifyLeafRefusal` 在拒绝被抛出的地方给它 kind —— 已带 kind 的错误原样透传
(策略拒绝仍是 403,不会被改写成 400),不是编码拒绝的真实故障也原样透传(仍是 500)。
并加了一条走真实路由、真实装配、真实库的端到端测试
(`TestRuntimeUnknownListFilterIsABadRequest`),**撤掉修复反向验证过它会以那句一模一样的 500 失败。**

**顺带记一条工作方法的教训:** 交付项目的 `backend/go.mod` 依赖的是**已发布的** runtime 版本
(`v0.0.0-source-326a5fa4…`),不是我的本机检出。所以任何本机 runtime 改动都不会在
交付项目的 dev-runtime 上显形 —— 想端到端验证 runtime 修复,要么发版,
要么在 runtime 仓库里用 `bootstrap/integrationtest` 的真实装配验。这一轮用的是后者。

## mini-15(需求 B 设备报修,0.3.77 + runtimeext `a69b96a5…`,2026-09-12 23:36–01:00)

**81.2 min / 115.9 M ctx / 500 次调用 / 822 KB 文档 / 9 个接口。**
需求 B 唯一对照是 mini-11(143.1 / 167.5 / 1132 / 11 个接口;mini-13 作废),**快了 61.9 min**。
基线弱,所以逐段对齐:

| 阶段 | mini-11 | mini-15 |
|---|---|---|
| 契约 | 6.7 | 7.5 |
| 前端 | 30.9 | 21.9 |
| 后端(含反复 check) | ~60 | 27.7 |
| runtime 验收 | 11.2 | 5.5 |

独立 verify(全新数据库,我自己跑):backend IA **9/9 initial + 9/9 restart**(各 28 s,evidence=ok),
runtime 浏览器 **10/10**(302 s),**同一个库再跑一次仍 10/10**(298 s),mock **10/10**(60 s),
theme 与 source_audit 均 `passed`,`project check --scope all` = `valid`。断言一条没动过。

### 预注册判定的结果:主判定不成立,不得宣称生效

**1. 主判定(runtime 段第一次会话准备失败的耗时 < 150 s)——本轮 runtime 段根本没出现会话准备类失败**
(ui-check runtime 一次通过,301 s)。按开跑前写死的规则:**本判定不成立,顺延到下一轮。**

有一个相关但不能当作证据的数据点:mock 阶段第一次失败 19 s,原因是
**代理把脚手架自带的 `awaitAuthenticatedRoute` 连同 TODO 区域一起删了**,10 条全部 `ReferenceError`。
它恢复之后 `prepareSession` 确实以它收尾(`await awaitAuthenticatedRoute(page, LANDING_ROUTES)`)—— 被采纳了,但没被考到。

**2. 总时长 81.2 < 110:记录,不据此下结论**(基线只有 mini-11 一轮,且那一轮本身是灾难轮)。

**3. 纯轮询判定:触发得非常彻底 —— 68 次。** 阈值是 4。

### 本轮最有价值的一条:runtime 段 5.5 min 却烧掉 29.9 M 上下文

runtime 段只有 5.5 分钟墙钟,却有 **119 次调用、29.9 M 上下文** —— 逼近后端段 27.7 min 的 42.1 M。
其中约 60 次集中在 76–78 分钟之间,**每三秒一次 `date -u; grep -c http_request …`**,
只为等一次它自己放到后台的 ui-check。**一秒都没缩短,却比那一段所有真实工作还贵。**

这是"时间"与"上下文"两个指标第一次明显分叉:光看墙钟,runtime 段是历史最好的一次;
看上下文,它是这一轮第二贵的一段。

### 又一次"失败的形态是等":736 s 的 mock 失败

产品外壳里 `a[href="/"]` 出现两次(窄屏头部 + 侧边栏),`readback` 的 `.first()` 在桌面视口下
点到了 `lg:hidden` 的那一个。点击没有导航,于是 PB:2~7 六条各等满 120 s。

根因不在产品,在生成的 Playwright 配置:**`actionTimeout` 没有设置,Playwright 自己的默认值是 0 ——
动作永远等下去,只有 120 s 的 test timeout 能结束它。** 于是任何一次点不动的点击都等于两分钟静默,
而且输出里没有任何一句指向那个元素。

已修(提交 a6eaf6c):`actionTimeout: 15_000` + `navigationTimeout: 30_000`;`readback` 改点
`a[href="…"]:visible`。**用一张带隐藏孪生元素的页面实测:裸 `.first()` 现在 15,009 ms 失败并点名可见性**
(此前是等满 test timeout);`:visible` 在同一张页面上只命中 1 个。
把新配置套回本轮交付的产品跑,10 条浏览器用例仍然全过。

### 同一次提交里修掉的另外两条

- **`awaitAuthenticatedRoute` 放错了位置**:上一轮我把它放在 `TODO(scaffold): product accounts`
  标记**下面**,正是实现者会整段覆盖的区域。挪到 `quiesce` 与 `readback` 旁边 —— 那是本就该留存的一组助手。
- **两个长任务阶段的指引现在写明**:这些检查跑几分钟并把进度打到 stderr,请前台跑;
  真要放后台,就用一次阻塞等待,不要轮询。

### 代理报告里值得单独记的两条

- **`generate-acceptance-skeletons.py` 生成的"该被拒绝的角色"注释是错的**:它给每个 role_scoped 行
  都写 "sign in as the Role this row must refuse (technician)",而 `work_order.start/finish`
  恰恰只有 technician 有授权、该被拒的是 dispatcher。照抄必错,只能回模型里数 Role 授权。**未修,记下一轮。**
- **`verification.md` 的 "Runtime behaviour facts" 让 9 个接口用例两个阶段一次通过、零修复轮。**
  这是目前性价比最高的一节文档 —— 减法要绕开它。

## mini-16(需求 A 请假审批,0.3.78 + runtimeext `a69b96a5…`,2026-09-13 01:31–02:47)

**76.5 min / 100.3 M ctx / 450 次调用 / 1172 KB 文档 / 11 个接口。**
需求 A 对照:mini-12 **67.9 / 87.1 / 405 / 1032 / 11**(至今最快),mini-14 **92.2 / 108.8 / 474 / 627 / 12**。
**比 mini-14 快 15.7 min,比 mini-12 慢 8.6 min。**

独立 verify(全新数据库,我自己跑):backend IA **11/11 initial + 11/11 restart**(各 36.5 s,evidence=ok),
runtime 浏览器 **10/10**(73 s),**同一个库再跑一次仍 10/10**(75 s),mock **10/10**(33 s),
theme 与 source_audit 均 `passed`。断言一条没动过。

### 预注册判定:上下文那条赢得非常干净

**1. 纯轮询调用数:68 → 1。** 阈值是 ≤ 4。而且那唯一一次是 `ss -ltnp | grep 5484` 的端口排查,不是等待循环;
**全程没有把任何检查放到后台**,完全照着"前台跑、读 stderr"执行。

**2. runtime 验收段上下文:29.9 M / 119 次 → 6.8 M / 33 次**(阈值 < 12 M),墙钟 5.5 → 4.7 min。
**上一轮"墙钟最好、上下文第二贵"的分叉被消掉了。**

**3. ui-check 失败形态:不成立,不得宣称生效。** 本轮唯一一次 runtime 失败是 111 s,在 180 s 阈值内,
但它是一次**普通断言失败**(跨用例数据污染 + 审批页没渲染读取失败),根本没走到动作超时那条路径。
可以记下的旁证:**本轮没有任何一条用例撞上 120 s test timeout**,而 mini-15 有六条、mini-14 有十二条;
最慢的一次失败 111 s,对照 736 s / 569 s。**与预期一致,但不是证明。**

**4. `awaitAuthenticatedRoute` 活到了验收:** 交付的 helpers.ts 里在,`prepareSession` 两处以它收尾。
位置问题解决。**额外的信号:代理把 `:visible` 这个写法推广到了自己的代码里**
(`a[href="/members"]:visible`、`[data-sign-out]:visible`、`[data-nav-toggle]:visible`),
说明这条约定被理解成了规则而不是一次性修补。

**5. 总时长慢于 mini-12 8.6 min,上下文多 13.2 M。** 文档读入 1032 → **1172 KB**,是 mini-10 以来最高。
契约段一段就读了 536 KB。下一轮的减法目标在这里。

### 本轮修复的平台缺陷:一句写反的规则,值一整轮模型演进

`contract-stage.md` 写着:写关系字段时"把 Action 放宽到 `;all` 没有用 —— 缺的是 `<target>.read`"。
代理严格照办,给 `member` 配了 `member_profile.read;org`,然后六个用例齐刷刷挂在
`403 backend.record.outside_scope`,而同一个成员在同一个 Runtime 上**既能列出也能 Get 该档案**。

我自己追到源码确认,**事实与文档相反**:
`record_query_policy_domain_wiring.go:98` 的 `relationReadEffectPrincipal` 在 Action 声明了对目标 Object 的
read effect 时(Handler 只要读那个 Object 就会声明),调用
`identitysdk.DeriveExecutionAccess`;而 `deriveExecutionDataPolicies`
**先丢掉 `(target, read)` 的全部 Allow 数据策略,再把 Action 自己的数据策略投影上去**。
于是 `member_profile.read;org` 在那条路径上是**惰性的**,真正决定可见性的是
`leave_request.submit` 的 scope —— 放宽 Action 才有用,放宽读授权没有用。
只有 Action **没有**声明该 Object 的 read effect 时,目标自己的 scope 才说了算,那才是原文描述的情形。

已修(提交 9030a7c):两个分支都写下来,并写明各自适用的条件。

同一提交里修掉验收骨架生成器的两处误导:
- **"该被拒绝的角色"是靠 `roles[1:]` 猜的**,而这个列表并不按授权排序 —— mini-15 那轮它把**唯一有授权**的角色
  指成了该被拒的角色。现在它列出声明的角色、明说这个列表回答不了这个问题、并指向 `backend/model`。
- **头注释承诺"Handler 发布的拒绝码"却没说 Runtime 输入校验在前**:空必填文本永远是
  `backend.validation.required`,Handler 自己的 `<object>.<field>_required` 到不了网线上。
  连着两轮(mini-15、mini-16)各踩一次。
  **用交付项目的 inventory 在临时副本里重新生成全部 11 个骨架验证:gofmt 干净、`go vet` 通过、两处新注释都在。**

### 代理报告里记下但未修的三条

- **`|` 会静默吃掉内容**:`lifecycle-todo.md` 的 Notes 和 `prd-from-plan.py` 生成的 PRD 表格,
  都把用户内容直接拼进 markdown 表格且不转义管道符 —— 字段 DSL 里的
  `select![annual:年假|sick:病假]` 把 10 格表头撑成 14 格,Notes 里的 `pending->approved|rejected` 整条消失。
  **同一类 bug 至少两处,下一轮修。**
- **`prd-from-plan.py` 把每一条路由都标成 `frontend_only`**(mini-14/15/16 连着三轮都要手改),
  照单全收的话 inventory 分母会是 0。
- **mock 验收作为后端阶段的授权门,结构上盖不住它要授权的风险**:本轮 runtime 的两个失败
  (跨用例数据污染、读取失败未渲染)在 mock 里**原理上不可能出现**。代理提了两条可静态检查的规则,值得评估。

## mini-17(需求 B 设备报修,0.3.79 + runtimeext `a69b96a5…`,2026-09-13 03:11–04:34)

**85.7 min / 108.3 M ctx / 455 次调用 / 577 KB 文档 / 10 个接口。**
对照 mini-15(需求 B):81.2 / 115.9 / 500 / 822 / 9。
**慢 4.5 min,上下文少 7.6 M,调用少 45 次,文档少 245 KB。**

独立 verify(全新数据库,我自己跑):backend IA **10/10 initial + 10/10 restart**(各 42.2 s,evidence=ok),
runtime 浏览器 **11/11**(162 s),**同一个库再跑一次仍 11/11**(152 s),mock **11/11**(31 s),
theme 与 source_audit 均 `passed`,`project check --scope all` = `valid`。断言一条没动过。

### 预注册判定

**1. 关系授权返工:没有发生(全程零次 `outside_scope`,只调用了一次 `apply-model.sh`)。
但本轮不能算作证明。** 模型里确实有跨 Object 的关系写入(`work_order.assignee -> technician`),
可这个产品的调度员天然需要 `;all`(`work_order.register;all`),而 mini-16 的失败需要一个**更窄**的
Action scope 才会触发。**改正后的规则没有被考到** —— 与"文档修对了"一致,但区分不开"这个产品根本不需要窄 scope"。

**2. Handler 拒绝码:生效。** 零次 `expected code "<object>.<field>_required", got …` 返工,
交付的用例直接用 `backend.validation.required`。
一个观察(非弱化,但值得记):它写成了 `mustRejectAny(..., "backend.validation.required", "work_order.resolution_required")` ——
两个码任一都算过。下一轮考虑让骨架直接写死平台码。

**3. 纯轮询:68 → 1 → **0**;runtime 段上下文 29.9 M → 6.8 M → 9.3 M(阈值 12 M)。**这一类结案。**

**4. 文档读入 822 → 577 KB**(阈值 < 900),是 mini-14 以来最低。契约段 364 KB。

**本轮变慢的是前端段:21.9 → 31.5 min。** 代理连撞三次质量基线对比度失败,
三次都来自交付的 shadcn 原语而不是它自己的代码(`hover:bg-primary/90` 半透明 + 质量核向上找到第一个
alpha ≥ 0.95 的祖先 = 白底测白字;`bg-sidebar-background` 根本不是生成的 Tailwind 类;
`sheet.tsx` 关闭按钮 1.01)。**这是下一轮的归因目标。**

### 本轮修复的五条(提交 1b5ab4e),四条是"报告了系统并不具备的状态"

- **`dev-runtime.sh ia` 为 `verify` 会拒绝的证据打绿灯。** verify 要求每个接口**恰好一个** check 的
  operation 等于 inventory 行的 `runtime_operation`,而 `ia` 只检查"至少一个";harness 注释也写成了下限。
  代理照读为下限,给每个接口加了第二个 check 放次要断言,`ia` 十个全绿 `evidence=ok`,
  `backend-check` 随后拒绝,**赔掉一整轮 focused/compile/finalize/backend-check**。
  `ia` 现在用同一条规则,并写明替代做法。**用漏过去的那个证据形状做了单元验证,合法证据零问题。**
- **`ui-check` 从项目根解析 `playwright`。** npm 会提升,所以一直没事;pnpm 不提升,
  **连着三轮**都撞 `Cannot find module 'playwright/package.json'`,每轮都手工加依赖,
  而且要**猜版本**去对上镜像里已有的浏览器(没有任何文档写这个映射)。
  改为经 `@playwright/test` 锚定解析 —— 它本来就依赖 `playwright` 并钉好了版本,无需猜也无需装。
  **把交付项目里手工加的那个依赖移开实测:旧写法抛错,新写法正常解析。**
- **backend-check 通过后不覆盖上一次失败的 summary**,而那正是所有报错信息指向的路径:
  绿了的一轮读起来仍是"失败在一个早已修好的错误上"。现在成功会覆盖。
- **两个 markdown 表读取端都不认自己写出端的转义。** `cell` 把值里的 `|` 写成 `\|`,
  PRD 校验器却按裸字符切 —— `select![low:a|medium:b]` 被报成"10 列表头下有 12 格",
  输出是对的、抱怨是假的,而一位代理照着假抱怨手工改了行。
  `lifecycle-todo.md` 是同一个 bug 的更糟版本:行宽校验不过,**整条手写 Notes 在下一次 render 时被静默丢弃**,
  一个 `pending->approved|rejected` 就够了。两处都改为按转义切分。
  **验证:失败的那行 DSL 现在零问题,真正列数不符的表仍被抓到,Notes 带 `|` 往返一致。**
- **`backend-model.md` 要求生成序列号的 Handler 声明 `deletion_record: ["list"]` 并从中读被清理的号段。**
  `handler.data_access` 只能命名本模型声明的 Object,所以必然
  `model.action_data_object_not_found`;而且整个 Runtime 里**根本不存在** `deletion_record` 这个概念,
  没有任何审计面可读。现在改为从存活行取 `max(suffix)+1`、写明为什么计数法仍然错、
  以及产品若真有硬删除就给序列号自己一个 Object(那是可声明的)。

### 代理报告里记下但未修的

- **Runtime 在 `--fresh` 工作区里种了一条示例记录**进项目自己的 Object
  (`Technician Display Label`,electrician),会出现在花名册和周报里;mock 模式永远看不到它。
  它那个不可断行的英文长名正是 390 px 质量基线溢出的触发器(真正的缺陷是代理自己的
  `Card` 栅格项默认 `min-width:auto`,但触发器来自没有文档的种子数据)。
- **`prd-from-plan.py` 把 Report 支撑的路由判成 `frontend_only`、backend operations 写 "none",
  并整条漏掉 `/my-orders`** —— 连着四轮都要手改 disposition。
- **`prepareSession` 只为"你会登录成"的账号做登记**,而 helpers 的契约要求"包括只被指派工作的账号";
  差额表现为一次不透明的 Playwright 超时。代理自己导出了 `ensureTechnicianAccount` 补上。

## mini-18(需求 A 请假审批,0.3.80 + runtimeext `a69b96a5…`,2026-09-13 04:59–06:05)

**70.2 min / 99.4 M ctx / 438 次调用 / 1146 KB 文档 / 11 个接口。**
需求 A 序列:mini-12 **67.9 / 87.1 / 405 / 1032**(最快)→ mini-14 92.2 / 108.8 → mini-16 76.5 / 100.3
→ **mini-18 70.2 / 99.4**。**第二快,仍比 mini-12 慢 2.3 min、上下文多 12.3 M。**

阶段对照 mini-12 → mini-18:契约 7.1 → **7.0**;前端 24.0 → 26.3;后端 22.9 → 24.9;
**runtime 验收 9.1 → 2.9**(压得最狠的一段);收尾 2.7 → 3.8。

### 独立 verify:**这一轮没有全绿 —— 复用库重跑不稳定**

我自己在全新数据库上跑:backend IA **11/11 initial + 11/11 restart**(各 32 s,evidence=ok),
runtime 浏览器**全新库 10/10**(92 s),mock **10/10**(28 s),theme 与 source_audit `passed`。

**但同一个库重跑:run2 失败、run3 通过、run4 失败(3 个用例)。约一半概率。**
代理自己那轮通过,是因为运气好。

追因(我查了库里的行,不是采信报告):`periodFor(label, monthOffset, span)` 把 nonce 哈希成
**某个固定月份里的一天**,再取 3 天区间。run1 的 `pb3` 占了 2026-12-07→09,
run2 的哈希落进同一个十二月并与之重叠,被产品自己的重叠规则拒掉 —— 提交没落地,断言自然数不到行。
`pb5`/`pb6` 同理。**月份是按用例写死的,只有日在变**,所以两次 run 抢同一个月的日子。

这是 Skill 规则的缺口,不只是这次交付的 bug:nonce 规则要求"有争议的业务键从 nonce 派生",
交付**照做了**,但派生进了一个小到会撞的值域。已修(提交 652e0aa):
**派生是必要不充分条件 —— 派生出的值必须落在大到两次 run 不会相遇的空间里**,并把这次失败写进规则。

### 预注册判定

**1. playwright 依赖:**否**,连续第四轮撞上。** 上一轮我只修了 runner 的解析路径,
而生成的 TypeScript 里还有 `import type { Locator, Page } from 'playwright'` ——
pnpm 不把 `playwright` 提到项目根,裸 specifier 解析不到。
已修:helpers 从 `@playwright/test` 取类型并再导出,两个 spec 模板从 helpers 取,
这样 spec 里不出现任何 Playwright 模块名,fixture 守卫不受影响。
**把交付项目里手工加的包移开实测:旧写法 TS2307,新写法三个模板全部类型检查通过。**

**2. `ia` 证据形状:不成立,顺延。** 本轮两次 `ia` 失败都不是证据形状问题
(一次重复邮箱的 params 键,一次必填校验 trim),没有出现多 check 的写法。

**3. 前端段 26.3 min**(mini-15 21.9 / mini-16 24.6 / mini-17 31.5),落在 25–28 之间,
两条阈值都没踩到。如实记录,不下结论。

**4. 文档读入 1146 KB(阈值 ≥1100 要拆)。** 分布:契约段 472 KB、**后端段 575 KB**。
与 mini-16 不同 —— 那轮是契约段 536 KB 最大。**下一轮的减法目标是后端段。**

**5. 纯轮询 5 次**(mini-17 是 0,mini-16 是 1)。略有回涨但都是诊断式调用,不是等待循环。

### 本轮修复的三条文档错误 —— 每条都是我自己从决定它的源码里读出来的,不是照抄代理报告

- **`verification.md` 说重复邮箱带 `params.email`。** Identity 契约声明的是
  `ParameterKeys: ["actual"]`,实际回 `params.actual` 加一个被 Action 嵌套的 `field_path`。赔掉一轮 `ia`。
- **没有任何地方说必填校验会先 trim。** `RecordIsEmptyValue` 就是 `strings.TrimSpace(text) == ""`,
  所以只有空白的必填字段拿到的是平台的 `backend.validation.required`,
  而 Handler 自己的"空白"规则在 HTTP 面上**永远执行不到**。连着两轮把该码写进了验收用例。
- **`project-mutation.md` 说 `--scope actions` 看不见 navigation。** 它会组合整个项目,
  因此也会撞上 navigation 拒绝并报 `project.navigation_invalid` —— plane 自己的测试注释就是这么写的。

### 查证后未采纳的一条

代理报告称 `lifecycle-todo.md` 在 `done` 时渲染成空表、7 行需求与全部 Notes 一起消失。
**我看了交付的文件:7 行和全部 Notes 都在。** 复现不了,就不改 —— 表格行来自
`plan['requirements']` 而不是当前批次,`Current batch: -` 在 done 时本来就是正常的。

### 代理报告里记下但未修的

- **交付的 `@domainry/record-client` 的 `RecordActionResult` 契约与对象级 Action 的真实回执不符**:
  契约只声明 `record_id?` / `record?`,而 `POST /records/{obj}/actions/{key}` 返回的是
  `created_records[]`,d.ts 里没有这个字段。**mock 下看不出来**(Mock 的 `runObjectAction` 同样不返回引用),
  只在 runtime 验收才炸。代理用一次窄类型断言绕过。这条值得下一轮修。
- `prd-from-plan.py` 把 `authorization` 一律默认成 `role_scoped`,`auth.login`/`auth.logout` 实际是 `public`。

## mini-19(需求 B 设备报修,0.3.81 + runtimeext `a69b96a5…`,2026-09-13 06:32–07:49)

**80.5 min / 109.0 M ctx / 453 次调用 / 1121 KB 文档 / 11 个接口。**
需求 B 序列:mini-11 143.1 → mini-15 81.2/115.9/9 接口 → mini-17 85.7/108.3/10 接口 →
**mini-19 80.5/109.0/11 接口**。**需求 B 至今最快,而且接口数比前两轮都多。**

阶段:契约 7.7 / 前端 29.1 / 后端 28.4 / runtime 验收 9.2 / 收尾 3.4。

### 独立 verify:全绿,并且第一次按新口径连跑三次

backend IA **11/11 initial + 11/11 restart**(各 38.6 s,evidence=ok);
runtime 浏览器**全新库 10/10(131 s),同一个库再跑 10/10(120 s),第三次仍 10/10(122 s)**;
mock **10/10**(31 s),theme 与 source_audit `passed`,`project check --scope all` = `valid`。断言一条没动过。

**主判定(上一轮的质量失败)通过:连跑三次全过。** nonce 规则那条改动生效。

### 一次我自己的操作错误,记下来免得下次又当成交付缺陷

第一轮三次重跑全部 **0/10**,失败点都在登录按钮 disabled。
差点当成交付坏了 —— 读了错误才发现:**是我漏了 `PB_RUNTIME_WORKSPACE_ID`**,
而这个产品的 `runtimeConfigurationError()` 在缺工作区标识时会禁用登录提交。
Skill 的 runtime 阶段指引里本来就写了要带这个变量。补上后三次全过。
**教训:先读错误再下结论 —— 这次如果按"代理交付坏了"写进日志,就是一条错误的归因。**

### playwright 依赖:第五轮,这次找到了第三个也是最后一个点

前两次我修的是 runner 的 CLI 解析(0.3.78)和生成的 TypeScript 类型导入(0.3.81),
**漏掉的是 fixture shim 自己**:`createRequire(cwd/package.json)('playwright/test')`。
pnpm 不把 `playwright` 提到项目根,于是第一条用例还没跑就
`Cannot find module 'playwright/test'`,**连续五轮每轮手工装依赖**。

已修(提交 8ee64ed):把这个 require 锚定到 `@playwright/test`,specifier 保持不变
(仍是 CLI 加载的同一个模块),只是从包真正所在的位置解析。
**端到端验证:把交付项目根部的 `playwright` 移走,旧 shim 以那句一模一样的错误失败,
新 shim 拿到真正的 test/expect,整套 mock 10/10 通过 —— 项目根部完全没有 `playwright`。**

### 另外三条"靠实验才知道"的事实已写进文档

- **Object 的 `write_policy` 是编译出来的,不是写出来的**,而它决定 Runtime 会不会往这个对象里
  种一条基线行 —— 就是那条会污染报表和整页列表断言的幽灵行。
  `verification.md` 用一大段讲这条行的危害,却不说**怎么知道自己的对象是哪一类**。
  现在指向 `runtime-manifest.json` 的 `objects[].config.write_policy`。
  我自己核过:`technician_profile: direct_crud`、`work_order: action_only`,与代理的观察一致。
  代理称这是本轮最大的一次猜。
- **阅读计划把 `project-mutation.md` 归在 model 阶段**,但那份文件里装着实现阶段被打分的
  "project check source rules"(动作查询要字面量 page size、能力不跟随 helper 间接调用、
  条件写必须与守卫同体、import 白名单)。代理走到实现阶段手上没有这份清单,只好回头重读。
  现在它的 purpose 里写明这一点 —— 目的是**留住**那一节,而不是再读一遍。
- **导航目录的 marker 之间只能有 JSON 值本身**。代理把整个 `const NAVIGATION_CATALOG = {...}`
  包了进去(这是最自然的读法),拿到 `Unexpected token 'c', "const NAVI"...`。

### 代理报告里记下但未修的

- **`project.source_binary_float_forbidden` 与平台自己的代码生成冲突**:工时建模成 `number`,
  平台生成 `ActualHours float64`,而规则禁止业务源码出现 `float64` 标识符;
  文档给的唯一出路"整数分 + big.Rat"是金额方案,对非金额的 `number` 没有答案。
  **连着两轮(mini-15、mini-19)各自绕了一次。下一轮修。**
- **`verify` 之前同一套 11 个用例要跑三遍**(`ia` 一遍 + verify 的 initial/restart 各一遍),
  即使遵守了"不要在开发 Runtime 上重复跑完整 pass"。
- **`status.remaining_requirement_ids` 只在 done 时清空**,后端段结束时它仍列着全部需求,
  第一眼像"后端一条都没过"。

## mini-20(需求 A 请假审批,0.3.83 + runtimeext `a69b96a5…`,2026-09-13 08:42–10:08)

**85.9 min / 111.4 M ctx / 495 次调用 / 756 KB 文档 / 12 个接口。**
需求 A 序列:mini-12 **67.9 / 87.1** → mini-14 92.2 / 108.8 → mini-16 76.5 / 100.3 →
mini-18 70.2 / 99.4 → **mini-20 85.9 / 111.4**。**时间比上一轮 A 慢 22%,规则 6 判失败,规则 7 触发。**

阶段对照 mini-18 → mini-20:契约 7.0 → 10.2;前端 26.3 → 26.6;后端 24.9 → 25.3;
**runtime 验收 2.9 → 23.7**;收尾 3.8 → 3.7。**整个回退就是 runtime 验收这一段,其它三段几乎没动。**

### 独立 verify:全绿

backend IA **12/12 initial + 12/12 restart**(各 48 s,evidence=ok);
runtime 浏览器同一个库**连跑三次:10/10(132 s)、10/10(147 s)、10/10(146 s)**;
mock 10/10(29 s),theme 与 source_audit `passed`,`project check --scope all` = `valid`。

**主判定(规则 1,可重跑)通过 —— 这是 mini-18 失败的那条。** nonce 值域那条改动经住了第二轮需求 A。

### 规则 7:先查清楚,不是"为需求 B 过拟合"

查的结果:mini-19 改的四处(playwright shim、三条文档事实)没有一处碰到本轮慢的那一段。
runtime 验收的 23.7 min 花在**发现三件 Skill 从来没说过的事**上,而这三件都不是需求 B 带来的:

1. **写操作的 helper 在"点击"就返回了,不是在"完成"才返回。** 下一步导航把飞行中的请求打断,
   或者去重填一个正在被 resolve 的提交清空的表单 —— 记录悄悄没写进去,
   而失败出现在三个用例之后,离原因很远。本轮最贵的一次。
2. **id 升序 keyset 分页 ⇒ 新建的记录在最后一页的最后一行。** 五份文档讲分页,没有一份讲这个后果。
   于是队列用例在第 1 页找自己刚提交的行,**队列短的时候过,一旦前面的用例(或上一次 run)
   填满一页就挂** —— 这正是 mini-18 那个"跑一次过、重跑挂"的坑换了身衣服。
3. **一条永远不会失败的断言。** 用 `hasText` 传多行字符串去 filter 行,
   而 `innerText` 用制表符连接单元格,filter 永远匹配不到,`toHaveCount(0)` 一直白过。

**另外:mini-18 不是一个干净的时间基线。** 它 runtime 段只用 2.9 min,
部分原因正是它把一个潜伏缺陷发出去了 —— 那个缺陷是我的重跑检查抓出来的。
拿 85.9 直接对 70.2 并不公平:本轮多做了 12 个接口(mini-18 是 11),而且真的把上面三件事修对了。

三条都已写进 Skill(提交 1973d15),并按模板渲染进真实项目 tsconfig 做了类型检查,0 错误。

### 预注册判定

- **规则 1 可重跑:通过**(三次全绿,其中两次在复用库上)。
- **规则 2 playwright:实质通过,但我的规则写错了。**
  `Cannot find module 'playwright/test'` 这一类**六轮来第一次为 0** —— 三处 require 解析确实修干净了。
  但我把判定写成"全程不手工安装任何 playwright 包",而 **Skill 自己就要求
  交付去 pin `@playwright/test` 到与已装浏览器匹配的版本**。是我的判定条件写错了,不是交付的问题。
  真正剩下的小成本:handoff 说了"pin 到匹配版本"却没说怎么查,交付为此试了好几条命令。已补上那一条命令。
- **规则 3a 非金额 number:未被检验。** 本轮 `day_count` 是 `integer!;min=1`,模型里一个 `number` 字段都没有。
  记"未被检验",不记通过。
- **规则 3b PRD 路由表:通过。** 五条业务路由全部直接是 `backend_bound`,
  其中 Report 支撑的 `/summary` 正确绑到两个 report query,代理没有手改这张表。**修复第一轮就生效。**
- **规则 4a 导航 marker:通过。** transcript 里那两处"strict JSON"都是在读文档和读编译器源码,
  错误本身一次都没触发(mini-19 触发过)。
- **规则 4b write_policy:未被检验。** 三处 `runtime-manifest.json` 都是目录列表,代理没去查过基线行类别。
- **规则 4c project-mutation.md 不重读:通过**(全程只读一次)。
- **规则 5 上下文:一半。文档总量 1146 → 756 KB(降 34%),后端段 311 KB 远低于 550 阈值;
  但总 ctx 99.4 → 111.4 M 反而上去了。** 归因:契约/前端段读进了约 454 KB 的截图 PNG
  (`approvals.png` 199 KB、`summary.png` 100 KB、`approvals-mobile.png` 96 KB、`login-desktop.png` 59 KB),
  外加 runtime 段 5 次重跑。**下一轮盯这条:截图应当只看不进上下文,或者缩图。**
- **规则 6 时间:失败**(85.9 > 70.2)。
- **规则 7 反过拟合:触发,已查清,结论是"不是过拟合"**(见上)。

### 代理报告里值得记、但本轮没动的

- **Mock 证明不了什么。** `requirements.spec.ts` 里 `isRuntime` 分支出现 8 次(7 个需求用例),
  也就是大部分用例被写了两遍;交付的 Mock client 不建记录、Mock report 忽略参数/分页/scope。
  **本轮三个真缺陷全部活着穿过了绿的 mock 套件。**(我核过源码,不是采信报告。)
- 同一份需求句子被重打五遍;12 行接口清单有四份机器可读副本;每个拒绝码写在六个地方。
- `member_profile.enroll` 的 action context 说 Handler 没有任何对象能力(`"data_api": []`),
  而这个 Action 的全部目的就是建 `member_profile`;正确的 API 只出现在生成的 `.gen.go` 符号表里,
  散文文档把人往反方向指。
- 生成的骨架种子测试(`TestSubmitSeedFailsClosed` 断言 `not_implemented`)与实现完的 Handler 必然冲突,
  没有任何文档说该删。
- 失败的 `ui-check` 诊断会被下一次运行删掉,失败没有durable 回执(代理因此漏记了四条 check 行)。

### 平台线:上游 release 把两个 gate 弄红了,我修了

上游 `a275369`(发布 runtime v0.1.53)把编译能力注册表从 143579 涨到 150286 字节,
但没更新被钉住的审计分母,`capabilitysource` 三个守卫测试全红;
runtime 侧 `go.sum` 留了 6 个包的旧版本哈希,`verify_runtime_composition.sh` 直接失败。
**两个都先在上游 HEAD、不带我的提交的 worktree 里复现过,确认与本轮无关,然后才动手。**
守卫测试的用意就是"分母变了就得有人复核",所以我做了复核而不是改数字:
跨 release diff 编译注册表,**新增的恰好是 agent 模块下一个新类目 `agent.collaboration`,带 13 个操作**
(agents / delegations / decisions / deliveries / disagreements / messages / requirements 这些路由),
没有删除项,没有既有类目的操作数变化 —— 正好解释 64→65 与 386→399,
而且 13 个全是 authenticated,正好解释 378→391,anonymous 与 signed 各 4 不变。
提交 57a6e0c(plane)、5e8d594(runtime)。

## mini-21(需求 B 设备报修,0.3.86 + runtimeext `a69b96a5…`,2026-09-13 10:59–12:10)

**70.5 min / 92.0 M ctx / 398 次调用 / 931 KB 文档 / 9 个接口 / 11 个浏览器用例。**
需求 B:mini-11 143.1 → mini-15 81.2/115.9/9 → mini-17 85.7/108.3/10 → mini-19 80.5/109.0/11 →
**mini-21 70.5/92.0/9**。

**上下文 109.0 → 92.0 M,降 15.6%,是 B 系列最低;文档 1121 → 931 KB。**
阶段:契约 9.5(其中 `freeze` 被拒回环一次)/ 前端 27.6 / reopen 回环 2.2 / 后端 24.9 / **runtime 验收 6.1**。

### 独立 verify:全绿

backend IA **9/9 initial + 9/9 restart**(各 34 s,evidence=ok);
runtime 同一个库**连跑三次:11/11(73 s)、11/11(69 s)、11/11(70 s)**;
mock 11/11(39 s),theme 与 source_audit `passed`,`project check --scope all` = `valid`。
**浏览器一轮 70 s,mini-20 是 132–147 s。**

### 规则 7(接口数归一)必须先说,否则会得出错误结论

**本轮 9 个接口,mini-19 是 11 个。**按接口归一:
mini-19 = 7.3 min/接口、9.9 M/接口;**mini-21 = 7.8 min/接口、10.2 M/接口 —— 每接口反而略差。**
所以"B 系列最快"这个说法只在绝对值上成立。**这正是我预注册规则 7 的原因,mini-20 就是被 12 对 11 误导过一次。**
唯一可以无条件说的是上下文那条:92.0 M 是 B 系列最低,而截图归零(见规则 3)与它直接相关。

### 预注册判定

- **规则 1 可重跑:通过**(三次 11/11,两次在复用库上)。
- **规则 2a 写完成 / 2b 最后一页:本轮没有发生这两类失败,但也无法证明是规则挡住的。** 记"未发生",不记通过。
- **规则 2c 白过的断言:通过(我自己读的交付 spec,没采信报告)。**
  所有 `toHaveCount(0)` 都针对 `data-*` 稳定属性,**而且每一条都有正向对照**
  (board/technicians/weekly-stats 对经理 `toBeVisible`、对维修工 `toHaveCount(0)`,my-orders 反过来);
  唯一的 `hasText` 传的是单行 nonce。正是"先让它失败一次"那条要的形状。
- **规则 3 截图:通过,而且是压倒性的。本轮读进上下文的图片 0 KB(mini-20 是 454 KB)。**
- **规则 4 非金额 number:通过 —— mini-20"未被检验"的那条,这轮检验了。**
  5 次出现全部是**读文档**和代理自己的报告行文,**门禁一次都没被触发**;
  交付按文档的逃生路径做(类型推断 + `FormatFloat` + ×10 四舍五入判一位小数),没有为非金额 number 引入整数最小单位。
  我的规则写成"出现 ≤1 次"是个坏代理指标 —— 读文档恰恰是我希望它做的。
- **规则 5 PRD 路由表:失败,而且是我上一轮那个修复没想到的分支。** 见下。
- **规则 6 时间/上下文:时间 70.5 ≤ 80.5 通过,ctx 92.0 ≤ 109.0 通过 —— 但都要按规则 7 打折看。**
- **规则 8 mock 价值(只记录):**`isRuntime` 在 requirements.spec.ts 出现 9 次(mini-20 是 8 次)。
  连续两轮都是"大部分用例被写两遍"。**下一轮开始考虑动 mock 阶段。**

### 规则 5 失败的真相:冻结计划可以完全不声明 routes

mini-21 的 `batch-plan.json` 里 **`frontend.routes` 这个键根本不存在**,而 `freeze` 接受了。
于是路由表渲染成一个只有表头的空表,快照行写着 `(routes: none)` ——
**产品有 6 条路由,这是一句假话**,而且两处都没有 `AUTHOR` 标记,Confirmation 清单不会拦。
我 mini-20 的修复让"有 routes 时绑定正确"(那轮 5 条全对),**但没考虑过它可以没有**。
已修(提交 1b2296b):两处都改成要求作者填写,并说明"冻结计划没有声明 `frontend.routes`"。
加了回归测试并做了反向验证(旧代码下该测试失败)。

### 另外两条本轮换来的规则

- **浮点门禁同样读 Handler 的 `_test.go`,没有任何文档说过。**
  表驱动测试用 `[]float64{...}` 字面量,被当成生产源码一样拒绝。改成生成的输入类型即可。
- **Mock 从内存作答,Runtime 是一次网络往返。** 任何"请求之后立刻读状态"的断言在 Mock 永远过、在 Runtime 抢答。
  本轮唯一一次 runtime 失败(70 s)就是两条这种:打开下拉后立刻读 option;
  以及 `expect.poll(rows.count() > 0)` 在**上一个筛选条件的旧行**上抢答,随后读到上一位维修工的行。
  handoff 详细警告了 nonce 与跨运行留存,却从没警告这一类。
  已写进 helpers 模板,和另外两条"等待"规则放在一起,并给出这两个具体形状。

### 代理报告里记下、本轮未动的

- `freeze` 里 `source` 一词两义(需求出处 vs Runtime 界面),损失一轮。
- **前端调用点没绑定,只有后端阶段的 `prd-from-plan.py` 能发现**,`freeze` 和 mock ui-check 都放行,
  代价是 reopen→freeze→install→scaffold→mock 全链重跑(本轮 2.2 min)。**校验应前移到 `freeze`。**
- `navigation-role-menus.json` 的 schema 只存在于 SKILL.md 一行里,references 下 17 个文档都没有。
- 生成的 mutation/query 字段全非导出,单元测试无法断言"Handler 到底写了什么";
  同一 Action 家族里两个 Handler 的可断言强度因此不同(带 `time.Now()` 的那个只能靠接口验收读回)。
- `_ "time/tzdata"` 被 import 白名单禁止,与"禁止固定偏移"互顶,Handler 只能隐式依赖宿主 zoneinfo。
- records 列表 `filters` 的线格式没文档,代理靠读前端 record-client 源码才确定是扁平等值 map。
- `EnrollTargetOrganization.Resolve()` 该不该调仍无依据(mini-20 选择调用,mini-21 选择不调用,两轮都过)。

## mini-22(需求 A 请假审批,0.3.87 + runtimeext `a69b96a5…`,2026-09-13 12:35–13:39)

**63.7 min / 101.6 M ctx / 476 次调用 / 1326 KB 文档 / 11 个接口 / 10 个浏览器用例。**
需求 A:mini-12 67.9/87.1 → mini-14 92.2/108.8 → mini-16 76.5/100.3 → mini-18 70.2/99.4/11 →
mini-20 85.9/111.4/12 → **mini-22 63.7/101.6/11**。

**按规则 2 归一(接口数相同,11 对 11,可以直接比):**
对 mini-18:**时间 70.2 → 63.7(−9.3%)**,ctx 99.4 → 101.6(+2.2%)。
对 mini-20(12 接口):每接口 7.2 → **5.8 min**、9.3 → 9.2 M。
**这是需求 A 至今最快的一轮,比保持了 10 轮的 mini-12(67.9)还快 4.2 min。**

阶段:契约 6.5 / 前端 19.1 / 后端 28.7 / **重冻结回环 1.0** / 后端二轮 6.4 / runtime 验收 2.0 / 收尾 3.1。
**前端 19.1 min 是所有轮次最低**(mini-20 26.6、mini-21 27.6),mock 一次就过。

### 独立 verify:全绿

backend IA **11/11 initial + 11/11 restart**(各 33 s);
runtime 同一个库**连跑三次:10/10(75 s)、10/10(74 s)、10/10(73 s)**;
mock 10/10(27 s),`project check --scope all` = `valid`。

### 最重要的一条:**我自己写的那段文档是错的,而且它自称"这段最贵"**

`contract-stage.md` 里那段关系授权规则(我在 9030a7c 改的)写着:
Action 声明了对目标对象的读效果时,Runtime **不看**目标自己的读数据域,
会丢掉 `<target>.read` 的 Allow 策略并把 Action 自己的数据域投影上去 —— 所以"要放宽的是 Action,不是目标"。

**mini-22 照做,建模成 `member_profile.read;owner` + `leave_request.submit;org`,
11 个接口用例挂了 6 个**(`leave_request.member_profile_missing`);
**只把目标对象的读权限改成 `;org`(Action 一个字没动)就 11/11 全过。**

**我没有采信报告,自己去读了 runtime 源码:**
投影逻辑在 `relationReadEffectPrincipal`,**唯一的调用者是 `canAccessPersistedRecord`
→ `record_relation_validation.go`**,而且函数自己的注释就写着
"the derived principal is local to this check, so ordinary record browsing keeps the caller's scope"。
列表/取单路径(`NormalizeListQuery` / `CanAccessRecord`)根本拿不到这个投影。

**所以规则是真的,但作用域被我写宽了:它管的是"Handler 写关系字段时 Runtime 校验目标可读",
不管"Handler 自己 List/Get 目标对象"。后者走调用者自己的 `<target>.read`。**
而且失败长得不像授权问题 —— 读不到行,Handler 报的是业务拒绝而不是 403。

已改(提交 04e8f31),并写明它此前说反了、代价是多少。
另外补了一条让 `;owner` 显得更危险的事实:**身份交付 Action 建出来的档案行,owner 是执行交付的那个经理,
不是它描述的那个人**,所以 `;owner` 下成员连自己的档案都读不到。

**教训:一段自信写错的文档比没有这段更糟。**上一轮我刚因为"我的修复没考虑某个分支"栽过一次,
这轮是"我的修复把作用域写宽了"。两次都是我自己改的东西,两次都是下一轮的交付替我发现的。

### 其它三条本轮换来的(同一提交)

- **重复交付同一个人时,档案对象上的 unique 业务字段会抢在 Identity 之前拒绝**:
  同邮箱同 `display_name` 拿到的是 `backend.unique.field`(`params.field`),
  不是文档笃定写的 `backend.identity.user_email_exists` —— 后者只在"邮箱重复但业务字段不同"时出现。
- **报表分页是 `cursor`/`next_cursor`,不是记录列表的 `after_id`**;harness 的 helper 不传 cursor,
  要证"相邻两页不重不漏"只能自己包一层。**报表行还把列拆进 `dimensions`/`measures` 两个 map**,
  消费端两边都要查,前后端各写一遍。三条都没有任何文档写过,代理是去读路由分片的 schema 才知道的。
- **`field_permissions` 条目必须三个布尔齐全**(`read`/`write`/`export`),只写一个方向
  会让 `model plan` 第一轮直接吐 40 条 `schema.required`。

### 预注册判定

- **规则 1 可重跑:通过**(三次 10/10)。
- **规则 2 归一化:已执行**(见开头,11 对 11 可直接比)。
- **规则 3a 路由表:通过(有 routes 分支)。** 计划声明了 routes,PRD 52 个 AUTHOR 全是判断列,生成内容无误。
  0.3.87 的"没声明 routes"分支本轮未被触发,记未被检验。
- **规则 3b 浮点门禁覆盖 `_test.go`:未被检验**(本轮天数仍是 integer)。
- **规则 3c Mock/Runtime 异步:通过** —— runtime 段 2.0 min,一次过,没有出现抢答类失败。
- **规则 4 截图:通过**(profiler 里没有任何图片读取)。
- **规则 5 时间/上下文:时间通过且刷新纪录;ctx 101.6 略高于 mini-20 的每接口值以下、但绝对值未低于 mini-18。**
  文档读取 1326 KB 是近几轮最高(mini-21 是 931),主因是契约段 420 KB + 后端段 583 KB。
- **规则 6 mock 重复(第三次测量):形状没变。** 本轮真正的缺陷(数据域)是 `ia` 抓到的,mock 全绿放过。
  **连续三轮同一结论,下一轮开始动 mock 阶段的定位。**
- **规则 7 `freeze` 漏掉未绑定调用点:本轮没有因此回环**(回环是数据域引起的)。记未发生。

## mini-23(需求 B 设备报修,0.3.89 + runtimeext `a69b96a5…`,2026-09-13 14:03–15:10)

**67.0 min / 84.2 M ctx / 389 次调用 / 395 KB 文档 / 10 个接口 / 10 个浏览器用例。**
需求 B:mini-15 81.2/115.9/9 → mini-17 85.7/108.3/10 → mini-19 80.5/109.0/11 → mini-21 70.5/92.0/9 →
**mini-23 67.0/84.2/10**。

**按规则 2 归一:每接口 6.7 min / 8.42 M**(mini-21 是 7.8 / 10.2,mini-19 是 7.3 / 9.9)。
**绝对值和归一值同时是需求 B 最好的一轮。**

**文档读取 395 KB —— 全系列最大的一次下降**(mini-21 931、mini-22 1326)。规则 6 的 1000 KB 阈值大幅通过。

阶段:契约 10.9 / 前端 21.1 / 后端 26.0 / runtime 验收 9.0。

### 独立 verify:全绿

backend IA **10/10 initial + 10/10 restart**(各 39.5 s);
runtime 同一个库**连跑三次:10/10(192 s)、10/10(184 s)、10/10(187 s)**;
mock 10/10(35 s),`project check --scope all` = `valid`。

### 规则 3(mock 定位改动):**3a 失败、3c 通过 —— 而且代理的自述是错的**

代理报告说"只在两模式合法不同处分支,**共 4 处**"。**我自己数了交付的 spec:
`requirements.spec.ts` 8 处 + `journeys.ts` 2 处 ≈ 10 处**,mini-20 是 8、mini-21 是 9。
**分支数没有下降,规则 3a 判失败。**(又一次:凡是能自己数的,就别采信报告。)

**但 3c 通过,而且这才是关键。**我逐个读了这些分支:
现在绝大多数是 `if (isRuntime) { …强业务断言… }` **而且没有 else** ——
Runtime 分支承载业务 oracle,Mock 干脆不断这一段,**而不是另写一套弱断言**。
唯一带 else 的那处(197 行)也不是弱化断言,而是**建场差异**(Mock 客户端不落库,
所以改用场景里已指派的工单驱动)。Runtime 侧断的是
`data-status` 属性、处理结果原文、工时 1.5、完成后不再有任何操作入口、
以及另一名维修工队列里根本没有这张工单(行级数据域)。**没有一处被改成"只断 2xx"。**

**结论:0.3.89 改变了"弱的那一半在做什么"(从并行弱套件变成干脆不断),
但没有减少分支点本身 —— 因为只要用例要在两个模式下都能跑,分支点就还得在。**
真要降这块成本,杠杆不在 mock 断言,而在"用例是否必须同时服务两个模式"。**这条留给后续,不急着改。**

### 新发现:浏览器套件变贵了,而覆盖没变多

同一个需求 B,**runtime 一轮 70 s(mini-21)→ 190 s(mini-23)**,而用例数是 11 → 10。
代理自己的报告指向同一处:"215 s 里绝大部分是 Playwright 在重跑 FAPI 已证过的状态机"。
**我没有据此改东西** —— 手上只有墙钟数,没有逐用例分解(diagnose 输出只给总时长)。
已写进 mini-24 的预注册计划:**先把逐用例耗时量出来,再决定要不要动**。
上两轮的教训就是"自信写错的修复比不修更贵",这次先量。

### 预注册判定

- **规则 1 可重跑:通过**(三次 10/10)。
- **规则 2 归一化:已执行**(见开头)。
- **规则 3a 分支数下降:失败**(≈10,未降);**3b 前端 21.1 min**(mini-21 27.6、mini-22 19.1,居中);
  **3c 断言未被弱化:通过**(我自己逐条读的)。
- **规则 4 数据域改正:未被检验**(本轮没有出现放宽 Action 却无效的那轮返工)。
- **规则 5 时间/上下文:全部通过**,绝对值与每接口值都优于 mini-21。
- **规则 6 文档 ≤1000 KB:通过,395 KB。**
- **规则 7 两项未修项:`navigation-role-menus`/菜单 schema 第二次付出代价 → 已修;
  `freeze` 的 binding `source` 闭集第二次让人丢一轮 → 已修。**

### 本轮修掉的两条(提交 116b25f,均已第二次付出代价)

- **binding 的 `source` 与需求的 `source` 同名不同义**,前者是四个值的闭集
  (`runtime.action` / `runtime.identity` / `runtime.records` / `runtime.report`),
  而这个闭集**只出现在拒绝信息里**。mini-21 和 mini-23 各丢一轮 `freeze`。
  同一段还补上:**binding 的 `test_path` 是硬约束**(backend-check 要求测试就在那个文件里),
  而 SKILL 文本却在说"文件怎么拆好读就怎么拆",两句直接冲突。
- **导航目录的菜单条目是固定七字段**(`key/label/description/route/icon/parent_key/sort_order`),
  交付只能从 `menus[0] contains unknown field path` 反推;并写明 marker 之间那段
  **必须同时是合法 JSON 和合法 TypeScript**,这才是赋值语句要放在 start marker 之上的原因。

### 代理报告里记下、未动的

- `map[string]any` 被源码闸门禁,而 `BusinessError.Parameters` 是 `map[string]string` 这件事没有任何文档写过,
  代理只能去 Go module cache 里 grep 声明。
- `Page(1, 200)` 必须是**内联字面量**,具名常量不行 —— 未见于任何文档。
- `gofmt -l` 干净但 `project check` 报 `source_unformatted`(差异只是文件末尾空行),闸门更严但没说严在哪。
- 生成能力 `caps.X.Get` 对不存在的 id 会**自己先拒**,Handler 自己的 `not_found` 分支永远不可达。
- 会话类需求(登录/登出)与 nonce 规则冲突:两个路由只有 login 和 password,
  password 是机密不许塞 nonce。代价是一整轮 189 s 的 runtime ui-check。
- `_ "time/tzdata"` 被 import 白名单禁止,宿主无 zoneinfo 时 `LoadLocation` 静默回落 UTC,
  工单号可能发错业务日 —— 项目对此无法自我保障。

## mini-24(需求 A 请假审批,0.3.90 + runtimeext `a69b96a5…`,2026-09-13 15:34–17:07)

**93.1 min / 134.8 M ctx / 533 次调用 / 662 KB 文档 / 12 个接口 / 10 个浏览器用例。**
需求 A:mini-18 70.2/99.4/11 → mini-20 85.9/111.4/12 → mini-22 **63.7/101.6/11** → **mini-24 93.1/134.8/12**。
**每接口 7.8 min / 11.2 M**(mini-20 是 7.2/9.3,mini-22 是 5.8/9.2)。**本轮是需求 A 最差的一轮。**

三次 reopen + 两个 model 轮次;代理自己的归因:
"时间大头是**授权与时间戳这两个平台语义的试错**(两个 model 轮次 + 两次 runtime 失败 ≈ 25 分钟),不是写业务代码。"

### 独立 verify:全绿

backend IA **12/12 initial + 12/12 restart**(各 43.8 s);
runtime 同一个库**连跑三次:10/10(95 s)、10/10(92 s)、10/10(95 s)**;
mock 10/10(28 s),`project check --scope all` = `valid`。

### 那 25 分钟里,授权那一半是我自己造成的

代理报告说关系授权的数据域规则又错了 —— **而且方向和 mini-22 正好相反**:
mini-22 是"放宽 Action 没用,放宽目标对象才对";mini-24 是"放宽目标对象到 `;all` 没用
(12 个里 7 个仍红、报错一字不变),放宽 Action 才 12/12 全绿"。

**两边都对,是同一条规则的两面。** 我核过 mini-24 的模型:
`leave_request.submit` 的 `handler.access` 里有 `member_profile: ["list"]`,即声明了读效果,
于是 `ReadEffectAuthority` 命中:
- **写关系字段**(mini-24 的 `applicant`)走关系校验 → 投影 **Action 自己的**数据域 → 放宽 Action 才有用;
- **Handler 自己 List/Get 目标对象**(mini-22)→ 走**调用者自己的** `<target>.read` → 放宽目标才有用。

这正是我在 mini-22 之后写进 `contract-stage.md` 的那段话。**所以那次改正是对的 —— 错在我只发了一半。**
当时我扫的是 `references/*.md`,**漏了 `references/capabilities/`**,
`actions-and-transactions.md:258` 里那句老话原封不动地留着:
"Widening the Action from `;owner` to `;all` therefore does not fix it" ——
而它描述的恰恰就是关系校验那一面,是错的;`identity-handler-delivery.md` 又按引用复述了一遍。
代理读的正是这两份。

**代价:两个 model 轮次(plan + apply + compose + 重启 + 重跑验收)。**
已修(提交 b690024):两处都改成给出分支,并写明哪一侧该动哪个授权。

**教训升级:改正一条错误事实时,必须把同一条说法在整棵文档树里扫干净,包括子目录。**
这是连续第三轮由我自己的改动引出的问题(mini-21:修复没考虑某分支;mini-22:作用域写宽;mini-24:只发了一半)。

### 另一半:datetime 不归一化 UTC,静默吞行

生成的 mutation 把 `time.Time` 原样按 RFC3339Nano 交给 Runtime,Object SQL 按**字符串**比较。
Handler 按文档用 `ApplicationTimeZone()` 打戳 → 库里是 `2026-09-14T00:50:17+08:00`,
页面按 UTC 问 `...T23:59:59Z` → **当天所有行被排除,列表全空,而每个请求都是 200,没有任何报错。**
更值得记的是:**它自己的 12 个接口验收全绿也没发现**,因为时间窗开的是 ±48h,刚好把一个时区的误差吞掉。
已写进 `reports.md`(同一提交):datetime 一律 UTC 持久化,且时间窗用例的窗口要窄到
"一个时区大小的误差会落在窗外"。

### 预注册判定

- **规则 1 可重跑:通过**(三次 10/10)。
- **规则 2 归一化:已执行**(每接口 7.8 min / 11.2 M,需求 A 最差)。
- **规则 3 逐用例耗时:拿到了。** 最后一次通过的 runtime ui-check 共 91.6 s:
  static UI 质量基线 17.2 s、`[PB:5]` 14.4、`[PB:4]` 12.4、`[PB:6]` 11.5、`[PB:3]` 11.0、
  `[PB:1]` 7.2、`[PB:2]` 6.6、`[PB:7]` 6.2、runtime-identity 1.7、runtime-unavailable 1.5。
  **没有单个用例是异常值,时间是均匀摊在 7 个业务用例上的** —— 也就是说
  mini-23 那次 70 s → 190 s 不是某一个用例失控。**仍不动手,等 C 之后再看。**
  另记:`ui-check` **只在失败时**写 `pb-ui-check-summary.json`,通过时逐用例耗时只存在于
  `.domainry/development/evidence/000-runtime-*.json` 的 `report` 字段里。
- **规则 4 0.3.90 两条:4a binding `source`/`test_path` 通过**(本轮没因此丢轮次);
  **4b 导航七字段:部分未被检验**,但暴露了相邻的一个坑(见下)。
- **规则 5 mock 分支形状:通过**,没有出现弱化断言;两处测试修复都是"断言对象错了",改完更严。
- **规则 6 时间/上下文:全部失败**(93.1 > 63.7;134.8 > 101.6;文档 662 KB > 600 KB 阈值)。
- **规则 7 未修项再付代价:无新增**(本轮的代价来自我自己的半成品修复)。

### 记下、未修(等第二次代价)

- **骨架生成器漏生成一个 FAPI 的 stub**(12 行里生成 11 行),而它自己的 `--check` 事后又说
  "matches the inventory denominator: 12 row(s)"。不逐行核对 `inventory.json` 就会一直缺到 `verify` 才炸。
- **前端编译产物失效只有后端阶段才发现**:改了 `navigation.ts` 之后 mock 连过两轮无意见,
  到 `project check` 才报 `compiled project navigation source sha256 differs`;
  重编译又动了前端源码树,于是 `backend-check` 拒 `Acceptance source changed`,必须再跑一遍 mock。
  **这个环完全可以在 mock 阶段闭掉**(mock 已经在扫 `src` 做 identity audit)。
- `reopen` 之后 `record-skill` 与 `frontend-install` 的先后顺序无处可查,错了就一直失败;
  `reopen` 不接受 `--reason`,而文档到处让人"记录重开理由"。
- `handler.access` 的算子集合(`get`/`list`/`get_for_update`/`conditional_update`)没有任何枚举。
- Handler 单测无法断言 mutation 内容(字段未导出,唯一出路 `unsafe` 又在 import 黑名单里)。

## mini-25(**需求 C 供应商合同台账 —— 留出集**,0.3.91,2026-09-13 17:28–19:32)

**124.4 min / 17 个接口 / 11 个浏览器用例。这是第一个"没做完"的轮次,而这正是它的价值。**

设立目的见 `/tmp/mini25-analysis-plan.md`:A 和 B 的章节几乎逐条对应(登录/建账号/建记录/列表分页/
状态机/月度汇总/本地校验),**交替 A/B 只防住了拟合域名词,没防住拟合这一类产品**。
C 故意建在 `workflow` / `scheduler` / `in-app-notifications` / 离线导出这四块上 ——
**这四个词在前 12 轮的优化日志和四个交付模型里出现次数都是 0。**

### 结果

- 后端:**我自己在全新库上跑,17/17 initial + 17/17 restart,evidence=ok**(各 62 s)。接口数是 A/B 的 1.5 倍。
- 浏览器:**9 过 2 挂**,`terminal_state: not_done`,**没有 completion token**。
  两个失败同一个根因(离线导出),代理**没有**用前端合成 CSV 或假任务列表把它弄绿 —— 断言原样挂着。

### 规则 2:我写进 Skill 的规则,换个形状还成立吗 —— **成立,没有一条被推翻**

被检验且成立:playwright 依赖(零解析失败)、写完成才返回、不会失败的断言、Mock 同步 vs Runtime 异步
(**mock 一次就过,45 s**)、截图代价(零图片)、nonce 值域、binding `source` 闭集(代理明确引用了这条)、
`field_permissions` 三布尔、报表 dimensions/measures、非金额 number。
未被检验:最后一页分页(本产品队列不分页)、关系授权数据域(本轮没踩)。
**结论:12 条里 10 条在一个从没测过的形状上照样成立,0 条被推翻。**

### 规则 3:四块新能力面各有一个坑,而且都不是小坑

**(1) Workflow —— 平台要求的路径,产品根本驱动不了。**
文档(`workflow.md` + `contract-stage.md`)规定"任何人工 approve/reject 等待必须建 Workflow 节点",
但交付给产品的 `WorkflowClient` 公共契约**只有 `getProcessRoute` 和 `approveTask`** ——
没有待办列表,没有 reject。于是产品既列不出待审批、也驳回不了。
代理 `reopen` 回契约,改成 approve/decline 两个 Action,批准走一次 `ConditionalUpdateBatch`
(合同 `RequireExpiryDateEqual` + `WithExpectedUpdatedAt`,申请 `RequireRequestStateEqual(pending)`),
"决定前到期日一个字不变"因此仍然可证,PB:4 通过。
**换句话说:C 在这一点上被迫退化成了 A/B 的形状。**

**(2) Scheduler —— 租户角色拿不到任何调度权限,定时执行在验收窗口内不可观测。**
以工作区初始管理员身份:`GET /scheduler/definitions` 与 `/scheduler/state` 都是 `auth.permission_denied`,
`model plan` 里也没有可授权的 scheduler 权限键。定时任务定义保留了,但"08:00 会不会真的触发"**未被验证**。

**(3) 通知 —— 模板变量的类型契约完全没有文档,而错误体是空的。**
`date!` 变量用 `TimestampValue` 被拒:`400 backend.notification.template_variable_invalid`,
**`params: null`** —— 不说哪个变量、哪个字段、期望什么。正确写法是 `StringValue` + `YYYY-MM-DD`,
且同一变量只能设一个指针。两条都没有任何文档写过。
另有一处自相矛盾:packet 的 `evidence_contract.check.allowed_sources` **含** `runtime.notification`,
而 runner 的校验器拒绝它,只能退回 `runtime.records`。

**(4) 离线导出 —— 唯一没能交付的一块,而且我核到了平台缺陷的确切位置。**
代理报告三件事:prepare 的 `audit_id` 必须指向调用者自己已创建的审计行(两步协议,无文档);
`data_exchange.jobs.list` 这个 grant 文档里根本不存在;
以及**工作区里一旦有作业,`GET /data-exchange/jobs` 就 403 `backend.workspace_scope_required`**,
而角色语法里**没有** `workspace` 这个数据域取值(`model plan` 只接受 all/owner/org/org_child/target_org)。

**我自己复现并读了 runtime 源码,机制比"闭环矛盾"更具体:**
`GET /data-exchange/jobs` 空工作区返回 `200 {"items":[]}`(我实测);一旦有作业需要投影,
`report_export_data_exchange_provider.go:135` 调 `QueryScopeForPrincipal(principal)`,
而该函数在 `!principal.Known` 时直接报错 → 403。
构造这个 principal 的 `record_data_exchange_providers.go:106` 只填了
`WorkspaceID / UserID / RequestID`,**`Known` 只在 `p.resolve` 恰好设置时才为真**。
> **【2026-09-13 更正,见文末 D-07 更正条】这一句把缺陷点指错了。`p.resolve` 不是"恰好"设置的,
> 它在 `DataExchangeProviders != nil` 时必然被 `ConfigureResolver` 绑成 `ResolveBatchPrincipal`。
> 403 的链路我复核后确认成立,但 `Known:false` 的来源不在这两行。**
**所以这是作业投影路径上的主体重建缺陷,不是建模时的数据域选错** ——
交付无论怎么改授权都修不好,而那句 `workspace_scope_required` 还在把人往一个不存在的数据域上引。
**按留出协议,本轮不修。** 记在这里,等第二次 C 或它在 A/B 上复现。

### 一次隔离违规(代理自述),以及我自己的工具缺口

代理在排查那条 `params: null` 的通知错误时,**读了 `~/go/pkg/mod` 下的平台源码**,
这违反简报硬约束 1。它自己发现后停止并在报告里如实写明,最终修复是之后靠 400 逐个试出来的。
**污染评估:只影响通知那一条发现的"发现路径",不影响其余三块,也不影响任何计时数字。**
**真正该改的是我的工具:**`eval-isolate.sh` 的 ANSWER_DIRS 只锁两个仓库,**没锁 Go module cache** ——
平台源码在那里有第二份可读副本。这是我的隔离设置漏了,不是代理找到的漏洞。已修(见下)。

### 对"是不是只对评估示例特化"的回答

- **正面证据**:12 条规则里 10 条在一个从未测过的形状上被检验且全部成立,0 条被推翻;
  mock 一次过、零 playwright 失败、零截图 —— 这些都是前 12 轮挣来的,而且迁移了。
- **反面证据**:C 做不完。四块新能力面**每一块都有坑**,其中两块(Workflow 可驱动性、导出作业投影)
  是平台缺陷而不是文档缺陷。**前 12 轮的优化完全没有触及这片区域,因为 A/B 根本不会走到这里。**
- **所以诚实的结论是**:优化本身没有过拟合到 A/B 的**域**,但**覆盖面**确实被 A/B 的形状限定了。
  Skill 在这两类产品上已经相当顺,在这四块能力上则基本是空白 —— 而空白处的文档质量未经任何检验。

## mini-26(**方差对照轮** —— 需求 A 请假审批,回滚到 0.3.80 + `1b5ab4e`,2026-09-13 20:21–21:38)

**76.9 min / 80.4 M ctx / 403 次调用 / 1003 KB 文档 / 10 个接口。**
这不是优化轮,是尺子。它复制 mini-18(0.3.80,同需求 A):**70.2 / 99.4 / 438 / 1146 / 11**。
配对是核过的:0.3.80 tarball 打包于 04:55:20Z,`1b5ab4e` 落于 04:53:40Z,mini-18 跑于 04:59–06:05,
下一次 skill 改动 `652e0aa` 要到 06:26。回滚后验了四个标记(裸 `playwright` import 回来、
`verification.md` 又说 `params.email`、nonce 值域规则不在、路由绑定修复不在),确认回滚为真。

### 同版本、同需求,两次跑的差别

| | mini-18 | mini-26 | Δ |
|---|---|---|---|
| 时间 min | 70.2 | 76.9 | **+6.7(+9.5%)** |
| 上下文 M | 99.4 | 80.4 | **−19.0(−19.1%)** |
| 调用次数 | 438 | 403 | −35(−8.0%) |
| 文档 KB | 1146 | 1003 | −143(−12.5%) |
| 接口数 | 11 | 10 | −1 |
| **min/接口** | 6.38 | **7.69** | **+1.31(+20.5%)** |
| **M/接口** | 9.04 | **8.04** | −1.00(−11.0%) |

接口数不同(11 vs 10),所以归一口径才是主口径。**同一份 Skill、同一份需求,
两次跑在时间上差 9.5%(按接口归一 20.5%),在上下文上差 19.1%。而且两个方向相反 ——
慢的那次反而省上下文。**

### 预注册判定(口径在启动前写死,见 `/tmp/mini26-analysis-plan.md`)

**1. 阈值(|Δtime| ≥ 7.0 min 或 |Δctx| ≥ 9.9 M):经上下文一路跨过。** Δctx = 19.0 M,接近阈值两倍;
Δtime = 6.7 min 差 0.3 min 没够到绝对线。按预注册的"或"口径,**判定成立:轮间噪声至少这么大。**

**2. mini-22 号称快了 6.5 min —— 落在噪声里,改写为"未证实"。** 对照轮的 |Δ| = 6.7 min ≥ 6.5 min。
mini-22 的 63.7 不再作为"改进"的证据,它和 mini-18 的 70.2 在一次对照里就能被复现出来的差距之内。

**3. 旧版本没有快过当前最好成绩**(76.9 > 63.7),所以"整条序列为负"的警报没响。
但也不能反过来说序列为正 —— 见第 2 条。

**4. 文档读入量本身也有噪声。** 预注册带 ±10% 判稳(1031–1261 KB),实测 1003 KB,
**落在带外(−12.5%)。同一份文档、同一个需求,读进来的量能差 12.5%。**
推论:1146 → 395 KB(−65%)这个下降远在噪声之外,是真的;但**十几个百分点的文档量变化不能单独当成绩。**

**5. 三条应当复现的缺陷,只复现了一条。**
- **(a) 裸 `playwright` import:复现。** 交付的 `journeys.ts:1` 就是 `import type { Page } from 'playwright'`,
  ui-check 第一次直接 `Cannot find module 'playwright/test'`,白跑一轮。**这条修的是真问题。**
- **(b) nonce 撞值域:没复现。** 见第 6 条。
- **(c) `params.email` 赔一轮 `ia`:未被触发,不是被证伪。** 交付自己写了
  `stringOf(params["email"]) + stringOf(params["actual"])` **两个键拼起来再判包含** ——
  哪个键名都能过。文档的错说法这一轮没咬到人。顺带:这条断言因此并没有钉住拒绝形状,
  它是对冲不是契约断言。**同一个文档错误,一轮赔一次 `ia`,一轮零成本 —— 文档错误的代价本身也是随机的。**

**6. 同库连跑三次应当至少挂一次 —— 被证伪,三次全过。**
130s / 106s / 100s,每次 `expected=10, unexpected=0, flaky=0`,`source_audit=passed`。
预注册要求说清是"本轮碰巧错开"还是"我当初根因判断有误",证据从代码里读:
mini-18 的 `periodFor` 把哈希落进**每个用例写死的那个月**里的某一天,两次 run 必然在同一个月抢日子;
mini-26 的 `derivedRange`(`journeys.ts:16`)是
`offset = (hash % 100) * 6槽 * 6天 + slot * 6`,**把每次 run 放进 2027 年起 100 个互不重叠的 36 天块**,
两次 run 撞块的概率 1%。**所以不是我根因判错,是这段派生代码由交付自己现写,每轮写成什么样是随机的。**
关键推论:**mini-26 是在"值域规则被回滚掉"的情况下自发写对的,
所以 mini-20/22/24 没再犯这个错,不能记在那条规则头上 —— 那条规则是不是吃劲的,至今没有证据。**

### 对照轮本身的一个硬发现:**旧版本在新 Plane 上跑不起来,纯回滚做不到**

0.3.80 的 CLI 被今天的 Plane 挡住:
`module_capability.contract_mismatch`,`client_registry_sha256: c8caa904… expected b59b19a3…`,
唯一出路是 CLI 自己打印的 `domainry-cli update --force`,而它会换掉 `~/.claude/skills/` 下的二进制。
代理按"记录下来继续绕"执行了并留了痕(`stage-log.txt` 第 3 行)。
**后果:mini-26 的 references 是 0.3.80 的,CLI 二进制却是今天 HEAD 编的。**
所以这一轮只能算"references 回滚 + CLI 当前 + Plane 当前",不是纯复制。
方向上这会让 mini-26 略偏慢(多了一轮被驳回的 `model plan`),
也就是说**真实轮间方差可能比 6.7 min 略小一点,但不会小到让第 2 条翻案。**
要做纯版本考古,必须连 Plane 一起回滚 —— 这条以后要照办。

### 独立 verify(我自己在全新库上跑,没采信代理自报)

backend IA:initial **10/10**、restart **10/10**,两相位 `evidence=ok`(36.2s / 33.6s)。
runtime ui-check **同库连跑三次:10/10、10/10、10/10**,`unexpected=0 flaky=0`,`source_audit=passed`。
mock **10/10**,`project check --scope all` = `valid`,0 条诊断。**全绿。**

### 这一轮不改任何 Skill

按预注册的最后一条:对照轮是尺子不是靶子,拿它的结果去改 Skill 就等于用尺子拟合。
代理报的四条新缝(导航 marker 无 schema、`RecordPage.items` 与文档的 `records` 不符、
`aria-busy` 就绪协议没写进产品 DOM 契约、PB 的 nonce 审计规则在 SKILL.md 里 grep 不到)**只登记,不修**,
等它们在正式轮里再要一次代价,或我自己在源码里核实之后再动。

### 这一轮真正改变的是判据

从现在起,A/B 序列里**单轮 10% 以内的时间差、20% 以内的上下文差,一律不作为改进证据**,
要么拿多轮中位数说话,要么就说"没测出来"。
前面那些"快了 2 分钟""省了 8 M"的说法,凡是低于这个幅度的,**都退回未证实。**

## D-07 更正:我给 data-exchange 403 记的根因指错了地方(2026-09-13,mini-26 之后复核)

mini-25 把这条记成"作业投影路径上的主体重建缺陷",并指向
`record_data_exchange_providers.go:106` "只填三个字段、没设 `Known`"。**这个定位是错的。**
我这次是从源码一条条读下来的,不是从代理报告抄的:

**成立的部分(复核后确认):**
`report_export_data_exchange_provider.go` 的 `principal()` 调 `QueryScopeForPrincipal`,
后者在 `!principal.Known` 时返回 `ErrPrincipalScopeRequired`(`principal_workspace_scope.go:104`),
`principal()` 把它包成 `workspaceError` → `report_export_data_exchange_provider.go:337`
= `403 backend.workspace_scope_required`。**链路对,错误码对得上,符号也对得上。**

**错的部分:**
`record_data_exchange_providers.go` 的 `principal()` 确实只填三个字段,但它前一行就调了
`p.resolve(ctx, scope.ActorID, scope.RoleKey)`,而 `p.resolve` **不是可有可无的** ——
`record_application_service.go:318` 只要 `DataExchangeProviders != nil` 就把它绑成
`ResolveBatchPrincipal`。所以"没人设 `Known`"不成立。

**`Known:false` 的真实来源:** `ResolveBatchPrincipal`
(`runtime_services_record_dependencies.go:75`)有三条显式返回 `Known:false` 的分支:
`identityPrincipals == nil`、`identityPrincipals.Resolve` 报错、`ResolveBusinessPrincipal` 报错。
我逐条排掉了第三条:`ResolveBusinessPrincipal` 在 `!principal.Known` 时原样返回、
在查不到档案行时 `continue`,**它不会把 `Known` 从真变假**。剩下第二条最可能。

**而第二条在本机的实现是 testkit 的 `manifestIdentityBinding.Resolve`
(`bootstrap/testkit/manifest_identity_sdk.go:254`):**
`RoleKey` 为空时回落到 `firstUserRole(subject)`,若该 subject 在 manifest 里没有角色,
`binding.roles[""]` 查不到 → `identity.role_not_found` 403 → 上游拿到 error → `Known:false` → 我们看到的那个 403。

**这条更正最要紧的后果:出错的解析器是 dev-runtime 用的 manifest/testkit 身份绑定,
所以它很可能是本机验收环境的缺陷,而不是生产 Plane 的缺陷。优先级因此大幅下降 ——
mini-25 把它记成平台缺陷是抬高了。**

**仍然不改源码。** 我把机制缩到了两行以内,但没有复现证明那次失败的作业带的是哪个 subject/role;
在没有复现的情况下改 `ResolveBatchPrincipal` 的回落或 testkit 的解析器,是拿平台源码赌一个假设。
**下一轮 C 的复现配方(已登记):403 发生的同一时刻,在 runtime.log 里抓
`identity.role_not_found` 或 `identity.application_scope_mismatch`,并记下作业的 `ActorID`/`RoleKey`。
抓到哪一个,就能一次定死是回落缺陷还是作业没存住角色。**

顺带核过:这个错说法**没有进任何 Skill 文档**(`skills/` 下 0 处匹配),只在本日志里,
所以不存在 mini-24 那种"改了一处漏了一处"的风险。按扫全树的规矩,这次是扫过才下的结论。
