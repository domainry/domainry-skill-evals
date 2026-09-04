你正在全新、隔离的 Git 项目中执行 Domainry M1 基线。显式使用 `$domainry-builder-v1`；评测对象仅为当前隔离 CODEX_HOME 中已安装的这个 skill。

唯一产品需求输入是当前目录的 `requirements.md`。不要读取父目录、其他代码库、评估 harness、golden checklist 或历史 run，也不要搜索本机其他项目来复用实现或结论。当前目录没有既有实现；请从零完成一个 Delivery Batch，严格执行 skill 规定的 `requirements → model → apply → verify → done`，交付 requirements.md 的全部已接受范围，不得降级或延后。

运行约束：

- 只使用 skill 自带的 `bin/domainry-cli`，不要安装、升级或修改 skill，也不要启动、停止或修改 Domainry Plane。
- `apply model` 使用 Go module path `example.com/domainry-m1-crm/backend`，并显式追加 `--service http://127.0.0.1:8283`。
- `verify` 使用独占地址 `127.0.0.1:19283`。
- 每一条 Domainry CLI 命令必须单独作为一次 shell 命令执行，不要把多条 CLI 调用合并在同一个 shell command 中。
- 按评估协议实时维护 `.domainry/development/stages.json`，只包含 requirements、model、apply、verify 四个阶段的 started/ended epoch 秒；源码实现和 apply finalize 都计入 apply。
- 自主修复所有可恢复失败，不向用户提问，不等待人工输入。只有 `verify` 返回 `state=verified_and_stopped`、全部业务流测试通过且 TODO 进入 done 后，才可声明完成。

最终回复简明报告 batch、delivery、测试和 Runtime 结果，并以单独一行 `EVAL_RESULT={"state":"done"}` 结束。若没有真正完成，必须如实使用 `EVAL_RESULT={"state":"not_done"}`。
