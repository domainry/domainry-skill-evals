import importlib.util
import hashlib
import json
import os
from pathlib import Path
import sys
import threading
import time

import pytest


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "harness"))
SPEC = importlib.util.spec_from_file_location("run_driver", ROOT / "harness/run_driver.py")
MOD = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MOD
SPEC.loader.exec_module(MOD)

import eval_config


def healthy_service(version="service-v1"):
    details = {
        "application_delivery": version,
        "runtime_contract": "runtime-domain-api-v1 + runtime-authoring-v1",
        "runtime_module": "runtime@v1 closure:runtime-closure-sha",
        "project_template": "template.tar.gz sha256:template-sha",
        "runtime_client_sdk": "client.tar.gz sha256:client-sha",
        "skill_packages": "1 platforms sha256:skill-package-sha",
        "project_delivery_trust": "local.domainry.project-delivery revision 1",
    }
    return 200, {
        "contract_version": "domainry-control-plane-health-v1",
        "status": "healthy",
        "service_kind": "template-control-plane",
        "version": version,
        "checks": [
            {"name": name, "status": "passed", "detail": detail}
            for name, detail in details.items()
        ],
    }


def stable_service_fetcher(_url, _timeout):
    return healthy_service()


def write_candidate(tmp_path):
    root = tmp_path / "installed-skills/domainry-builder-v1"
    (root / "bin").mkdir(parents=True)
    identity = {
        "contract_version": "domainry-builder-skill-identity-v1",
        "skill_name": "domainry-builder-v1",
        "package_metadata_filename": "skill-package.json",
    }
    identity_raw = json.dumps(identity, separators=(",", ":")).encode()
    (root / "skill-identity.json").write_bytes(identity_raw)
    (root / "SKILL.md").write_text("candidate\n")
    cli = root / "bin/domainry-cli"
    cli.write_bytes(b"#!/bin/sh\nexit 0\n")
    cli.chmod(0o755)
    package = {
        "contract_version": "domainry-builder-skill-package-v1",
        "skill_name": "domainry-builder-v1",
        "skill_identity_contract_version": "domainry-builder-skill-identity-v1",
        "skill_identity_sha256": hashlib.sha256(identity_raw).hexdigest(),
        "entrypoint": "bin/domainry-cli",
        "skill_tree_sha256": eval_config.installed_tree_sha256(
            root, "skill-package.json"),
        "cli_binary_sha256": hashlib.sha256(cli.read_bytes()).hexdigest(),
        "version": "test-v1",
        "runtime_api_contract_version": "runtime-domain-api-v1",
        "runtime_api_contract_hash": "a" * 64,
    }
    (root / "skill-package.json").write_text(json.dumps(package))
    config = tmp_path / "candidate-config.json"
    config.write_text(json.dumps({
        "candidate_skill_root": str(root),
        "cli_relative": "bin/domainry-cli",
        "apply_target": {"flag": "--service", "value": "http://127.0.0.1:8283"},
    }))
    return root, config


def run_arguments(tmp_path, script, *, run_name="run", session_id="fresh-session"):
    config = tmp_path / "candidate-config.json"
    if not config.exists():
        _, config = write_candidate(tmp_path)
    prompt = tmp_path / "requirements.md"
    prompt.write_text("task")
    session = (
        "import json\n"
        f"print(json.dumps({{'type':'thread.started','thread_id':{session_id!r}}}), flush=True)\n"
    )
    return {
        "run_dir": tmp_path / run_name,
        "isolation_root": tmp_path / f"{run_name}-isolation",
        "benchmark": "m1-crm",
        "run_id": run_name,
        "candidate_config": config,
        "model": "test-model",
        "mode": "baseline",
        "parent_run_id": None,
        "prompt_source": prompt,
        "agent_command": [
            sys.executable, "-u", "-c", session + script, "{model}", "{prompt}"],
        "checker_command": None,
        "checker_source": None,
        "auth_source": None,
        "budgets": MOD.Budgets(),
        "service_fetcher": stable_service_fetcher,
    }


def command_event(kind, family_command, code=None):
    item = {"type": "command_execution", "command": family_command}
    if code is not None:
        item["exit_code"] = code
    return {"type": kind, "item": item}


def observed_cli(family, started, completed, index):
    return {
        "family": family,
        "event_item_id": f"item_{index}",
        "observed_started_epoch": started,
        "observed_completed_epoch": completed,
        "observed_started_event_line": index * 2 + 1,
        "observed_completed_event_line": index * 2 + 2 if completed is not None else None,
        "capture_file": (
            f"cli/{index + 1:03d}-{family}.json" if completed is not None else None),
    }


def test_baseline_stops_on_first_failed_scoring_command():
    monitor = MOD.RunMonitor("baseline", MOD.Budgets())
    command = "/candidate/domainry-cli model plan --json --project ."
    monitor.observe(command_event("item.started", command))
    monitor.observe(command_event("item.completed", command, 1))
    assert monitor.stop_state == "baseline_first_scoring_failure"
    assert monitor.first_scoring_failure == {
        "family": "model_plan", "exit_code": 1, "output_state": None,
    }


def test_baseline_stops_on_explicit_failure_state_even_with_zero_exit():
    monitor = MOD.RunMonitor("baseline", MOD.Budgets())
    command = "/candidate/domainry-cli model plan --json --project ."
    event = command_event("item.completed", command, 0)
    event["item"]["aggregated_output"] = json.dumps({
        "state": "repair_required", "issue_count": 1,
    })
    monitor.observe(event)
    assert monitor.stop_state == "baseline_first_scoring_failure"
    assert monitor.first_scoring_failure["output_state"] == "repair_required"


def test_convergence_requires_parent_and_may_retry(tmp_path):
    monitor = MOD.RunMonitor("convergence", MOD.Budgets(cli_retries=2))
    command = "/candidate/domainry-cli verify --json --project ."
    monitor.observe(command_event("item.started", command))
    monitor.observe(command_event("item.completed", command, 1))
    monitor.observe(command_event("item.started", command))
    assert monitor.stop_state is None
    assert monitor.cli_retries == 1

    arguments = run_arguments(tmp_path, "")
    arguments.update(mode="convergence", parent_run_id=None)
    with pytest.raises(ValueError, match="parent_run_id"):
        MOD.execute_run(**arguments)


def test_cli_retry_and_token_budgets_fail_closed():
    monitor = MOD.RunMonitor("convergence", MOD.Budgets(total_tokens=100, cli_retries=1))
    command = "/candidate/domainry-cli apply finalize --json --project ."
    monitor.observe(command_event("item.started", command))
    monitor.observe(command_event("item.completed", command, 1))
    monitor.observe(command_event("item.started", command))
    monitor.observe(command_event("item.completed", command, 1))
    monitor.observe(command_event("item.started", command))
    assert monitor.stop_state == "budget_exhausted_cli_retries"
    assert monitor.cli_retries == 2

    token_monitor = MOD.RunMonitor("convergence", MOD.Budgets(total_tokens=100))
    token_monitor.observe({"type": "turn.completed", "usage": {
        "input_tokens": 90, "output_tokens": 11,
    }})
    assert token_monitor.stop_state == "budget_exhausted_tokens"
    assert token_monitor.total_tokens == 101


def test_token_usage_breakdown_uses_provider_input_plus_output_without_double_counting():
    monitor = MOD.RunMonitor("baseline", MOD.Budgets(total_tokens=5_000_000))
    monitor.observe({"type": "turn.completed", "usage": {
        "input_tokens": 5_613_505,
        "cached_input_tokens": 5_387_520,
        "output_tokens": 59_969,
        "reasoning_output_tokens": 14_837,
    }})

    assert monitor.total_tokens == 5_673_474
    assert monitor.stop_state == "budget_exhausted_tokens"
    assert monitor.token_usage == {
        "input_tokens": 5_613_505,
        "cached_input_tokens": 5_387_520,
        "non_cached_input_tokens": 225_985,
        "output_tokens": 59_969,
        "reasoning_output_tokens": 14_837,
        "budget_tokens": 5_673_474,
        "budget_basis": "provider_cumulative_input_plus_output",
        "cached_input_included_in_input": True,
        "reasoning_output_included_in_output": True,
        "observability_status": "complete",
    }


def test_token_usage_optional_details_fail_closed_per_event():
    assert MOD.event_usage_breakdown({"usage": {
        "input_tokens": 90, "output_tokens": 10,
    }}) == {
        "input_tokens": 90,
        "cached_input_tokens": None,
        "non_cached_input_tokens": None,
        "output_tokens": 10,
        "reasoning_output_tokens": None,
        "budget_tokens": 100,
        "budget_basis": "provider_cumulative_input_plus_output",
        "cached_input_included_in_input": True,
        "reasoning_output_included_in_output": True,
        "observability_status": "partial",
    }
    assert MOD.event_usage_breakdown({"usage": {
        "input_tokens": 90, "cached_input_tokens": 91,
        "output_tokens": 10, "reasoning_output_tokens": 11,
    }})["observability_status"] == "invalid_detail"
    assert MOD.event_usage_breakdown({"usage": {
        "input_tokens": 90,
    }}) is None


def test_verify_fixture_is_independent_diagnostic_and_never_a_scoring_retry():
    monitor = MOD.RunMonitor("baseline", MOD.Budgets(cli_invocations=1, cli_retries=0))
    diagnostic = "/candidate/domainry-cli verify fixture --json --project ."
    verify = "/candidate/domainry-cli verify --json --project ."
    monitor.observe(command_event("item.started", diagnostic), observed_at=10, event_line=1)
    failed = command_event("item.completed", diagnostic, 1)
    failed["item"]["aggregated_output"] = "error: undeclared role sales_rep\n"
    monitor.observe(failed, observed_at=12, event_line=2)
    monitor.observe(command_event("item.started", verify), observed_at=13, event_line=3)

    assert monitor.stop_state is None
    assert monitor.cli_invocations == 1
    assert monitor.cli_retries == 0
    assert monitor.diagnostic_invocations == 1
    assert monitor.diagnostic_failures == 1
    assert monitor.first_scoring_failure is None
    assert monitor.diagnostic_first_failure["family"] == "verify_fixture"
    assert monitor.first_failure()["failure_kind"] == "diagnostic"


def test_prompt_policy_separates_baseline_and_convergence(tmp_path):
    source = tmp_path / "source.md"
    source.write_text("do the work")
    baseline = tmp_path / "baseline.md"
    convergence = tmp_path / "convergence.md"
    MOD.append_prompt_policy(source, baseline, "baseline")
    MOD.append_prompt_policy(source, convergence, "convergence")
    assert "Do not repair or retry" in baseline.read_text()
    assert "never pass@1 evidence" in convergence.read_text()


def test_command_json_is_argv_not_shell_text():
    assert MOD.command_from_json(json.dumps(["python3", "-V"])) == ["python3", "-V"]
    with pytest.raises(ValueError):
        MOD.command_from_json(json.dumps("python3 -V"))


def test_driver_seals_baseline_evidence_after_first_failure(tmp_path):
    command = "/candidate/domainry-cli model plan --json --project ."
    script = (
        "import json,time\n"
        f"item={{'type':'command_execution','command':{command!r}}}\n"
        "print(json.dumps({'type':'item.started','item':item}), flush=True)\n"
        "done=dict(item); done['exit_code']=1; done['aggregated_output']='{}'\n"
        "print(json.dumps({'type':'item.completed','item':done}), flush=True)\n"
        "time.sleep(5)\n"
    )
    arguments = run_arguments(tmp_path, script, run_name="baseline-01")
    arguments["budgets"] = MOD.Budgets(
        wall_clock_seconds=30, cli_invocations=5, cli_retries=1)
    code = MOD.execute_run(**arguments)
    run = arguments["run_dir"]
    assert code == 1
    lifecycle = json.loads((run / "lifecycle.json").read_text())
    scorecard = json.loads((run / "scorecard.json").read_text())
    assert lifecycle["state"] == "baseline_first_scoring_failure"
    assert lifecycle["measurement_complete"] is False
    assert lifecycle["environment_valid"] is True
    assert lifecycle["measurement_boundary"] == "baseline_first_failure_sealed"
    assert (run / "agent-events.jsonl").is_file()
    assert (run / "cli/001-model_plan.json").is_file()
    assert (run / "checklist-results.json").is_file()
    assert (run / "failures.json").is_file()
    assert scorecard["pass_at_1"] is False
    assert scorecard["terminal_state"] == "baseline_first_scoring_failure"


def test_baseline20_shape_preserves_diagnostic_failure_and_token_terminal(tmp_path):
    commands = [
        ("model_capability", "/candidate/domainry-cli model capability --json --project .",
         {"state": "available"}, 0),
        ("model_plan", "/candidate/domainry-cli model plan --json --project .",
         {"state": "valid"}, 0),
        ("apply_model", "/candidate/domainry-cli apply model --json --project .",
         {"state": "implementation_ready"}, 0),
        ("verify_fixture", "/candidate/domainry-cli verify fixture --json --project .",
         'error: project compiler-bound Runtime acceptance fixture: Runtime acceptance fixture '
         '"overdue_contacted_lead" references undeclared role "sales_rep"\n', 1),
    ]
    script = (
        "import json\n"
        f"commands={commands!r}\n"
        "for index,(family,command,output,code) in enumerate(commands):\n"
        " item={'id':f'item_{index}','type':'command_execution','command':command}\n"
        " print(json.dumps({'type':'item.started','item':item}),flush=True)\n"
        " done=dict(item);done.update(exit_code=code,aggregated_output=(json.dumps(output) if isinstance(output,dict) else output))\n"
        " print(json.dumps({'type':'item.completed','item':done}),flush=True)\n"
        "message={'id':'result','type':'agent_message','text':'EVAL_RESULT={\"state\":\"not_done\"}'}\n"
        "print(json.dumps({'type':'item.completed','item':message}),flush=True)\n"
        "print(json.dumps({'type':'turn.completed','usage':{"
        "'input_tokens':5613505,'cached_input_tokens':5387520,"
        "'output_tokens':59969,'reasoning_output_tokens':14837}}),flush=True)\n"
    )
    arguments = run_arguments(tmp_path, script, run_name="baseline-20-shape")
    arguments["budgets"] = MOD.Budgets(
        total_tokens=5_000_000, cli_invocations=5, cli_retries=0)

    assert MOD.execute_run(**arguments) == 1
    run = arguments["run_dir"]
    lifecycle = json.loads((run / "lifecycle.json").read_text())
    progress = json.loads((run / "progress.json").read_text())
    scorecard = json.loads((run / "scorecard.json").read_text())
    tokens = json.loads((run / "tokens.json").read_text())
    failures = json.loads((run / "failures.json").read_text())
    stage_timing = json.loads((run / "stage-timing.json").read_text())

    assert lifecycle["state"] == "budget_exhausted_tokens"
    assert lifecycle["measurement_complete"] is False
    assert lifecycle["termination"] == {
        "observed": 5_673_474,
        "limit": 5_000_000,
        "basis": "provider_cumulative_input_plus_output",
    }
    assert lifecycle["first_failure"]["family"] == "verify_fixture"
    assert lifecycle["scoring_first_failure"] is None
    assert lifecycle["first_scoring_failure"] is None
    assert lifecycle["diagnostic_first_failure"]["capture_file"] == (
        "cli/004-verify_fixture.json")
    assert lifecycle["usage"]["cli_invocations_started"] == 3
    assert lifecycle["usage"]["cli_invocations_captured"] == 3
    assert lifecycle["usage"]["cli_retries_started"] == 0
    assert lifecycle["usage"]["diagnostic_cli_invocations_started"] == 1
    assert lifecycle["usage"]["diagnostic_cli_failures"] == 1
    assert lifecycle["diagnostic_cli"]["latest"]["subcommand"] == "verify_fixture"
    assert lifecycle["diagnostic_cli"]["first_failure"]["family"] == "verify_fixture"
    assert lifecycle["checker_exit_code"] is None
    assert lifecycle["checker_gate"]["reason"] == "agent_declared_not_done"

    assert progress["domainry_cli"]["invocations_total"] == 3
    assert progress["domainry_cli"]["retries_total"] == 0
    assert progress["diagnostic_cli"]["invocations_total"] == 1
    assert progress["diagnostic_cli"]["failed_total"] == 1
    assert progress["diagnostic_first_failure"]["family"] == "verify_fixture"
    assert progress["agent"]["token_usage"]["non_cached_input_tokens"] == 225_985
    assert progress["checker_allowed"] is False

    assert tokens["total_tokens"] == tokens["budget_tokens"] == 5_673_474
    assert tokens["input_tokens"] == 5_613_505
    assert tokens["cached_input_tokens"] == 5_387_520
    assert tokens["non_cached_input_tokens"] == 225_985
    assert tokens["output_tokens"] == 59_969
    assert tokens["reasoning_output_tokens"] == 14_837

    assert scorecard["A4_verify_first_pass"] is None
    assert scorecard["C4_cli_invocations"] == 3
    assert scorecard["C4_cli_retries"] == 0
    assert scorecard["C4_diagnostic_cli"]["invocations"] == 1
    assert scorecard["C4_diagnostic_cli"]["failures"] == 1
    assert scorecard["C2_usage_breakdown"]["cached_input_tokens"] == 5_387_520
    assert scorecard["diagnostic_failure_attribution"] == {"domainry-cli": 1}
    assert scorecard["failure_attribution"] == {"unattributed": 1}
    assert scorecard["C5_stage_timing"]["diagnostic_intervals"][0]["family"] == (
        "verify_fixture")
    assert scorecard["C5_stage_timing"]["stages"]["verify"]["status"] == "unknown"

    diagnostic = stage_timing["diagnostic_intervals"]
    assert len(diagnostic) == 1
    assert diagnostic[0]["family"] == "verify_fixture"
    assert diagnostic[0]["failed"] is True
    assert diagnostic[0]["scoring_effect"] == "none"
    assert stage_timing["stages"]["verify"]["status"] == "unknown"
    assert any(failure.get("failure_kind") == "diagnostic" for failure in failures)
    assert any(failure.get("stage") == "driver" for failure in failures)


def test_driver_rejects_overwriting_measured_run(tmp_path):
    arguments = run_arguments(tmp_path, "")
    run = arguments["run_dir"]
    run.mkdir()
    (run / "meta.json").write_text("{}")
    with pytest.raises(ValueError, match="measured-run artifacts"):
        MOD.execute_run(**arguments)


@pytest.mark.parametrize(("dirty_path", "expected"), [
    ("project/.domainry/state.json", r"project/\.domainry"),
    ("runtime/cohort.sqlite", "SQLite cohort"),
    ("codex-home/history.jsonl", "CODEX_HOME"),
    ("project/old.txt", "old or non-empty project"),
])
def test_driver_rejects_reused_isolation_state(tmp_path, dirty_path, expected):
    arguments = run_arguments(tmp_path, "")
    dirty = arguments["isolation_root"] / dirty_path
    dirty.parent.mkdir(parents=True, exist_ok=True)
    dirty.write_text("old")
    with pytest.raises(ValueError, match=expected):
        MOD.execute_run(**arguments)


def test_driver_rejects_resume_or_missing_frozen_model_and_prompt():
    with pytest.raises(ValueError, match="resume"):
        MOD.validate_agent_command(["codex", "exec", "resume", "{model}", "{prompt}"])
    with pytest.raises(ValueError, match=r"\{prompt\}"):
        MOD.validate_agent_command(["codex", "exec", "--model", "{model}"])
    with pytest.raises(ValueError, match=r"\{model\}"):
        MOD.validate_agent_command(["codex", "exec", "{prompt}"])
    with pytest.raises(ValueError, match="evaluator-only"):
        MOD.validate_agent_command(
            ["codex", "exec", "{model}", "{prompt}", str(ROOT)])


def test_agent_gets_clean_environment_and_fresh_git_project(tmp_path, monkeypatch):
    old_home = tmp_path / "old-home"
    old_codex = tmp_path / "old-codex"
    old_home.mkdir()
    old_codex.mkdir()
    (old_codex / "history.jsonl").write_text("old session")
    monkeypatch.setenv("HOME", str(old_home))
    monkeypatch.setenv("CODEX_HOME", str(old_codex))
    script = (
        "import os,pathlib\n"
        "p=pathlib.Path('context.json')\n"
        "db=pathlib.Path(os.environ['DOMAINRY_EVAL_SQLITE_PATH'])\n"
        "p.write_text(json.dumps({'cwd':os.getcwd(),'home':os.environ['HOME'],"
        "'codex_home':os.environ['CODEX_HOME'],'db_absent':not db.exists(),"
        "'domainry_absent':not pathlib.Path('.domainry').exists()}))\n"
    )
    arguments = run_arguments(tmp_path, script)
    assert MOD.execute_run(**arguments) == 1
    meta = json.loads((arguments["run_dir"] / "meta.json").read_text())
    context = json.loads((Path(meta["project_path"]) / "context.json").read_text())
    freeze = json.loads((arguments["run_dir"] / "freeze-manifest.json").read_text())
    assert context["cwd"] == meta["project_path"]
    assert context["home"] != str(old_home)
    assert context["codex_home"] != str(old_codex)
    assert context["db_absent"] is True
    assert context["domainry_absent"] is True
    assert all(freeze["absence_proof"].values())
    assert freeze["model"] == "test-model"
    assert freeze["candidate"] == freeze["isolated_candidate"]


def test_candidate_copy_drift_invalidates_run(tmp_path):
    script = (
        "import os,pathlib\n"
        "skill=pathlib.Path(os.environ['CODEX_HOME'])/'skills/domainry-builder-v1/SKILL.md'\n"
        "skill.write_text('tampered\\n')\n"
    )
    arguments = run_arguments(tmp_path, script)
    assert MOD.execute_run(**arguments) == 1
    lifecycle = json.loads((arguments["run_dir"] / "lifecycle.json").read_text())
    assert lifecycle["state"] == "environment_invalid_candidate_drift"
    assert lifecycle["environment_valid"] is False
    assert json.loads((
        arguments["run_dir"] / "candidate-isolated-after.json").read_text())["valid"] is False


def test_two_runs_have_distinct_isolation_and_session_context(tmp_path):
    first = run_arguments(tmp_path, "", run_name="run-one", session_id="session-one")
    second = run_arguments(tmp_path, "", run_name="run-two", session_id="session-two")
    assert MOD.execute_run(**first) == 1
    assert MOD.execute_run(**second) == 1
    first_meta = json.loads((first["run_dir"] / "meta.json").read_text())
    second_meta = json.loads((second["run_dir"] / "meta.json").read_text())
    assert first_meta["isolation_root"] != second_meta["isolation_root"]
    assert first_meta["project_path"] != second_meta["project_path"]
    assert first_meta["codex_home"] != second_meta["codex_home"]
    assert first_meta["agent_session_id"] == "session-one"
    assert second_meta["agent_session_id"] == "session-two"


def test_reused_agent_session_invalidates_second_run(tmp_path):
    first = run_arguments(tmp_path, "", run_name="run-one", session_id="same-session")
    second = run_arguments(tmp_path, "", run_name="run-two", session_id="same-session")
    MOD.execute_run(**first)
    assert MOD.execute_run(**second) == 1
    lifecycle = json.loads((second["run_dir"] / "lifecycle.json").read_text())
    assert lifecycle["state"] == "invalid_agent_session_context"
    assert lifecycle["environment_valid"] is False


def test_real_codex_entry_fails_fast_without_auth(tmp_path, monkeypatch):
    arguments = run_arguments(tmp_path, "")
    empty_codex_home = tmp_path / "caller-codex-home"
    empty_codex_home.mkdir()
    monkeypatch.setenv("CODEX_HOME", str(empty_codex_home))
    arguments["agent_command"] = [
        "codex", "exec", "--json", "--model", "{model}", "{prompt}"]
    with pytest.raises(ValueError, match="authentication is unavailable"):
        MOD.execute_run(**arguments)
    assert not arguments["isolation_root"].exists()


def test_real_codex_entry_defaults_to_caller_codex_home_auth(tmp_path, monkeypatch):
    caller_home = tmp_path / "caller-codex-home"
    caller_home.mkdir()
    auth = caller_home / "auth.json"
    auth.write_text(json.dumps({"token": "available"}))
    (caller_home / "history.jsonl").write_text("must not be selected")
    monkeypatch.setenv("CODEX_HOME", str(caller_home))
    assert MOD.resolve_auth_source(None, ["codex", "exec"]) == auth.resolve()


def test_only_ephemeral_auth_is_staged_and_it_is_removed(tmp_path):
    auth_home = tmp_path / "auth-source-home"
    auth_home.mkdir()
    secret = "secret-that-must-not-be-archived"
    auth = auth_home / "auth.json"
    auth.write_text(json.dumps({"token": secret}))
    auth_hash = hashlib.sha256(auth.read_bytes()).hexdigest()
    (auth_home / "history.jsonl").write_text("old thread")
    (auth_home / "config.toml").write_text("model='old-model'")
    (auth_home / "state.sqlite").write_text("old state")
    script = (
        "import hashlib,os,pathlib,stat,sys\n"
        "home=pathlib.Path(os.environ['CODEX_HOME'])\n"
        "raw=(home/'auth.json').read_bytes()\n"
        "token=json.loads(raw)['token']\n"
        "print(json.dumps({'type':'item.completed','item':{'type':'agent_message',"
        "'text':token+' '+hashlib.sha256(raw).hexdigest()}}),flush=True)\n"
        "sys.stderr.write(token)\n"
        "pathlib.Path('auth-context.json').write_text(json.dumps({"
        "'entries':sorted(p.name for p in home.iterdir()),"
        "'mode':stat.S_IMODE((home/'auth.json').stat().st_mode)}))\n"
    )
    arguments = run_arguments(tmp_path, script)
    arguments["auth_source"] = auth
    MOD.execute_run(**arguments)
    meta = json.loads((arguments["run_dir"] / "meta.json").read_text())
    context = json.loads((Path(meta["project_path"]) / "auth-context.json").read_text())
    assert context == {"entries": ["auth.json", "skills"], "mode": 0o600}
    isolated_codex_home = Path(meta["codex_home"])
    assert sorted(path.name for path in isolated_codex_home.iterdir()) == ["skills"]
    lifecycle = json.loads((arguments["run_dir"] / "lifecycle.json").read_text())
    freeze_text = (arguments["run_dir"] / "freeze-manifest.json").read_text()
    assert lifecycle["auth_cleanup_status"] == "removed"
    assert secret not in freeze_text
    assert auth_hash not in freeze_text
    assert "auth-source-home" not in freeze_text
    for path in arguments["run_dir"].rglob("*"):
        if path.is_file():
            assert secret.encode() not in path.read_bytes()
            assert auth_hash.encode() not in path.read_bytes()


def test_auth_is_removed_when_agent_exits_abnormally(tmp_path):
    auth = tmp_path / "auth.json"
    auth.write_text(json.dumps({"token": "ephemeral"}))
    arguments = run_arguments(tmp_path, "raise RuntimeError('boom')\n")
    arguments["auth_source"] = auth
    assert MOD.execute_run(**arguments) == 1
    meta = json.loads((arguments["run_dir"] / "meta.json").read_text())
    assert not (Path(meta["codex_home"]) / "auth.json").exists()
    lifecycle = json.loads((arguments["run_dir"] / "lifecycle.json").read_text())
    assert lifecycle["auth_cleanup_status"] == "removed"
    progress = json.loads((arguments["run_dir"] / "progress.json").read_text())
    assert progress["status"] == "terminal"
    assert progress["lifecycle_phase"] == "terminal"
    assert progress["lifecycle_state"] == "agent_process_failed"


def test_auth_is_removed_after_budget_termination(tmp_path):
    auth = tmp_path / "auth.json"
    auth.write_text(json.dumps({"token": "ephemeral"}))
    arguments = run_arguments(tmp_path, "import time\ntime.sleep(5)\n")
    arguments["auth_source"] = auth
    arguments["budgets"] = MOD.Budgets(wall_clock_seconds=0.05)
    assert MOD.execute_run(**arguments) == 1
    meta = json.loads((arguments["run_dir"] / "meta.json").read_text())
    assert not (Path(meta["codex_home"]) / "auth.json").exists()
    lifecycle = json.loads((arguments["run_dir"] / "lifecycle.json").read_text())
    assert lifecycle["state"] == "budget_exhausted_wall_clock"
    assert lifecycle["auth_cleanup_status"] == "removed"


def test_auth_cleanup_failure_marks_environment_invalid_but_leaves_no_secret(
        tmp_path, monkeypatch):
    auth = tmp_path / "auth.json"
    auth.write_text(json.dumps({"token": "ephemeral"}))
    real_remove = MOD.remove_isolated_auth

    def reported_failure(path):
        real_remove(path)
        return "failed to remove isolated Codex authentication"

    monkeypatch.setattr(MOD, "remove_isolated_auth", reported_failure)
    arguments = run_arguments(tmp_path, "")
    arguments["auth_source"] = auth
    assert MOD.execute_run(**arguments) == 1
    lifecycle = json.loads((arguments["run_dir"] / "lifecycle.json").read_text())
    meta = json.loads((arguments["run_dir"] / "meta.json").read_text())
    assert lifecycle["state"] == "environment_invalid_auth_cleanup"
    assert lifecycle["auth_cleanup_status"] == "failed"
    assert lifecycle["environment_valid"] is False
    assert not (Path(meta["codex_home"]) / "auth.json").exists()


def verify_artifact(evidence, *, nested=False):
    output = (
        {"output": {"business_flow_evidence": evidence}}
        if nested else {"business_flow_evidence": evidence}
    )
    return {"family": "verify", "output": output}


def test_flow_evidence_is_extracted_from_latest_verify_and_archived(tmp_path):
    evidence = {"contract_version": MOD.FLOW_EVIDENCE_CONTRACT, "phases": {}}
    artifacts = [verify_artifact({"contract_version": "old"}), verify_artifact(evidence, nested=True)]
    path, source, valid, error = MOD.archive_flow_evidence(artifacts, None, tmp_path)
    assert json.loads(path.read_text()) == evidence
    assert source == "verify"
    assert valid is True
    assert error is None


def test_missing_flow_evidence_is_left_for_checker(tmp_path):
    path, source, valid, error = MOD.archive_flow_evidence([], None, tmp_path)
    assert path is None
    assert source == "missing"
    assert valid is None
    assert error is None
    command = MOD.expand_checker_command(
        ["checker", "--flow-evidence", "{flow_evidence}", "--project", "{project}"],
        {"flow_evidence": "", "verify_result": "", "project": "/project"},
    )
    assert command == ["checker", "--project", "/project"]


def test_external_flow_evidence_cannot_override_verify(tmp_path):
    embedded = {"contract_version": MOD.FLOW_EVIDENCE_CONTRACT, "value": 1}
    external = tmp_path / "external.json"
    external.write_text(json.dumps({
        "contract_version": MOD.FLOW_EVIDENCE_CONTRACT, "value": 2}))
    path, source, valid, error = MOD.archive_flow_evidence(
        [verify_artifact(embedded)], external, tmp_path)
    assert path is None
    assert source == "conflict"
    assert valid is False
    assert "hashes differ" in error


def test_conflicting_embedded_flow_evidence_is_rejected(tmp_path):
    output = {
        "business_flow_evidence": {
            "contract_version": MOD.FLOW_EVIDENCE_CONTRACT, "value": 1},
        "output": {"business_flow_evidence": {
            "contract_version": MOD.FLOW_EVIDENCE_CONTRACT, "value": 2}},
    }
    path, source, valid, error = MOD.archive_flow_evidence(
        [{"family": "verify", "output": output}], None, tmp_path)
    assert path is None
    assert source == "verify"
    assert valid is False
    assert "conflicting" in error


def test_checker_tampering_with_archived_flow_evidence_invalidates_run(tmp_path):
    evidence = {"contract_version": MOD.FLOW_EVIDENCE_CONTRACT, "phases": {}}
    commands = [
        ("/candidate/domainry-cli model plan --json --project .", {"state": "valid"}),
        ("/candidate/domainry-cli apply model --json --project .",
         {"state": "implementation_ready"}),
        ("/candidate/domainry-cli apply finalize --json --project .",
         {"state": "finalized"}),
        ("/candidate/domainry-cli verify --json --project .", {
            "state": "verified_and_stopped", "business_flow_evidence": evidence}),
    ]
    script = (
        f"commands={commands!r}\n"
        "for command,output in commands:\n"
        " item={'type':'command_execution','command':command,'exit_code':0,"
        "'aggregated_output':json.dumps(output)}\n"
        " print(json.dumps({'type':'item.completed','item':item}),flush=True)\n"
        "print(json.dumps({'type':'item.completed','item':{'type':'agent_message',"
        "'text':'EVAL_RESULT={\"state\":\"done\"}'}}),flush=True)\n"
    )
    checker = tmp_path / "checker.py"
    checker.write_text(
        "import pathlib,sys\npathlib.Path(sys.argv[1]).write_text('{}')\n")
    arguments = run_arguments(tmp_path, script)
    arguments["checker_source"] = checker
    arguments["checker_command"] = [
        sys.executable, "{checker}", "{flow_evidence}"]
    assert MOD.execute_run(**arguments) == 1
    lifecycle = json.loads((arguments["run_dir"] / "lifecycle.json").read_text())
    assert lifecycle["state"] == "flow_evidence_archive_drift"
    assert lifecycle["environment_valid"] is False


def test_service_identity_is_frozen_and_stable(tmp_path):
    arguments = run_arguments(tmp_path, "")
    MOD.execute_run(**arguments)
    before = json.loads((arguments["run_dir"] / "service-before.json").read_text())
    after = json.loads((arguments["run_dir"] / "service-after.json").read_text())
    freeze = json.loads((arguments["run_dir"] / "freeze-manifest.json").read_text())
    assert before == after == freeze["service_identity"]
    assert before["healthy"] is True
    assert len(before["health_document_sha256"]) == 64
    published = before["published_identity"]
    assert published["version"] == "service-v1"
    names = {check["name"] for check in published["checks"]}
    assert MOD.REQUIRED_SERVICE_CHECKS <= names


def test_unhealthy_service_fails_before_isolation_or_agent(tmp_path):
    arguments = run_arguments(tmp_path, "")
    arguments["service_fetcher"] = lambda _url, _timeout: (503, {
        "contract_version": "domainry-control-plane-health-v1",
        "status": "unhealthy",
        "checks": [{"name": "application_delivery", "status": "failed"}],
    })
    with pytest.raises(ValueError, match="service is unhealthy"):
        MOD.execute_run(**arguments)
    assert not arguments["isolation_root"].exists()
    assert not arguments["run_dir"].exists()


def test_service_drift_invalidates_run_and_skips_checker(tmp_path):
    responses = [healthy_service("service-v1"), healthy_service("service-v2")]

    def changing_service(_url, _timeout):
        return responses.pop(0)

    script = ""
    checker = tmp_path / "checker.py"
    checker.write_text("from pathlib import Path\nPath('checker-ran').write_text('yes')\n")
    arguments = run_arguments(tmp_path, script)
    arguments["service_fetcher"] = changing_service
    arguments["checker_source"] = checker
    arguments["checker_command"] = [sys.executable, "{checker}"]
    assert MOD.execute_run(**arguments) == 1
    lifecycle = json.loads((arguments["run_dir"] / "lifecycle.json").read_text())
    meta = json.loads((arguments["run_dir"] / "meta.json").read_text())
    assert lifecycle["state"] == "environment_invalid_service_drift"
    assert lifecycle["environment_valid"] is False
    assert not (Path(meta["project_path"]) / "checker-ran").exists()
    checklist = json.loads((arguments["run_dir"] / "checklist-results.json").read_text())
    assert "environment invalid" in checklist["reason"]


def test_real_shape_baseline_plan_failure_skips_checker_and_attributes_diagnostics(tmp_path):
    capability_command = "/candidate/domainry-cli model capability --json --project ."
    command = "/candidate/domainry-cli model plan --json --project ."
    diagnostics = [
        {
            "code": "model.field_modifier_invalid",
            "message": "field lead_id modifier unique is only valid on Object fields",
            "path": "backend/model/30-conversion.json#conversion_request",
            "owner": "domainry-cli",
            "stage": "model_loader",
            "repair_facts": {"collection": "objects", "key": "conversion_request"},
        },
        {
            "code": "model.field_modifier_invalid",
            "message": "field conversion_request_id modifier unique is only valid on Object fields",
            "path": "backend/model/30-conversion.json#customer",
            "owner": "domainry-cli",
            "stage": "model_loader",
            "repair_facts": {"collection": "objects", "key": "customer"},
        },
    ]
    output = {
        "contract_version": "domainry-model-preflight-envelope-v1",
        "state": "repair_required",
        "issue_count": 2,
        "diagnostics": diagnostics,
    }
    raw_output = "\n".join([
        json.dumps(output, separators=(",", ":")),
        "model.field_modifier_invalid: invalid model field",
        "ledger.runtime_manifest_invalid: reports[1].object_sql_v1.sql is invalid",
        "error: Builder validation found 2 issue(s)",
    ])
    script = (
        f"capability={{'id':'item_capability','type':'command_execution',"
        f"'command':{capability_command!r}}}\n"
        "print(json.dumps({'type':'item.started','item':capability}),flush=True)\n"
        "capability_done=dict(capability);capability_done.update("
        "exit_code=0,aggregated_output=json.dumps({'state':'available'}))\n"
        "print(json.dumps({'type':'item.completed','item':capability_done}),flush=True)\n"
        f"item={{'id':'item_plan','type':'command_execution','command':{command!r}}}\n"
        "print(json.dumps({'type':'item.started','item':item}),flush=True)\n"
        f"done=dict(item);done.update(exit_code=1,aggregated_output={raw_output!r})\n"
        "print(json.dumps({'type':'item.completed','item':done}),flush=True)\n"
    )
    checker = tmp_path / "checker.py"
    checker.write_text("from pathlib import Path\nPath('checker-ran').write_text('yes')\n")
    arguments = run_arguments(tmp_path, script, run_name="real-shape-baseline")
    arguments["checker_source"] = checker
    arguments["checker_command"] = [sys.executable, "{checker}"]

    assert MOD.execute_run(**arguments) == 1
    run = arguments["run_dir"]
    lifecycle = json.loads((run / "lifecycle.json").read_text())
    checklist = json.loads((run / "checklist-results.json").read_text())
    failures = json.loads((run / "failures.json").read_text())
    scorecard = json.loads((run / "scorecard.json").read_text())
    meta = json.loads((run / "meta.json").read_text())
    capture = json.loads(next((run / "cli").glob("*-model_plan.json")).read_text())
    stage_timing = json.loads((run / "stage-timing.json").read_text())

    assert lifecycle["state"] == "baseline_first_scoring_failure"
    assert lifecycle["environment_valid"] is True
    assert lifecycle["measurement_boundary"] == "baseline_first_failure_sealed"
    assert lifecycle["checker_exit_code"] is None
    assert lifecycle["usage"]["total_tokens"] is None
    assert not (run / "tokens.json").exists()
    assert checklist["status"] == "not_executed"
    assert "before verify" in checklist["reason"]
    assert not (Path(meta["project_path"]) / "checker-ran").exists()
    assert len(failures) == 2
    assert capture["output"] == output
    assert capture["raw_output"] == raw_output
    assert [failure["owner"] for failure in failures] == ["domainry-cli", "domainry-cli"]
    assert all(failure["attribution_status"] == "attributed" for failure in failures)
    assert scorecard["A1_plan_first_pass"] is False
    assert scorecard["A1_plan_error_count"] == 2
    assert scorecard["A5_acceptance_first_pass"] is None
    assert scorecard["A_source"]["A5"] == "not_measurable"
    assert scorecard["failure_attribution"] == {"domainry-cli": 2}
    assert scorecard["C2_total_tokens"] is None
    assert scorecard["C5_stage_seconds"]["model"] is not None
    assert stage_timing["stages"]["plan"]["started_epoch"] == (
        stage_timing["stages"]["discovery"]["ended_epoch"])
    assert stage_timing["stages"]["plan"]["ended_epoch"] == (
        capture["observed_completed_epoch"])
    assert stage_timing["stages"]["plan"]["end_provenance"] == {
        "source": "agent-event-observations.jsonl",
        "capture_file": "cli/002-model_plan.json",
        "family": "model_plan",
        "event": "completed",
        "event_item_id": "item_plan",
        "event_line": capture["observed_completed_event_line"],
        "boundary_reason": "terminal_stage_cli_completed",
    }
    assert stage_timing["critical_path"]["unknown_stages"] == [
        "apply", "finalize", "verify"]
    progress = json.loads((run / "progress.json").read_text())
    assert progress["status"] == "terminal"
    assert progress["lifecycle_state"] == "baseline_first_scoring_failure"
    assert progress["first_failure_seal_triggered"] is True
    assert progress["checker_allowed"] is False
    assert progress["checker_decision_reason"] == "baseline_first_failure_before_verify"
    assert progress["domainry_cli"] == {
        "invocations_total": 2,
        "completed_total": 2,
        "failed_total": 1,
        "retries_total": 0,
        "latest": progress["domainry_cli"]["latest"],
    }
    assert progress["domainry_cli"]["latest"]["subcommand"] == "model_plan"
    assert progress["domainry_cli"]["latest"]["status"] == "failed"
    assert progress["agent"]["total_tokens"] is None
    assert progress["agent"]["total_tokens_status"] == "unavailable"


def test_baseline10_not_done_after_apply_is_delivery_incomplete(tmp_path):
    commands = [
        (f"/candidate/domainry-cli model capability cap-{index} --json", "available")
        for index in range(4)
    ] + [
        ("/candidate/domainry-cli model plan --json --project .", "valid"),
        ("/candidate/domainry-cli apply model --json --project .", "implementation_ready"),
    ]
    script = (
        f"commands={commands!r}\n"
        "for command,state in commands:\n"
        " item={'type':'command_execution','command':command}\n"
        " print(json.dumps({'type':'item.started','item':item}),flush=True)\n"
        " done=dict(item);done.update(exit_code=0,aggregated_output=json.dumps({'state':state}))\n"
        " print(json.dumps({'type':'item.completed','item':done}),flush=True)\n"
        "print(json.dumps({'type':'item.completed','item':{'type':'agent_message',"
        "'text':'EVAL_RESULT={\"state\":\"not_done\"}'}}),flush=True)\n"
    )
    checker = tmp_path / "checker.py"
    checker.write_text("from pathlib import Path\nPath('checker-ran').write_text('yes')\n")
    arguments = run_arguments(tmp_path, script, run_name="baseline10-not-done")
    arguments["checker_source"] = checker
    arguments["checker_command"] = [sys.executable, "{checker}"]

    assert MOD.execute_run(**arguments) == 1
    run = arguments["run_dir"]
    lifecycle = json.loads((run / "lifecycle.json").read_text())
    meta = json.loads((run / "meta.json").read_text())
    checklist = json.loads((run / "checklist-results.json").read_text())
    failures = json.loads((run / "failures.json").read_text())
    scorecard = json.loads((run / "scorecard.json").read_text())
    progress = json.loads((run / "progress.json").read_text())

    assert lifecycle["state"] == "delivery_incomplete"
    assert lifecycle["measurement_complete"] is False
    assert lifecycle["measurement_boundary"] == "delivery_incomplete"
    assert lifecycle["agent_exit_code"] == 0
    assert lifecycle["agent_result_state"] == "not_done"
    assert lifecycle["checker_exit_code"] is None
    assert lifecycle["checker_gate"]["reason"] == "agent_declared_not_done"
    assert {"apply_finalize:missing", "verify:missing"} <= set(
        lifecycle["checker_gate"]["missing"])
    assert checklist["status"] == "not_executed"
    assert not (Path(meta["project_path"]) / "checker-ran").exists()
    assert meta["agent_declared_done"] is False
    assert meta["agent_result_state"] == "not_done"
    assert failures == [{
        "stage": "apply",
        "owner": "agent",
        "note": "Agent declared EVAL_RESULT state not_done before delivery completed",
        "terminal_state": "delivery_incomplete",
        "detail": {
            "agent_result_state": "not_done",
            "latest_scoring_family": "apply_model",
            "missing_prerequisites": lifecycle["checker_gate"]["missing"],
        },
        "attribution_status": "attributed",
    }]
    assert scorecard["A1_plan_first_pass"] is True
    assert scorecard["A2_apply_first_pass"] is True
    assert scorecard["A3_finalize_first_pass"] is None
    assert scorecard["A4_verify_first_pass"] is None
    assert scorecard["A5_acceptance_first_pass"] is None
    assert scorecard["A_source"]["A5"] == "not_measurable"
    assert scorecard["pass_at_1_eligible"] is False
    assert scorecard["failure_attribution"] == {"agent": 1}
    assert progress["checker_allowed"] is False
    assert progress["checker_decision_reason"] == "agent_declared_not_done"


def test_not_done_never_allows_checker_even_with_complete_successful_funnel(tmp_path):
    evidence = {"contract_version": MOD.FLOW_EVIDENCE_CONTRACT, "phases": {}}
    commands = [
        ("/candidate/domainry-cli model plan --json --project .", {"state": "valid"}),
        ("/candidate/domainry-cli apply model --json --project .",
         {"state": "implementation_ready"}),
        ("/candidate/domainry-cli apply finalize --json --project .",
         {"state": "finalized"}),
        ("/candidate/domainry-cli verify --json --project .", {
            "state": "verified_and_stopped", "business_flow_evidence": evidence}),
    ]
    script = (
        f"commands={commands!r}\n"
        "for command,output in commands:\n"
        " item={'type':'command_execution','command':command}\n"
        " print(json.dumps({'type':'item.started','item':item}),flush=True)\n"
        " done=dict(item);done.update(exit_code=0,aggregated_output=json.dumps(output))\n"
        " print(json.dumps({'type':'item.completed','item':done}),flush=True)\n"
        "print(json.dumps({'type':'item.completed','item':{'type':'agent_message',"
        "'text':'EVAL_RESULT={\"state\":\"not_done\"}'}}),flush=True)\n"
    )
    checker = tmp_path / "checker.py"
    checker.write_text("from pathlib import Path\nPath('checker-ran').write_text('yes')\n")
    arguments = run_arguments(tmp_path, script, run_name="not-done-complete-funnel")
    arguments["checker_source"] = checker
    arguments["checker_command"] = [sys.executable, "{checker}", "{flow_evidence}"]

    assert MOD.execute_run(**arguments) == 1
    run = arguments["run_dir"]
    lifecycle = json.loads((run / "lifecycle.json").read_text())
    scorecard = json.loads((run / "scorecard.json").read_text())
    progress = json.loads((run / "progress.json").read_text())
    meta = json.loads((run / "meta.json").read_text())
    assert lifecycle["state"] == "delivery_incomplete"
    assert lifecycle["checker_gate"]["ready"] is False
    assert lifecycle["checker_gate"]["reason"] == "agent_declared_not_done"
    assert lifecycle["checker_exit_code"] is None
    assert scorecard["measurement_complete"] is False
    assert scorecard["pass_at_1_eligible"] is False
    assert scorecard["A5_acceptance_first_pass"] is None
    assert progress["checker_allowed"] is False
    assert not (Path(meta["project_path"]) / "checker-ran").exists()


def test_checker_gate_requires_parseable_finalize_success_and_exact_verify_state(tmp_path):
    verify_result = tmp_path / "verify.json"
    verify_result.write_text("{}")
    base = [
        {"family": "model_plan", "exit_code": 0, "output": {"state": "valid"}},
        {"family": "apply_model", "exit_code": 0,
         "output": {"state": "implementation_ready"}},
    ]
    ready, reason, missing = MOD.checker_delivery_readiness(
        artifacts=base + [
            {"family": "apply_finalize", "exit_code": 0, "output": {}},
            {"family": "verify", "exit_code": 0,
             "output": {"state": "verified_and_stopped"}},
        ],
        agent_result_state="done",
        verify_result=str(verify_result),
        archived_evidence=None,
        evidence_valid=None,
        checker_command=["checker"],
    )
    assert ready is False
    assert reason == "delivery_prerequisites_incomplete"
    assert missing == ["apply_finalize:success_receipt_missing"]

    ready, _, missing = MOD.checker_delivery_readiness(
        artifacts=base + [
            {"family": "apply_finalize", "exit_code": 0,
             "output": {"state": "finalized"}},
            {"family": "verify", "exit_code": 0,
             "output": {"state": "stopped"}},
        ],
        agent_result_state="done",
        verify_result=str(verify_result),
        archived_evidence=None,
        evidence_valid=None,
        checker_command=["checker"],
    )
    assert ready is False
    assert missing == ["verify:state_not_verified_and_stopped"]


@pytest.mark.parametrize(
    "family", ["model_plan", "apply_model", "apply_finalize", "verify"])
def test_structured_diagnostics_attribute_every_scoring_family(family):
    diagnostic = {
        "code": "contract.invalid",
        "message": "structured failure",
        "owner": "structured.owner",
        "stage": "contract_validation",
        "file": "backend/model/example.json",
        "json_pointer": "/objects/0",
        "constraint": "example.contract",
        "repair_facts": {"operation": "replace"},
    }
    failures = MOD.failures_from_first_scoring_capture(
        [{
            "family": family,
            "exit_code": 1,
            "output": {
                "state": "repair_required",
                "diagnostics": [diagnostic],
            },
        }],
        {"family": family},
        "baseline_first_scoring_failure",
    )
    assert failures == [{
        "stage": "contract_validation",
        "owner": "structured.owner",
        "note": "structured failure",
        "terminal_state": "baseline_first_scoring_failure",
        "attribution_status": "attributed",
        "diagnostic": diagnostic,
        "detail": diagnostic,
    }]


def test_progress_is_atomically_visible_during_normal_run_and_matches_final_outputs(tmp_path):
    commands = [
        ("/candidate/domainry-cli model capability --json --project .", "available"),
        ("/candidate/domainry-cli model plan --json --project .", "valid"),
        ("/candidate/domainry-cli apply model --json --project .", "implementation_ready"),
        ("/candidate/domainry-cli apply finalize --json --project .", "finalized"),
        ("/candidate/domainry-cli verify --json --project .", "verified_and_stopped"),
    ]
    script = (
        "import time\n"
        f"commands={commands!r}\n"
        "for index,(command,state) in enumerate(commands):\n"
        " item={'id':f'item_{index}','type':'command_execution','command':command}\n"
        " print(json.dumps({'type':'item.started','item':item}),flush=True)\n"
        " done=dict(item);done.update(exit_code=0,aggregated_output=json.dumps({'state':state}))\n"
        " print(json.dumps({'type':'item.completed','item':done}),flush=True)\n"
        "time.sleep(0.5)\n"
        "print(json.dumps({'type':'item.completed','item':{'type':'agent_message',"
        "'text':'EVAL_RESULT={\"state\":\"done\"}'}}),flush=True)\n"
    )
    checker = tmp_path / "checker.py"
    checker.write_text(
        "import json,pathlib,sys\n"
        "pathlib.Path(sys.argv[1],'checklist-results.json').write_text(json.dumps({"
        "'results':[{'id':'M01','priority':'P0','status':'pass','mechanism':'reuse'}]}))\n"
    )
    arguments = run_arguments(tmp_path, script, run_name="progress-normal")
    arguments["checker_source"] = checker
    arguments["checker_command"] = [sys.executable, "{checker}", "{run_dir}"]
    outcome = {}

    def run():
        outcome["code"] = MOD.execute_run(**arguments)

    thread = threading.Thread(target=run)
    thread.start()
    progress_path = arguments["run_dir"] / "progress.json"
    running = None
    deadline = time.time() + 3
    while time.time() < deadline and thread.is_alive():
        if progress_path.exists():
            # Repeated parsing also checks readers never observe a partial replacement.
            snapshot = json.loads(progress_path.read_text())
            latest = snapshot["domainry_cli"]["latest"]
            if (snapshot["status"] == "running"
                    and snapshot["domainry_cli"]["completed_total"]
                    and isinstance(latest, dict)
                    and latest.get("status") == "passed"):
                running = snapshot
                break
        time.sleep(0.01)
    thread.join(timeout=5)
    assert not thread.is_alive()
    assert outcome["code"] == 0
    assert running is not None
    assert running["lifecycle_phase"] == "agent"
    assert running["domainry_cli"]["latest"]["status"] == "passed"
    assert running["agent"]["last_activity_status"] == "observed"

    progress = json.loads(progress_path.read_text())
    lifecycle = json.loads((arguments["run_dir"] / "lifecycle.json").read_text())
    scorecard = json.loads((arguments["run_dir"] / "scorecard.json").read_text())
    assert progress["status"] == "terminal"
    assert progress["lifecycle_state"] == lifecycle["state"] == "completed"
    assert progress["checker_allowed"] is True
    assert progress["domainry_cli"]["invocations_total"] == 5
    assert progress["domainry_cli"]["failed_total"] == 0
    assert progress["scorecard"]["pass_at_1"] == scorecard["pass_at_1"]
    assert progress["scorecard"]["run_outcome_pass"] == scorecard["run_outcome_pass"]
    assert progress["lifecycle_phase_timing"]["agent"]["ended_epoch"] is not None
    assert progress["lifecycle_phase_timing"]["checker"]["started_epoch"] is not None
    assert progress["delivery_stage_timing_source"] == "evaluator-events"
    assert progress["delivery_stage_timing_status"] == "valid"
    observations_path = arguments["run_dir"] / "agent-event-observations.jsonl"
    observations = [json.loads(line) for line in observations_path.read_text().splitlines()]
    raw_events = (arguments["run_dir"] / "agent-events.jsonl").read_text().splitlines()
    assert len(observations) == len(raw_events)
    assert [row["event_line"] for row in observations] == list(
        range(1, len(raw_events) + 1))
    first_capture = json.loads((arguments["run_dir"] / "cli/001-model_capability.json").read_text())
    assert first_capture["observed_started_epoch"] is not None
    assert first_capture["observed_completed_epoch"] >= first_capture["observed_started_epoch"]
    stage_timing = json.loads((arguments["run_dir"] / "stage-timing.json").read_text())
    assert stage_timing["stage_order"] == [
        "discovery", "plan", "apply", "finalize", "verify"]
    assert stage_timing["status"] == "valid"
    assert stage_timing["critical_path"]["unknown_stages"] == []
    assert stage_timing["critical_path"]["hotspot"]["stage"] in stage_timing["stage_order"]
    assert stage_timing["stages"]["discovery"]["end_provenance"] == {
        "source": "agent-event-observations.jsonl",
        "capture_file": "cli/001-model_capability.json",
        "family": "model_capability",
        "event": "completed",
        "event_item_id": "item_0",
        "event_line": 3,
        "boundary_reason": "discovery_capability_completed",
    }
    assert scorecard["C5_stage_seconds_source"] == "evaluator-events"
    assert scorecard["C5_stage_seconds_status"] == "valid"
    assert not list(arguments["run_dir"].glob(".progress.json.*.tmp"))


def test_progress_marks_unobserved_usage_unavailable(tmp_path):
    project = tmp_path / "project"
    project.mkdir()
    monitor = MOD.RunMonitor("baseline", MOD.Budgets())
    monitor.observe({"type": "thread.started", "thread_id": "fresh"}, observed_at=12.0)
    writer = MOD.ProgressWriter(
        tmp_path / "progress.json", "run", "baseline", project, monitor, 10.0)
    writer.write(13.0, force=True)
    progress = json.loads((tmp_path / "progress.json").read_text())
    assert progress["agent"]["total_tokens"] is None
    assert progress["agent"]["total_tokens_status"] == "unavailable"


def test_progress_uses_evaluator_observed_cli_timestamps(tmp_path):
    project = tmp_path / "project"
    project.mkdir()
    monitor = MOD.RunMonitor("baseline", MOD.Budgets())
    commands = [
        (100.0, 120.0, "/candidate/domainry-cli model capability --json --project ."),
        (130.0, 140.0, "/candidate/domainry-cli model plan --json --project ."),
        (180.0, 200.0, "/candidate/domainry-cli apply model --json --project ."),
        (260.0, 270.0, "/candidate/domainry-cli apply finalize --json --project ."),
        (280.0, 290.0, "/candidate/domainry-cli verify --json --project ."),
    ]
    for index, (started, ended, command) in enumerate(commands):
        start_event = command_event("item.started", command)
        start_event["item"]["id"] = f"item_{index}"
        end_event = command_event("item.completed", command, 0)
        end_event["item"]["id"] = f"item_{index}"
        monitor.observe(start_event, observed_at=started)
        monitor.observe(end_event, observed_at=ended)
    writer = MOD.ProgressWriter(
        tmp_path / "progress.json", "run", "baseline", project, monitor, 90.0)
    writer.mark_agent_ended(300.0)
    writer.write(300.0, force=True)
    progress = json.loads((tmp_path / "progress.json").read_text())
    assert progress["delivery_stage"] == "verify"
    assert progress["delivery_stage_source"] == "cli-event"
    assert progress["delivery_stage_timing_source"] == "evaluator-events"
    assert progress["delivery_stage_timing_status"] == "valid"
    assert progress["delivery_stage_timing"]["requirements"] == {
        "started_epoch": 90.0, "ended_epoch": 120.0}
    assert progress["delivery_stage_timing"]["apply"] == {
        "started_epoch": 180.0, "ended_epoch": 280.0}
    assert progress["delivery_stage_timing"]["verify"] == {
        "started_epoch": 280.0, "ended_epoch": 290.0}


@pytest.mark.parametrize(
    ("terminal_stage", "attempts", "expected_start", "expected_end", "unknown"),
    [
        (
            "plan",
            [("model_capability", 105.0, 120.0), ("model_plan", 500.0, 524.0)],
            120.0,
            524.0,
            ["apply", "finalize", "verify"],
        ),
        (
            "apply",
            [
                ("model_capability", 105.0, 120.0),
                ("model_plan", 130.0, 140.0),
                ("apply_model", 200.0, 224.0),
            ],
            200.0,
            224.0,
            ["finalize", "verify"],
        ),
        (
            "finalize",
            [
                ("model_capability", 105.0, 120.0),
                ("model_plan", 130.0, 140.0),
                ("apply_model", 200.0, 210.0),
                ("apply_finalize", 260.0, 284.0),
            ],
            260.0,
            284.0,
            ["verify"],
        ),
        (
            "verify",
            [
                ("model_capability", 105.0, 120.0),
                ("model_plan", 130.0, 140.0),
                ("apply_model", 200.0, 210.0),
                ("apply_finalize", 260.0, 270.0),
                ("verify", 300.0, 324.0),
            ],
            300.0,
            324.0,
            [],
        ),
    ],
)
def test_plan_apply_finalize_failures_and_verify_termination_use_cli_completion(
    terminal_stage, attempts, expected_start, expected_end, unknown,
):
    artifacts = [
        observed_cli(family, started, completed, index)
        for index, (family, started, completed) in enumerate(attempts)
    ]
    artifacts[-1]["exit_code"] = 1

    timing = MOD.evaluator_stage_timing(artifacts, 100.0, 550.0)

    stage = timing["stages"][terminal_stage]
    assert stage["started_epoch"] == expected_start
    assert stage["ended_epoch"] == expected_end
    assert stage["seconds"] == expected_end - expected_start
    assert stage["end_provenance"]["source"] == "agent-event-observations.jsonl"
    assert stage["end_provenance"]["event"] == "completed"
    assert stage["end_provenance"]["boundary_reason"] == (
        "terminal_stage_cli_completed")
    assert timing["critical_path"]["unknown_stages"] == unknown
    for later_stage in unknown:
        assert timing["stages"][later_stage] == {
            "started_epoch": None,
            "ended_epoch": None,
            "seconds": None,
            "status": "unknown",
            "start_provenance": None,
            "end_provenance": None,
        }


def test_open_stage_cli_uses_agent_end_only_after_lifecycle_termination():
    artifacts = [
        observed_cli("model_capability", 105.0, 120.0, 0),
        observed_cli("model_plan", 500.0, None, 1),
    ]

    running = MOD.evaluator_stage_timing(artifacts, 100.0, None)
    assert running["stages"]["plan"]["status"] == "unknown"
    assert running["critical_path"]["observed_seconds"] == 20.0

    terminated = MOD.evaluator_stage_timing(artifacts, 100.0, 550.0)
    plan = terminated["stages"]["plan"]
    assert plan["started_epoch"] == 120.0
    assert plan["ended_epoch"] == 550.0
    assert plan["seconds"] == 430.0
    assert plan["end_provenance"] == {
        "source": "lifecycle.json",
        "field": "agent_ended_epoch",
        "boundary_reason": "active_stage_cli_open_at_agent_end",
        "related_cli_start": {
            "source": "agent-event-observations.jsonl",
            "capture_file": None,
            "family": "model_plan",
            "event": "started",
            "event_item_id": "item_1",
            "event_line": 3,
            "boundary_reason": "stage_cli_started",
        },
    }


def test_completed_active_stage_stays_unknown_while_agent_is_running():
    artifacts = [
        observed_cli("model_capability", 105.0, 120.0, 0),
        observed_cli("model_plan", 500.0, 524.0, 1),
    ]
    timing = MOD.evaluator_stage_timing(artifacts, 100.0, None)
    assert timing["status"] == "partial"
    assert timing["stages"]["discovery"]["seconds"] == 20.0
    assert timing["stages"]["plan"]["status"] == "unknown"
    assert timing["critical_path"]["unknown_stages"] == [
        "plan", "apply", "finalize", "verify"]


def test_later_stage_observation_prevents_terminal_closure_of_skipped_transition():
    artifacts = [
        observed_cli("model_capability", 105.0, 120.0, 0),
        observed_cli("model_plan", 130.0, 140.0, 1),
        observed_cli("verify", 300.0, 324.0, 2),
    ]

    timing = MOD.evaluator_stage_timing(artifacts, 100.0, 350.0)

    assert timing["stages"]["plan"]["status"] == "unknown"
    assert timing["stages"]["apply"]["status"] == "unknown"
    assert timing["stages"]["finalize"]["status"] == "unknown"
    assert timing["stages"]["verify"]["seconds"] == 24.0


def test_legacy_capture_without_observation_epochs_never_becomes_zero_duration():
    timing = MOD.evaluator_stage_timing([
        {"family": "model_plan", "exit_code": 1, "event_item_id": "legacy"},
    ], 100.0, 200.0)
    assert timing["status"] == "unavailable"
    assert timing["critical_path"]["observed_seconds"] == 0
    assert all(
        stage["status"] == "unknown" and stage["seconds"] is None
        for stage in timing["stages"].values())


def test_progress_does_not_trust_project_stage_timestamps(tmp_path):
    project = tmp_path / "project"
    stage_path = project / ".domainry/development/stages.json"
    stage_path.parent.mkdir(parents=True)
    stage_path.write_text(json.dumps({
        "requirements": {"started": 80, "ended": 120},
        "model": {"started": 120, "ended": 180},
    }))
    monitor = MOD.RunMonitor("baseline", MOD.Budgets())
    writer = MOD.ProgressWriter(
        tmp_path / "progress.json", "run", "baseline", project, monitor, 90.0)
    writer.write(200.0, force=True)
    progress = json.loads((tmp_path / "progress.json").read_text())
    assert progress["delivery_stage_timing_source"] is None
    assert progress["delivery_stage_timing_status"] == "unavailable"
    assert all(
        value == {"started_epoch": None, "ended_epoch": None}
        for value in progress["delivery_stage_timing"].values())


def test_verify_help_is_auxiliary_and_real_verify_is_first_scoring_attempt(tmp_path):
    help_command = "/candidate/domainry-cli verify --help"
    verify_command = (
        "/candidate/domainry-cli verify --json --project . --address 127.0.0.1:19286")
    script = (
        f"help_item={{'id':'item_156','type':'command_execution','command':{help_command!r}}}\n"
        "print(json.dumps({'type':'item.started','item':help_item}),flush=True)\n"
        "help_done=dict(help_item);help_done.update(exit_code=0,aggregated_output='usage')\n"
        "print(json.dumps({'type':'item.completed','item':help_done}),flush=True)\n"
        f"verify_item={{'id':'item_160','type':'command_execution','command':{verify_command!r}}}\n"
        "print(json.dumps({'type':'item.started','item':verify_item}),flush=True)\n"
        "verify_done=dict(verify_item);verify_done.update(exit_code=1,"
        "aggregated_output=json.dumps({'contract_version':'domainry-project-verify-v2',"
        "'state':'failed','error':'finalization receipt is stale'}))\n"
        "print(json.dumps({'type':'item.completed','item':verify_done}),flush=True)\n"
    )
    checker = tmp_path / "checker.py"
    checker.write_text(
        "import json,pathlib,sys\n"
        "pathlib.Path(sys.argv[1],'checklist-results.json').write_text(json.dumps({"
        "'results':[{'id':'M01','priority':'P0','status':'fail','mechanism':'missing'}]}))\n"
    )
    arguments = run_arguments(tmp_path, script, run_name="verify-help-boundary")
    arguments["checker_source"] = checker
    arguments["checker_command"] = [sys.executable, "{checker}", "{run_dir}"]
    assert MOD.execute_run(**arguments) == 1

    run = arguments["run_dir"]
    captures = [json.loads(path.read_text()) for path in sorted((run / "cli").glob("*.json"))]
    lifecycle = json.loads((run / "lifecycle.json").read_text())
    scorecard = json.loads((run / "scorecard.json").read_text())
    progress = json.loads((run / "progress.json").read_text())
    assert [(row["event_item_id"], row["family"], row["exit_code"])
            for row in captures] == [("item_160", "verify", 1)]
    assert lifecycle["first_scoring_failure"]["family"] == "verify"
    assert lifecycle["usage"]["cli_invocations_started"] == 1
    assert scorecard["A4_verify_first_pass"] is False
    assert scorecard["C4_cli_invocations"] == 1
    assert progress["domainry_cli"]["invocations_total"] == 1
    assert progress["domainry_cli"]["failed_total"] == 1
    assert progress["domainry_cli"]["latest"]["subcommand"] == "verify"
    assert progress["domainry_cli"]["latest"]["status"] == "failed"


def test_baseline06_verify_telemetry_first_failure_attributes_first_capture(tmp_path):
    command = (
        "/candidate/domainry-cli verify --json --project . "
        "--address 127.0.0.1:19286")
    first_failure = {
        "name": "run initial Runtime business flows",
        "status": "failed",
        "elapsed_ms": 394,
        "owner": "project.business_flow_tests",
    }
    telemetry = {
        "contract_version": "domainry-verify-telemetry-v1",
        "elapsed_ms": 100080,
        "cache": {
            "signed_runtime_package": False,
            "verification_receipt": False,
        },
        "cache_misses": {
            "signed_runtime_package": "current V6 package receipt is missing",
            "verification_receipt": "verification receipt is missing",
        },
        "stages": [
            {
                "name": "validate reusable verification and signed Runtime package",
                "status": "done",
                "elapsed_ms": 0,
                "owner": "domainry-runtime",
            },
            first_failure,
        ],
        "first_failure": first_failure,
    }
    output_error = (
        "verify initial Runtime business flows: managed business-flow tests failed "
        "for initial: exit status 1")
    output = {
        "contract_version": "domainry-project-verify-v2",
        "error": output_error,
        "state": "failed",
        "telemetry": telemetry,
    }
    script = (
        f"item={{'id':'item_160','type':'command_execution','command':{command!r}}}\n"
        "print(json.dumps({'type':'item.started','item':item}),flush=True)\n"
        f"done=dict(item);done.update(exit_code=1,aggregated_output=json.dumps({output!r}))\n"
        "print(json.dumps({'type':'item.completed','item':done}),flush=True)\n"
    )
    checker = tmp_path / "checker.py"
    checker.write_text(
        "import json,pathlib,sys\n"
        "pathlib.Path(sys.argv[1],'checklist-results.json').write_text(json.dumps({"
        "'results':[{'id':'M01','priority':'P0','status':'fail','mechanism':'missing'}]}))\n"
    )
    arguments = run_arguments(tmp_path, script, run_name="baseline06-verify-shape")
    arguments["checker_source"] = checker
    arguments["checker_command"] = [sys.executable, "{checker}", "{run_dir}"]

    assert MOD.execute_run(**arguments) == 1
    run = arguments["run_dir"]
    failures = json.loads((run / "failures.json").read_text())
    scorecard = json.loads((run / "scorecard.json").read_text())
    lifecycle = json.loads((run / "lifecycle.json").read_text())

    assert failures == [{
        "stage": "run initial Runtime business flows",
        "name": "run initial Runtime business flows",
        "owner": "project.business_flow_tests",
        "elapsed_ms": 394,
        "note": output_error,
        "terminal_state": "baseline_first_scoring_failure",
        "attribution_status": "attributed",
        "output_state": "failed",
        "output_error": output_error,
        "first_failure": first_failure,
        "telemetry": telemetry,
        "detail": first_failure,
    }]
    assert scorecard["failure_attribution"] == {
        "project.business_flow_tests": 1}
    assert lifecycle["checker_exit_code"] is None
    assert scorecard["A4_verify_first_pass"] is False
    assert scorecard["A5_acceptance_first_pass"] is None
    assert scorecard["A_source"]["A5"] == "not_measurable"
    progress = json.loads((run / "progress.json").read_text())
    assert progress["checker_allowed"] is False
    assert progress["checker_decision_reason"] == "baseline_first_failure_verify_failed"

    # A later capture cannot replace attribution from the sealed first failure.
    later = {
        "family": "verify",
        "exit_code": 1,
        "output": {
            "state": "failed",
            "telemetry": {"first_failure": {
                "name": "later failure",
                "owner": "wrong.later.owner",
            }},
        },
    }
    first_capture = {
        "family": "verify", "exit_code": 1, "output": output,
    }
    extracted = MOD.failures_from_first_scoring_capture(
        [first_capture, later], {"family": "verify"},
        "baseline_first_scoring_failure")
    assert extracted[0]["owner"] == "project.business_flow_tests"
