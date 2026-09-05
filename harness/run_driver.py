#!/usr/bin/env python3
"""Budgeted evaluator run lifecycle for baseline and convergence runs.

The driver consumes a Codex ``--json`` event stream, persists every raw line,
and makes stopping policy evaluator-owned.  A baseline is stopped after the
first failed scoring CLI command.  A convergence run is the only mode allowed
to continue repairing, and it must name its parent run.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
import hashlib
import json
import os
from pathlib import Path
import selectors
import shutil
import signal
import subprocess
import sys
import time
from typing import Callable

from eval_config import load as load_candidate
from extract_cli_captures import extract, family_for, parse_output
from preflight import assess_health, fetch_health


CONTRACT_VERSION = "domainry-eval-run-lifecycle-v1"
FREEZE_CONTRACT = "domainry-eval-freeze-manifest-v1"
PROGRESS_CONTRACT = "domainry-eval-progress-v1"
FLOW_EVIDENCE_CONTRACT = "domainry-business-flow-evidence-v1"
SCORING_FAMILIES = {"model_plan", "apply_model", "apply_finalize", "verify"}
IDENTITY_FIELDS = (
    "candidate_id", "skill_name", "skill_version", "skill_identity_sha256",
    "package_metadata_sha256", "skill_tree_sha256", "cli_binary_sha256",
    "runtime_api_contract_version", "runtime_api_contract_hash",
    "apply_target_flag", "apply_target_value",
)
FORBIDDEN_SESSION_ARGUMENTS = {
    "resume", "continue", "--resume", "--continue", "--session",
    "--session-id", "--thread", "--thread-id", "--conversation",
}
REQUIRED_SERVICE_CHECKS = {
    "application_delivery", "runtime_contract", "runtime_module",
    "project_template", "runtime_client_sdk", "skill_packages",
    "project_delivery_trust",
}
SENSITIVE_SERVICE_KEYS = {
    "auth", "authorization", "credential", "password", "secret", "token",
    "source_path", "filesystem_path", "repository_path",
}
SERVICE_IDENTITY_KEYS = {
    "contract_version", "service_kind", "version", "discovery",
    "application_delivery", "application_delivery_manifest", "runtime_module",
    "runtime_contract", "runtime_api_contract", "runtime_authoring_contract",
    "project_template", "runtime_client", "runtime_client_sdk", "skill_packages",
    "project_delivery_trust", "trust_identity", "identity",
}


def write_json(path: Path, value: object) -> None:
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def load_json_if_object(path: Path) -> dict[str, object] | None:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None
    return value if isinstance(value, dict) else None


def atomic_write_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.{os.getpid()}.{time.time_ns()}.tmp")
    try:
        temporary.write_text(
            json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        os.replace(temporary, path)
    finally:
        temporary.unlink(missing_ok=True)


def observed_stage_timing(
    project: Path, boundary_start: float, boundary_end: float,
) -> tuple[
    dict[str, dict[str, float | None]], str | None, str,
]:
    stages = {stage: {"started_epoch": None, "ended_epoch": None} for stage in (
        "requirements", "model", "apply", "verify")}
    path = project / ".domainry" / "development" / "stages.json"
    try:
        document = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return stages, None, "unavailable"
    if not isinstance(document, dict):
        return stages, "agent-stages.json", "invalid_shape"
    observed = False
    invalid_status = None
    previous_end = None
    open_stage = False
    for stage in stages:
        value = document.get(stage)
        if not isinstance(value, dict):
            continue
        started = value.get("started")
        ended = value.get("ended")
        started_valid = isinstance(started, (int, float)) and not isinstance(started, bool)
        ended_valid = isinstance(ended, (int, float)) and not isinstance(ended, bool)
        if started is not None and not started_valid:
            invalid_status = invalid_status or "invalid_shape"
        if ended is not None and not ended_valid:
            invalid_status = invalid_status or "invalid_shape"
        if not started_valid and not ended_valid:
            continue
        observed = True
        if not started_valid:
            invalid_status = invalid_status or "invalid_shape"
            continue
        start_value = float(started)
        end_value = float(ended) if ended_valid else None
        if (start_value < boundary_start or start_value > boundary_end
                or (end_value is not None and (
                    end_value < boundary_start or end_value > boundary_end))):
            invalid_status = invalid_status or "invalid_out_of_bounds"
        elif end_value is not None and end_value < start_value:
            invalid_status = invalid_status or "invalid_interval"
        elif open_stage or (previous_end is not None and start_value < previous_end):
            invalid_status = invalid_status or "invalid_non_monotonic"
        stages[stage]["started_epoch"] = start_value
        stages[stage]["ended_epoch"] = end_value
        if end_value is None:
            open_stage = True
        else:
            previous_end = end_value
    source = "agent-stages.json" if observed or document else None
    if invalid_status:
        return ({stage: {"started_epoch": None, "ended_epoch": None}
                 for stage in stages}, source, invalid_status)
    return stages, source, "valid" if observed else "unavailable"


def sha256_bytes(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest()


def sha256_file(path: Path) -> str:
    return sha256_bytes(path.read_bytes())


def canonical_json_sha256(value: object) -> str:
    return sha256_bytes(json.dumps(
        value, ensure_ascii=False, sort_keys=True, separators=(",", ":"),
    ).encode("utf-8"))


def identity_fingerprint(identity: dict[str, object]) -> dict[str, object]:
    return {key: identity.get(key) for key in IDENTITY_FIELDS}


def public_service_identity(value: object, key: str = "") -> object | None:
    if key.lower() in SENSITIVE_SERVICE_KEYS:
        return None
    if isinstance(value, dict):
        return {
            child_key: cleaned
            for child_key, child_value in sorted(value.items())
            if (cleaned := public_service_identity(child_value, child_key)) is not None
        }
    if isinstance(value, list):
        return [public_service_identity(item) for item in value]
    if isinstance(value, (str, int, float, bool)) or value is None:
        return value
    return str(value)


def stable_public_service_identity(health: dict[str, object]) -> dict[str, object]:
    identity = {
        key: public_service_identity(health[key], key)
        for key in sorted(SERVICE_IDENTITY_KEYS & health.keys())
    }
    checks = health.get("checks")
    if isinstance(checks, list):
        cleaned_checks = [
            public_service_identity(check) for check in checks if isinstance(check, dict)
        ]
        identity["checks"] = sorted(
            cleaned_checks,
            key=lambda check: str(check.get("name", "")) if isinstance(check, dict) else "",
        )
    return identity


def capture_service_identity(
    candidate: dict[str, object], timeout: float,
    fetcher: Callable[[str, float], tuple[int, object]] = fetch_health,
) -> dict[str, object]:
    if candidate.get("apply_target_flag") != "--service":
        return {
            "target_kind": "environment",
            "target_value": candidate.get("apply_target_value"),
            "identity_verifiable": False,
        }
    status, health = fetcher(str(candidate["apply_target_value"]), timeout)
    healthy, diagnostics = assess_health(status, health)
    if not healthy or not isinstance(health, dict):
        raise ValueError(
            "Application Delivery service is unhealthy: " + ", ".join(diagnostics))
    checks = health.get("checks")
    check_names = {
        check.get("name") for check in checks if isinstance(check, dict)
    } if isinstance(checks, list) else set()
    missing = sorted(REQUIRED_SERVICE_CHECKS - check_names)
    if missing:
        raise ValueError(
            "Application Delivery service identity is incomplete: " + ", ".join(missing))
    public_identity = stable_public_service_identity(health)
    return {
        "target_kind": "service",
        "healthy": True,
        "http_status": status,
        "health_document_sha256": canonical_json_sha256(public_identity),
        "published_identity": public_identity,
    }


def is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False


def command_from_json(raw: str | None, *, required: bool = False) -> list[str] | None:
    if raw is None:
        if required:
            raise ValueError("a command JSON array is required")
        return None
    value = json.loads(raw)
    if not isinstance(value, list) or not value or not all(isinstance(v, str) and v for v in value):
        raise ValueError("command must be a non-empty JSON array of strings")
    return value


def expand_command(command: list[str], values: dict[str, str]) -> list[str]:
    expanded = []
    for part in command:
        for key, value in values.items():
            part = part.replace("{" + key + "}", value)
        expanded.append(part)
    return expanded


def expand_checker_command(command: list[str], values: dict[str, str]) -> list[str]:
    optional = {"--verify-result": "{verify_result}", "--flow-evidence": "{flow_evidence}"}
    filtered: list[str] = []
    index = 0
    while index < len(command):
        expected = optional.get(command[index])
        if (expected is not None and index + 1 < len(command)
                and command[index + 1] == expected and not values[expected[1:-1]]):
            index += 2
            continue
        filtered.append(command[index])
        index += 1
    return expand_command(filtered, values)


def validate_agent_command(command: list[str]) -> None:
    lowered = {part.lower() for part in command}
    forbidden = sorted(lowered & FORBIDDEN_SESSION_ARGUMENTS)
    if forbidden:
        raise ValueError(
            "agent command may not resume or continue a session: " + ", ".join(forbidden))
    joined = "\0".join(command)
    if "{prompt}" not in joined:
        raise ValueError("agent command must receive the rendered prompt through {prompt}")
    if "{model}" not in joined:
        raise ValueError("agent command must select the frozen model through {model}")
    leaked = [name for name in (
        "{run_dir}", "{prompt_path}", "{verify_result}", "{flow_evidence}",
    ) if name in joined]
    if leaked:
        raise ValueError(
            "agent command exposes evaluator-only paths: " + ", ".join(leaked))
    if str(Path(__file__).resolve().parent.parent) in joined:
        raise ValueError("agent command contains evaluator-only filesystem paths")


def event_usage_tokens(event: object) -> int | None:
    """Return cumulative billed tokens from any streamed usage snapshot."""
    if not isinstance(event, dict):
        return None
    usage = event.get("usage")
    if not isinstance(usage, dict):
        return None
    input_tokens = usage.get("input_tokens")
    output_tokens = usage.get("output_tokens")
    if not isinstance(input_tokens, int) or not isinstance(output_tokens, int):
        return None
    return input_tokens + output_tokens


def event_eval_result_state(event: object) -> str | None:
    if not isinstance(event, dict) or event.get("type") != "item.completed":
        return None
    item = event.get("item")
    if not isinstance(item, dict) or item.get("type") != "agent_message":
        return None
    text = str(item.get("text", ""))
    marker = "EVAL_RESULT="
    states = []
    cursor = 0
    decoder = json.JSONDecoder()
    while True:
        position = text.find(marker, cursor)
        if position < 0:
            break
        payload = text[position + len(marker):].lstrip()
        try:
            value, _ = decoder.raw_decode(payload)
        except json.JSONDecodeError:
            cursor = position + len(marker)
            continue
        state = value.get("state") if isinstance(value, dict) else None
        if state in {"done", "not_done"}:
            states.append(state)
        cursor = position + len(marker)
    return states[-1] if states else None


def event_declares_done(event: object) -> bool:
    return event_eval_result_state(event) == "done"


def command_event(event: object) -> tuple[str | None, bool, int | None]:
    """Return family, started flag, and completed exit code for one event."""
    if not isinstance(event, dict) or event.get("type") not in {"item.started", "item.completed"}:
        return None, False, None
    item = event.get("item")
    if not isinstance(item, dict) or item.get("type") != "command_execution":
        return None, False, None
    command = item.get("command")
    family = family_for(command) if isinstance(command, str) else None
    if family is None:
        return None, False, None
    if event["type"] == "item.started":
        return family, True, None
    code = item.get("exit_code")
    return family, False, code if isinstance(code, int) else None


def command_output_failed(event: object) -> tuple[bool, str | None]:
    if not isinstance(event, dict):
        return False, None
    item = event.get("item")
    if not isinstance(item, dict):
        return False, None
    raw = item.get("aggregated_output", "")
    output = parse_output(raw if isinstance(raw, str) else str(raw))
    if not isinstance(output, dict):
        return False, None
    state = output.get("state")
    failed_states = {"repair_required", "failed", "invalid", "blocked", "error", "stale"}
    issue_count = output.get("issue_count")
    failed = state in failed_states or (isinstance(issue_count, int) and issue_count > 0)
    return failed, state if isinstance(state, str) else None


def artifact_failed(artifact: dict[str, object]) -> bool:
    if artifact.get("exit_code") != 0:
        return True
    output = artifact.get("output")
    if not isinstance(output, dict):
        return False
    return (
        output.get("state") in {
            "repair_required", "failed", "invalid", "blocked", "error", "stale",
        }
        or (isinstance(output.get("issue_count"), int) and output["issue_count"] > 0)
    )


def failures_from_first_scoring_capture(
    artifacts: list[dict[str, object]], first_failure: dict[str, object] | None,
    terminal: str,
) -> list[dict[str, object]]:
    if terminal != "baseline_first_scoring_failure" or not first_failure:
        return []
    family = first_failure.get("family")
    artifact = next((
        row for row in artifacts
        if row.get("family") == family and artifact_failed(row)
    ), None)
    output = artifact.get("output") if isinstance(artifact, dict) else None
    diagnostics = output.get("diagnostics") if isinstance(output, dict) else None
    failures = []
    if isinstance(diagnostics, list):
        for diagnostic in diagnostics:
            if not isinstance(diagnostic, dict):
                continue
            owner = diagnostic.get("owner")
            owner = owner if isinstance(owner, str) and owner else None
            failures.append({
                "stage": diagnostic.get("stage") or family,
                "owner": owner,
                "note": diagnostic.get("message") or diagnostic.get("code")
                        or "structured CLI diagnostic",
                "terminal_state": terminal,
                "attribution_status": "attributed" if owner else "pending",
                "diagnostic": diagnostic,
                "detail": diagnostic,
            })
    if failures:
        return failures

    # Apply/verify envelopes report the authoritative failed stage under
    # telemetry.first_failure. Attribution is deliberately limited to the
    # already-selected first failed capture; later captures and free text are
    # not consulted.
    if family not in SCORING_FAMILIES:
        return []
    telemetry = output.get("telemetry") if isinstance(output, dict) else None
    telemetry_failure = (
        telemetry.get("first_failure") if isinstance(telemetry, dict) else None)
    if not isinstance(telemetry_failure, dict):
        return []
    owner = telemetry_failure.get("owner")
    owner = owner if isinstance(owner, str) and owner else None
    name = telemetry_failure.get("name")
    name = name if isinstance(name, str) and name else None
    stage = telemetry_failure.get("stage")
    stage = stage if isinstance(stage, str) and stage else name or family
    outer_state = output.get("state")
    outer_error = output.get("error")
    return [{
        "stage": stage,
        "name": name,
        "owner": owner,
        "elapsed_ms": telemetry_failure.get("elapsed_ms"),
        "note": outer_error or name or "structured CLI telemetry failure",
        "terminal_state": terminal,
        "attribution_status": "attributed" if owner else "pending",
        "output_state": outer_state,
        "output_error": outer_error,
        "first_failure": telemetry_failure,
        "telemetry": telemetry,
        "detail": telemetry_failure,
    }]


@dataclass(frozen=True)
class Budgets:
    wall_clock_seconds: float | None = None
    total_tokens: int | None = None
    cli_invocations: int | None = None
    cli_retries: int | None = None

    def as_dict(self) -> dict[str, float | int | None]:
        return {
            "wall_clock_seconds": self.wall_clock_seconds,
            "total_tokens": self.total_tokens,
            "cli_invocations": self.cli_invocations,
            "cli_retries": self.cli_retries,
        }


@dataclass(frozen=True)
class Isolation:
    root: Path
    codex_home: Path
    agent_home: Path
    temp: Path
    project: Path
    runtime: Path
    database: Path
    candidate_copy: Path

    def as_dict(self) -> dict[str, str]:
        return {
            "root": str(self.root),
            "codex_home": str(self.codex_home),
            "agent_home": str(self.agent_home),
            "temp": str(self.temp),
            "project": str(self.project),
            "runtime": str(self.runtime),
            "database": str(self.database),
            "candidate_copy": str(self.candidate_copy),
        }


def isolation_paths(root: Path, skill_name: str) -> Isolation:
    resolved = root.expanduser().resolve(strict=False)
    return Isolation(
        root=resolved,
        codex_home=resolved / "codex-home",
        agent_home=resolved / "home",
        temp=resolved / "tmp",
        project=resolved / "project",
        runtime=resolved / "runtime",
        database=resolved / "runtime" / "cohort.sqlite",
        candidate_copy=resolved / "codex-home" / "skills" / skill_name,
    )


def reject_existing_isolation(isolation: Isolation) -> None:
    if not isolation.root.exists():
        return
    if (isolation.project / ".domainry").exists():
        raise ValueError("isolation contains old project/.domainry state")
    if isolation.database.exists() or any(
        Path(str(isolation.database) + suffix).exists() for suffix in ("-wal", "-shm")
    ):
        raise ValueError("isolation contains an existing SQLite cohort")
    if isolation.codex_home.exists() and any(isolation.codex_home.iterdir()):
        raise ValueError("isolated CODEX_HOME is non-empty or contains Agent history")
    if isolation.project.exists() and any(isolation.project.iterdir()):
        raise ValueError("isolation contains an old or non-empty project")
    raise ValueError("isolation root must not exist before the run")


def git_output(project: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "-c", "safe.directory=*", *args], cwd=project,
        text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False,
        env={
            "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
            "HOME": str(project.parent / "home"),
            "GIT_CONFIG_NOSYSTEM": "1",
            "LANG": "C.UTF-8",
        },
    )
    if result.returncode != 0:
        raise ValueError(f"Git project validation failed: {result.stderr.strip()}")
    return result.stdout.strip()


def validate_pristine_isolation(isolation: Isolation) -> None:
    if isolation.root.is_symlink():
        raise ValueError("isolation root must not be a symlink")
    if (isolation.project / ".domainry").exists():
        raise ValueError("fresh project already contains .domainry state")
    if isolation.database.exists() or any(
        Path(str(isolation.database) + suffix).exists() for suffix in ("-wal", "-shm")
    ):
        raise ValueError("fresh Runtime SQLite cohort already exists")
    project_entries = sorted(path.name for path in isolation.project.iterdir())
    if project_entries != [".git"]:
        raise ValueError("fresh Git project contains files outside .git")
    if git_output(isolation.project, "status", "--porcelain", "--untracked-files=all"):
        raise ValueError("fresh Git project has working-tree state")
    if git_output(isolation.project, "for-each-ref", "--format=%(refname)"):
        raise ValueError("fresh Git project has existing refs or history")
    codex_entries = sorted(path.name for path in isolation.codex_home.iterdir())
    if codex_entries != ["skills"]:
        raise ValueError("isolated CODEX_HOME contains Agent history or non-skill state")
    skill_entries = list((isolation.codex_home / "skills").iterdir())
    if skill_entries != [isolation.candidate_copy]:
        raise ValueError("isolated CODEX_HOME must contain exactly the frozen candidate")
    if any(isolation.agent_home.iterdir()):
        raise ValueError("isolated Agent HOME must be empty before launch")
    if any(isolation.temp.iterdir()):
        raise ValueError("isolated temporary directory must be empty before launch")


def create_isolation(root: Path, candidate: dict[str, object]) -> tuple[Isolation, dict[str, object]]:
    skill_name = str(candidate["skill_name"])
    isolation = isolation_paths(root, skill_name)
    reject_existing_isolation(isolation)
    evaluator_root = Path(__file__).resolve().parent.parent
    if is_relative_to(isolation.root, evaluator_root):
        raise ValueError("isolation root must be outside the evaluator repository")
    absence = {
        "checked_epoch": time.time(),
        "isolation_root_absent": True,
        "project_absent": True,
        "codex_home_absent": True,
        "agent_home_absent": True,
        "sqlite_database_absent": True,
        "sqlite_wal_absent": True,
        "sqlite_shm_absent": True,
    }
    isolation.root.mkdir(parents=True)
    isolation.agent_home.mkdir()
    isolation.temp.mkdir()
    isolation.runtime.mkdir()
    (isolation.codex_home / "skills").mkdir(parents=True)
    shutil.copytree(Path(str(candidate["skill_root"])), isolation.candidate_copy, copy_function=shutil.copy2)
    isolation.project.mkdir()
    git_output(isolation.project, "init", "--quiet", "--initial-branch=main")
    validate_pristine_isolation(isolation)
    return isolation, absence


def clean_agent_environment(isolation: Isolation) -> dict[str, str]:
    environment = {
        "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
        "HOME": str(isolation.agent_home),
        "CODEX_HOME": str(isolation.codex_home),
        "TMPDIR": str(isolation.temp),
        "XDG_CONFIG_HOME": str(isolation.agent_home / ".config"),
        "XDG_CACHE_HOME": str(isolation.agent_home / ".cache"),
        "XDG_DATA_HOME": str(isolation.agent_home / ".local/share"),
        "GIT_CONFIG_NOSYSTEM": "1",
        "DOMAINRY_EVAL_SQLITE_PATH": str(isolation.database),
        "LANG": os.environ.get("LANG", "C.UTF-8"),
    }
    for key in ("SSL_CERT_FILE", "SSL_CERT_DIR", "HTTP_PROXY", "HTTPS_PROXY", "NO_PROXY"):
        if key in os.environ:
            environment[key] = os.environ[key]
    return environment


def is_codex_agent_command(command: list[str]) -> bool:
    return bool(command) and Path(command[0]).name.lower() in {"codex", "codex.exe"}


def validate_auth_source(path: Path) -> Path:
    candidate = path.expanduser()
    if candidate.is_symlink() or not candidate.is_file():
        raise ValueError("Codex authentication is unavailable or not a regular file")
    try:
        document = json.loads(candidate.read_text(encoding="utf-8"))
    except (OSError, UnicodeDecodeError, json.JSONDecodeError):
        raise ValueError("Codex authentication material is not valid JSON") from None
    if not isinstance(document, dict) or not document:
        raise ValueError("Codex authentication material is not a non-empty JSON object")
    return candidate.resolve()


def resolve_auth_source(explicit: Path | None, command: list[str]) -> Path | None:
    if explicit is not None:
        return validate_auth_source(explicit)
    if not is_codex_agent_command(command):
        return None
    caller_codex_home = os.environ.get("CODEX_HOME")
    source = (
        Path(caller_codex_home).expanduser() / "auth.json"
        if caller_codex_home
        else Path.home() / ".codex" / "auth.json"
    )
    try:
        return validate_auth_source(source)
    except ValueError:
        raise ValueError(
            "Codex authentication is unavailable; provide a trusted --auth-source") from None


def stage_isolated_auth(source: Path | None, isolation: Isolation) -> Path | None:
    if source is None:
        return None
    destination = isolation.codex_home / "auth.json"
    if destination.exists() or destination.is_symlink():
        raise ValueError("isolated authentication destination is not clean")
    try:
        payload = source.read_bytes()
        # Exclusive creation prevents an unexpected file or link from being followed.
        descriptor = os.open(destination, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(descriptor, "wb") as output:
            output.write(payload)
        destination.chmod(0o600)
    except OSError:
        try:
            destination.unlink(missing_ok=True)
        except OSError:
            pass
        raise ValueError("failed to stage isolated Codex authentication") from None
    return destination


def remove_isolated_auth(path: Path | None) -> str | None:
    if path is None:
        return None
    try:
        path.unlink(missing_ok=True)
        if path.exists() or path.is_symlink():
            return "isolated Codex authentication still exists after cleanup"
    except OSError:
        return "failed to remove isolated Codex authentication"
    return None


def auth_redaction_tokens(source: Path | None) -> set[bytes]:
    if source is None:
        return set()
    raw = source.read_bytes()
    document = json.loads(raw)
    tokens = {raw, sha256_bytes(raw).encode("ascii")}

    def collect(value: object) -> None:
        if isinstance(value, dict):
            for child in value.values():
                collect(child)
        elif isinstance(value, list):
            for child in value:
                collect(child)
        elif isinstance(value, str) and len(value.encode("utf-8")) >= 8:
            tokens.add(value.encode("utf-8"))

    collect(document)
    return {token for token in tokens if token}


def redact_auth_from_file(path: Path, tokens: set[bytes]) -> str | None:
    if not path.exists() or not tokens:
        return None
    try:
        content = path.read_bytes()
        for token in sorted(tokens, key=len, reverse=True):
            content = content.replace(token, b"[REDACTED_AUTH]")
        path.write_bytes(content)
    except OSError:
        try:
            path.unlink(missing_ok=True)
        except OSError:
            pass
        return "failed to sanitize Agent output containing authentication material"
    return None


class RunMonitor:
    """Pure event policy used by the process driver and unit tests."""

    def __init__(self, mode: str, budgets: Budgets) -> None:
        if mode not in {"baseline", "convergence"}:
            raise ValueError("mode must be baseline or convergence")
        self.mode = mode
        self.budgets = budgets
        self.cli_invocations = 0
        self.cli_completions = 0
        self.cli_failures = 0
        self.cli_retries = 0
        self.total_tokens: int | None = None
        self.agent_declared_done = False
        self.agent_result_state: str | None = None
        self.last_activity_epoch: float | None = None
        self.latest_cli: dict[str, object] | None = None
        self.agent_session_ids: set[str] = set()
        self._failed_families: set[str] = set()
        self.first_scoring_failure: dict[str, object] | None = None
        self.stop_state: str | None = None
        self.stop_detail: dict[str, object] | None = None

    def stop(self, state: str, detail: dict[str, object]) -> None:
        if self.stop_state is None:
            self.stop_state = state
            self.stop_detail = detail

    def observe(self, event: object, observed_at: float | None = None) -> None:
        if isinstance(event, dict):
            self.last_activity_epoch = observed_at if observed_at is not None else time.time()
        if isinstance(event, dict) and event.get("type") == "thread.started":
            session_id = event.get("thread_id")
            if not isinstance(session_id, str) or not session_id:
                self.stop("invalid_agent_session_context", {
                    "reason": "thread.started event lacks a non-empty thread_id",
                })
            else:
                self.agent_session_ids.add(session_id)
                if len(self.agent_session_ids) > 1:
                    self.stop("invalid_agent_session_context", {
                        "reason": "multiple Agent sessions appeared in one measured run",
                        "session_ids": sorted(self.agent_session_ids),
                    })
        result_state = event_eval_result_state(event)
        if result_state is not None:
            self.agent_result_state = result_state
            self.agent_declared_done = result_state == "done"
        usage = event_usage_tokens(event)
        if usage is not None:
            self.total_tokens = max(self.total_tokens or 0, usage)
            if self.budgets.total_tokens is not None and usage > self.budgets.total_tokens:
                self.stop("budget_exhausted_tokens", {
                    "observed": usage, "limit": self.budgets.total_tokens,
                })

        family, started, exit_code = command_event(event)
        if family is None:
            return
        if started:
            self.cli_invocations += 1
            self.latest_cli = {
                "subcommand": family,
                "status": "in_progress",
                "exit_code": None,
                "output_state": None,
                "observed_epoch": self.last_activity_epoch,
            }
            if family in self._failed_families:
                self.cli_retries += 1
            if (self.budgets.cli_invocations is not None
                    and self.cli_invocations > self.budgets.cli_invocations):
                self.stop("budget_exhausted_cli_invocations", {
                    "observed": self.cli_invocations,
                    "limit": self.budgets.cli_invocations,
                    "family": family,
                })
            if (self.budgets.cli_retries is not None
                    and self.cli_retries > self.budgets.cli_retries):
                self.stop("budget_exhausted_cli_retries", {
                    "observed": self.cli_retries,
                    "limit": self.budgets.cli_retries,
                    "family": family,
                })
            return

        output_failed, output_state = command_output_failed(event)
        self.cli_completions += 1
        failed = exit_code is None or exit_code != 0 or output_failed
        if failed:
            self.cli_failures += 1
        self.latest_cli = {
            "subcommand": family,
            "status": "failed" if failed else "passed",
            "exit_code": exit_code,
            "output_state": output_state,
            "observed_epoch": self.last_activity_epoch,
        }
        if exit_code is not None and (exit_code != 0 or output_failed):
            self._failed_families.add(family)
            if family in SCORING_FAMILIES and self.first_scoring_failure is None:
                self.first_scoring_failure = {
                    "family": family,
                    "exit_code": exit_code,
                    "output_state": output_state,
                }
                if self.mode == "baseline":
                    self.stop("baseline_first_scoring_failure", self.first_scoring_failure)


class ProgressWriter:
    def __init__(
        self, path: Path, run_id: str, run_kind: str, project: Path,
        monitor: RunMonitor, started: float,
    ) -> None:
        self.path = path
        self.run_id = run_id
        self.run_kind = run_kind
        self.project = project
        self.monitor = monitor
        self.started = started
        self.lifecycle_phase = "agent"
        self.lifecycle_state = "agent_running"
        self.checker_allowed: bool | None = None
        self.checker_decision_reason: str | None = None
        self.agent_ended_epoch: float | None = None
        self.terminal = False
        self.scorecard: dict[str, object] | None = None
        self._last_write: float | None = None
        self.phase_timing: dict[str, dict[str, float | None]] = {
            phase: {"started_epoch": None, "ended_epoch": None}
            for phase in ("agent", "checker", "scorer", "terminal")
        }
        self.phase_timing["agent"]["started_epoch"] = started

    def set_phase(self, phase: str, now: float) -> None:
        if phase == self.lifecycle_phase:
            return
        current = self.phase_timing.get(self.lifecycle_phase)
        if current is not None and current["ended_epoch"] is None:
            current["ended_epoch"] = now
        self.lifecycle_phase = phase
        timing = self.phase_timing.setdefault(
            phase, {"started_epoch": None, "ended_epoch": None})
        if timing["started_epoch"] is None:
            timing["started_epoch"] = now

    def mark_agent_ended(self, now: float) -> None:
        self.agent_ended_epoch = now
        self.phase_timing["agent"]["ended_epoch"] = now

    def _delivery_stage(
        self, timing: dict[str, dict[str, float | None]], source: str | None,
    ) -> tuple[str | None, str | None]:
        for stage in ("requirements", "model", "apply", "verify"):
            value = timing[stage]
            if value["started_epoch"] is not None and value["ended_epoch"] is None:
                return stage, source
        if self.monitor.agent_declared_done:
            return "done", "agent-event"
        latest = self.monitor.latest_cli
        family = latest.get("subcommand") if isinstance(latest, dict) else None
        inferred = {
            "model_capability": "model", "model_plan": "model",
            "apply_model": "apply", "apply_finalize": "apply", "verify": "verify",
        }.get(family)
        return inferred, "cli-event" if inferred else None

    def write(self, now: float, *, force: bool = False) -> None:
        if not force and self._last_write is not None and now - self._last_write < 1.0:
            return
        agent_boundary_end = self.agent_ended_epoch or now
        stage_timing, stage_source, stage_status = observed_stage_timing(
            self.project, self.started, agent_boundary_end)
        current_stage, current_stage_source = self._delivery_stage(
            stage_timing, stage_source if stage_status == "valid" else None)
        total_tokens = self.monitor.total_tokens
        last_activity = self.monitor.last_activity_epoch
        checker_allowed = self.checker_allowed
        checker_reason = self.checker_decision_reason
        latest_subcommand = (
            self.monitor.latest_cli.get("subcommand")
            if isinstance(self.monitor.latest_cli, dict) else None)
        if (checker_allowed is None
                and self.monitor.stop_state == "baseline_first_scoring_failure"
                and latest_subcommand != "verify"):
            checker_allowed = False
            checker_reason = "baseline_first_failure_before_verify"
        snapshot = {
            "contract_version": PROGRESS_CONTRACT,
            "run_id": self.run_id,
            "run_kind": self.run_kind,
            "status": "terminal" if self.terminal else "running",
            "lifecycle_phase": self.lifecycle_phase,
            "lifecycle_state": self.monitor.stop_state or self.lifecycle_state,
            "lifecycle_phase_timing": self.phase_timing,
            "delivery_stage": current_stage,
            "delivery_stage_source": current_stage_source,
            "delivery_stage_timing": stage_timing,
            "delivery_stage_timing_source": stage_source,
            "delivery_stage_timing_status": stage_status,
            "wall_elapsed_seconds": round(max(0.0, now - self.started), 3),
            "domainry_cli": {
                "invocations_total": max(
                    self.monitor.cli_invocations, self.monitor.cli_completions),
                "completed_total": self.monitor.cli_completions,
                "failed_total": self.monitor.cli_failures,
                "retries_total": self.monitor.cli_retries,
                "latest": self.monitor.latest_cli,
            },
            "agent": {
                "last_activity_epoch": last_activity,
                "last_activity_status": "observed" if last_activity is not None else "unavailable",
                "total_tokens": total_tokens,
                "total_tokens_status": "observed" if total_tokens is not None else "unavailable",
            },
            "first_failure_seal_triggered": (
                self.monitor.first_scoring_failure is not None
                and self.monitor.mode == "baseline"),
            "checker_allowed": checker_allowed,
            "checker_decision_reason": checker_reason,
            "scorecard": self.scorecard,
            "updated_epoch": now,
        }
        atomic_write_json(self.path, snapshot)
        self._last_write = now


def terminate_process_group(process: subprocess.Popen, grace_seconds: float = 5.0) -> None:
    if process.poll() is not None:
        return
    try:
        os.killpg(process.pid, signal.SIGTERM)
        process.wait(timeout=grace_seconds)
    except ProcessLookupError:
        return
    except subprocess.TimeoutExpired:
        try:
            os.killpg(process.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        process.wait()


def capture_artifacts(events_path: Path, run_dir: Path) -> list[dict[str, object]]:
    # The raw stream remains authoritative. If the runner emitted one malformed
    # line, salvage every independently valid completed CLI event so budget or
    # stream failures still produce a useful scorecard.
    artifacts = extract(events_path, strict=False)
    cli = run_dir / "cli"
    cli.mkdir(exist_ok=True)
    if any(cli.iterdir()):
        raise ValueError(f"refusing to overwrite non-empty capture directory: {cli}")
    for index, artifact in enumerate(artifacts, 1):
        write_json(cli / f"{index:03d}-{artifact['family']}.json", artifact)
    return artifacts


def run_auxiliary(
    command: list[str], cwd: Path, stdout_path: Path, stderr_path: Path,
    timeout_seconds: float | None = None,
) -> tuple[int, bool]:
    with stdout_path.open("w", encoding="utf-8") as stdout, stderr_path.open(
        "w", encoding="utf-8"
    ) as stderr:
        try:
            process = subprocess.Popen(
                command, cwd=cwd, stdout=stdout, stderr=stderr, start_new_session=True)
        except OSError as error:
            stderr.write(str(error) + "\n")
            return 127, False
        try:
            return process.wait(timeout=timeout_seconds), False
        except subprocess.TimeoutExpired:
            terminate_process_group(process)
            return process.returncode, True


def latest_verify_path(run_dir: Path) -> str:
    matches = sorted((run_dir / "cli").glob("*-verify.json"))
    return str(matches[-1]) if matches else ""


def latest_family_artifact(
    artifacts: list[dict[str, object]], family: str,
) -> dict[str, object] | None:
    matches = [artifact for artifact in artifacts if artifact.get("family") == family]
    return matches[-1] if matches else None


def checker_delivery_readiness(
    *, artifacts: list[dict[str, object]], agent_result_state: str | None,
    verify_result: str, archived_evidence: Path | None,
    evidence_valid: bool | None, checker_command: list[str] | None,
) -> tuple[bool, str, list[str]]:
    """Return the objective delivery gate applied before any checker process."""
    missing = []
    if agent_result_state != "done":
        missing.append(
            "agent_result:not_done" if agent_result_state == "not_done"
            else "agent_result:missing")

    latest = {
        family: latest_family_artifact(artifacts, family)
        for family in ("model_plan", "apply_model", "apply_finalize", "verify")
    }
    expected_states = {
        "model_plan": {"valid"},
        "apply_model": {"implementation_ready", "applied"},
    }
    for family in ("model_plan", "apply_model", "apply_finalize"):
        artifact = latest[family]
        if artifact is None:
            missing.append(f"{family}:missing")
        elif artifact_failed(artifact):
            missing.append(f"{family}:failed")
        else:
            output = artifact.get("output")
            if not isinstance(output, dict):
                missing.append(f"{family}:unparseable_output")
            elif family in expected_states and output.get("state") not in expected_states[family]:
                missing.append(f"{family}:unexpected_success_state")
            elif family == "apply_finalize":
                finalized = output.get("state") == "finalized"
                receipt = (
                    output.get("contract_version")
                    == "domainry-source-finalization-receipt-v2"
                    and isinstance(output.get("receipt_sha256"), str)
                    and bool(output["receipt_sha256"])
                )
                if not finalized and not receipt:
                    missing.append("apply_finalize:success_receipt_missing")

    verify = latest["verify"]
    if verify is None:
        missing.append("verify:missing")
    elif artifact_failed(verify):
        missing.append("verify:failed")
    else:
        verify_output = verify.get("output")
        if not isinstance(verify_output, dict):
            missing.append("verify:unparseable_output")
        elif verify_output.get("state") != "verified_and_stopped":
            missing.append("verify:state_not_verified_and_stopped")

    verify_document = (
        load_json_if_object(Path(verify_result)) if verify_result else None)
    if verify_document is None:
        missing.append("verify_artifact:missing_or_unparseable")

    evidence_required = bool(checker_command) and any(
        "{flow_evidence}" in part for part in checker_command)
    if evidence_required:
        evidence_document = (
            load_json_if_object(archived_evidence) if archived_evidence else None)
        if evidence_document is None or evidence_valid is not True:
            missing.append("flow_evidence:missing_invalid_or_unparseable")

    if not missing:
        return True, "eligible", []
    if agent_result_state == "not_done":
        return False, "agent_declared_not_done", missing
    return False, "delivery_prerequisites_incomplete", missing


def embedded_flow_evidence(artifacts: list[dict[str, object]]) -> tuple[object | None, str | None]:
    verifies = [artifact for artifact in artifacts if artifact.get("family") == "verify"]
    if not verifies:
        return None, None
    output = verifies[-1].get("output")
    if not isinstance(output, dict):
        return None, None
    direct = output.get("business_flow_evidence")
    nested_output = output.get("output")
    nested = (
        nested_output.get("business_flow_evidence")
        if isinstance(nested_output, dict) else None
    )
    if direct is not None and nested is not None:
        if canonical_json_sha256(direct) != canonical_json_sha256(nested):
            return None, "verify contains conflicting business_flow_evidence values"
        return direct, None
    return (direct if direct is not None else nested), None


def evidence_contract_valid(evidence: object) -> bool:
    return (
        isinstance(evidence, dict)
        and evidence.get("contract_version") == FLOW_EVIDENCE_CONTRACT
    )


def load_external_evidence(path: Path | None) -> tuple[object | None, str | None]:
    if path is None:
        return None, None
    try:
        return json.loads(path.read_text(encoding="utf-8")), None
    except (OSError, UnicodeDecodeError, json.JSONDecodeError):
        return None, "external business-flow evidence is missing or invalid JSON"


def archive_flow_evidence(
    artifacts: list[dict[str, object]], external_path: Path | None, run_dir: Path,
) -> tuple[Path | None, str, bool | None, str | None]:
    embedded, embedded_error = embedded_flow_evidence(artifacts)
    external, external_error = load_external_evidence(external_path)
    if embedded_error:
        return None, "verify", False, embedded_error
    if embedded is not None and external is not None:
        if canonical_json_sha256(embedded) != canonical_json_sha256(external):
            return None, "conflict", False, (
                "verify and external business-flow evidence hashes differ")
    selected = embedded if embedded is not None else external
    source = "verify" if embedded is not None else "external" if external is not None else "missing"
    if selected is None:
        return None, source, None, external_error
    destination = run_dir / "business-flow-evidence.json"
    write_json(destination, selected)
    valid = evidence_contract_valid(selected)
    return destination, source, valid, (
        None if valid else "business-flow evidence contract_version is invalid")


def ensure_checklist(run_dir: Path, checker_code: int | None, reason: str | None = None) -> None:
    path = run_dir / "checklist-results.json"
    if path.exists():
        return
    write_json(path, {
        "contract_version": "domainry-evaluator-checklist-unavailable-v1",
        "pass": False,
        "status": "not_executed" if checker_code is None else "checker_failed",
        "reason": reason or f"checker exit code {checker_code}",
        "results": [],
    })


def append_prompt_policy(source: Path, destination: Path, mode: str) -> None:
    base = source.read_text(encoding="utf-8").rstrip()
    isolation_policy = (
        "\n\n## Evaluator-owned isolation policy\n\n"
        "Work only in the current empty Git project and use only the candidate Skill "
        "installed in the provided isolated CODEX_HOME. This is a new Agent session; "
        "do not resume or import any prior session, TODO, project, .domainry state, or "
        "database. Use DOMAINRY_EVAL_SQLITE_PATH as the sole Runtime SQLite cohort. "
        "Do not search parent or external directories for evaluator assets, golden "
        "checks, scorers, or historical runs.\n"
    )
    if mode == "baseline":
        policy = (
            "\n\n## Evaluator-owned measured-run policy\n\n"
            "This is a baseline measurement. Stop after the first failed model plan, "
            "apply model, apply finalize, or verify command. Do not repair or retry that "
            "failure in this run; report `EVAL_RESULT={\"state\":\"not_done\"}`. The "
            "driver independently enforces this boundary.\n"
        )
    else:
        policy = (
            "\n\n## Evaluator-owned measured-run policy\n\n"
            "This is an explicitly selected convergence run. Repairs and retries are "
            "allowed within the recorded budgets. This run is never pass@1 evidence.\n"
        )
    destination.write_text(base + isolation_policy + policy, encoding="utf-8")


def build_freeze_manifest(
    *, run_id: str, benchmark: str, mode: str, parent_run_id: str | None,
    model: str, budgets: Budgets, prompt_source: Path, prompt_path: Path,
    checker_source: Path | None, agent_command: list[str],
    checker_command: list[str] | None, candidate_config: Path,
    candidate: dict[str, object], isolated_candidate: dict[str, object],
    isolation: Isolation, absence: dict[str, object], frozen_scorer_bytes: bytes,
    frozen_checker_bytes: bytes | None, auth_source: Path | None,
    service_identity: dict[str, object],
) -> dict[str, object]:
    scorer = Path(__file__).with_name("scorer.py")
    return {
        "contract_version": FREEZE_CONTRACT,
        "run_id": run_id,
        "benchmark": benchmark,
        "run_kind": mode,
        "parent_run_id": parent_run_id,
        "model": model,
        "budgets": budgets.as_dict(),
        "absence_proof": absence,
        "isolation": isolation.as_dict(),
        "candidate": identity_fingerprint(candidate),
        "isolated_candidate": identity_fingerprint(isolated_candidate),
        "service_identity": service_identity,
        "hashes": {
            "candidate_config_sha256": sha256_file(candidate_config),
            "requirements_sha256": sha256_file(prompt_source),
            "rendered_driver_prompt_sha256": sha256_file(prompt_path),
            "checker_sha256": sha256_file(checker_source) if checker_source else None,
            "scorer_sha256": sha256_file(scorer),
            "frozen_checker_sha256": (
                sha256_bytes(frozen_checker_bytes) if frozen_checker_bytes else None),
            "frozen_scorer_sha256": sha256_bytes(frozen_scorer_bytes),
            "driver_sha256": sha256_file(Path(__file__)),
            "agent_command_sha256": canonical_json_sha256(agent_command),
            "checker_command_sha256": (
                canonical_json_sha256(checker_command) if checker_command else None),
        },
        "agent_context": {
            "fresh_session_required": True,
            "resume_forbidden": True,
            "codex_home_contents_during_agent": (
                ["auth.json", f"skills/{candidate['skill_name']}"]
                if auth_source is not None else [f"skills/{candidate['skill_name']}"]),
            "ephemeral_auth_staged": auth_source is not None,
            "auth_retention": "remove_immediately_after_agent",
            "environment_policy": "minimal-isolated-v1",
            "prompt_inputs": ["requirements", "evaluator-owned measured-run policy"],
            "evaluator_assets_exposed": False,
        },
    }


def validate_freeze_manifest(
    manifest_path: Path, expected: dict[str, object], isolation: Isolation,
    candidate_config: Path, prompt_source: Path, prompt_path: Path,
    checker_source: Path | None,
) -> None:
    actual = json.loads(manifest_path.read_text(encoding="utf-8"))
    if actual != expected:
        raise ValueError("freeze manifest differs from evaluator-owned frozen inputs")
    validate_pristine_isolation(isolation)
    hashes = actual["hashes"]
    live = {
        "candidate_config_sha256": sha256_file(candidate_config),
        "requirements_sha256": sha256_file(prompt_source),
        "rendered_driver_prompt_sha256": sha256_file(prompt_path),
        "checker_sha256": sha256_file(checker_source) if checker_source else None,
        "scorer_sha256": sha256_file(Path(__file__).with_name("scorer.py")),
        "driver_sha256": sha256_file(Path(__file__)),
    }
    for key, value in live.items():
        if hashes.get(key) != value:
            raise ValueError(f"frozen input drift before Agent launch: {key}")


def frozen_input_drift(
    manifest_path: Path, expected_manifest_sha256: str, prompt_source: Path,
    prompt_path: Path, candidate_config: Path, checker_source: Path | None,
) -> list[str]:
    expected = json.loads(manifest_path.read_text(encoding="utf-8"))
    hashes = expected.get("hashes", {})
    checks = {
        "freeze_manifest_sha256": (sha256_file(manifest_path), expected_manifest_sha256),
        "candidate_config_sha256": (
            sha256_file(candidate_config), hashes.get("candidate_config_sha256")),
        "requirements_sha256": (
            sha256_file(prompt_source), hashes.get("requirements_sha256")),
        "rendered_driver_prompt_sha256": (
            sha256_file(prompt_path), hashes.get("rendered_driver_prompt_sha256")),
        "checker_sha256": (
            sha256_file(checker_source) if checker_source else None,
            hashes.get("checker_sha256")),
        "scorer_sha256": (
            sha256_file(Path(__file__).with_name("scorer.py")), hashes.get("scorer_sha256")),
        "driver_sha256": (sha256_file(Path(__file__)), hashes.get("driver_sha256")),
    }
    return [key for key, (actual, frozen) in checks.items() if actual != frozen]


def revalidate_candidate(
    config: Path, candidate_root: Path, expected: dict[str, object], output: Path,
) -> str | None:
    try:
        current = load_candidate(config, candidate_root)
        write_json(output, current)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        write_json(output, {"valid": False, "error": str(error)})
        return str(error)
    if identity_fingerprint(current) != identity_fingerprint(expected):
        return "candidate identity fingerprint changed"
    return None


def prior_session_owner(run_dir: Path, session_id: str) -> str | None:
    roots = {
        run_dir.parent.resolve(),
        (Path(__file__).resolve().parent.parent / "runs").resolve(),
    }
    for lifecycle_path in (
        path for root in roots if root.exists() for path in root.glob("**/lifecycle.json")
    ):
        if lifecycle_path.parent.resolve() == run_dir.resolve():
            continue
        try:
            lifecycle = json.loads(lifecycle_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            continue
        if lifecycle.get("agent_session_id") == session_id:
            return str(lifecycle_path.parent)
    return None


def run_agent_process(
    *, command: list[str], project: Path, environment: dict[str, str],
    events_path: Path, stderr_path: Path, monitor: RunMonitor, budgets: Budgets,
    started: float, clock: Callable[[], float], progress: ProgressWriter,
) -> int:
    with events_path.open("wb") as events, stderr_path.open("wb") as stderr:
        process = subprocess.Popen(
            command, cwd=project, stdout=subprocess.PIPE, stderr=stderr,
            env=environment, text=False, bufsize=0, start_new_session=True,
        )
        assert process.stdout is not None
        selector = selectors.DefaultSelector()
        selector.register(process.stdout, selectors.EVENT_READ)
        pending = b""

        def consume(chunk: bytes) -> None:
            nonlocal pending
            events.write(chunk)
            events.flush()
            pending += chunk
            while b"\n" in pending:
                raw_line, pending = pending.split(b"\n", 1)
                line = raw_line.decode("utf-8", errors="replace")
                observed_at = clock()
                monitor.last_activity_epoch = observed_at
                try:
                    event = json.loads(line)
                except json.JSONDecodeError:
                    monitor.stop("invalid_agent_event_stream", {"line": line[:500]})
                    progress.write(observed_at, force=True)
                    continue
                monitor.observe(event, observed_at=observed_at)
                progress.write(observed_at, force=True)

        try:
            while process.poll() is None:
                elapsed = clock() - started
                progress.write(clock())
                if budgets.wall_clock_seconds is not None and elapsed > budgets.wall_clock_seconds:
                    monitor.stop("budget_exhausted_wall_clock", {
                        "observed": round(elapsed, 3), "limit": budgets.wall_clock_seconds,
                    })
                if monitor.stop_state:
                    terminate_process_group(process)
                    break
                for key, _ in selector.select(timeout=0.25):
                    chunk = os.read(key.fileobj.fileno(), 65536)
                    if not chunk:
                        continue
                    consume(chunk)
                    if monitor.stop_state:
                        terminate_process_group(process)
                        break
            remainder = process.stdout.read()
            if remainder:
                consume(remainder)
            if pending.strip():
                line = pending.decode("utf-8", errors="replace")
                try:
                    observed_at = clock()
                    monitor.observe(json.loads(line), observed_at=observed_at)
                    progress.write(observed_at, force=True)
                except json.JSONDecodeError:
                    if monitor.stop_state is None:
                        monitor.stop("invalid_agent_event_stream", {"line": line[:500]})
            return process.wait()
        except BaseException:
            terminate_process_group(process)
            raise
        finally:
            selector.close()


def execute_run(
    *,
    run_dir: Path,
    isolation_root: Path,
    benchmark: str,
    run_id: str,
    candidate_config: Path,
    model: str,
    mode: str,
    parent_run_id: str | None,
    prompt_source: Path,
    agent_command: list[str],
    checker_command: list[str] | None,
    checker_source: Path | None,
    auth_source: Path | None,
    budgets: Budgets,
    flow_evidence_source: Path | None = None,
    clock: Callable[[], float] = time.time,
    service_timeout: float = 5.0,
    service_fetcher: Callable[[str, float], tuple[int, object]] = fetch_health,
) -> int:
    if not prompt_source.is_file():
        raise ValueError(f"prompt file does not exist: {prompt_source}")
    if not candidate_config.is_file():
        raise ValueError(f"candidate config does not exist: {candidate_config}")
    if not model.strip():
        raise ValueError("model is required")
    validate_agent_command(agent_command)
    auth_source = resolve_auth_source(auth_source, agent_command)
    if checker_command is not None:
        if checker_source is None or not checker_source.is_file():
            raise ValueError("checker_source is required and must exist when checker is configured")
        if "{checker}" not in "\0".join(checker_command):
            raise ValueError("checker command must use the frozen checker through {checker}")
    elif checker_source is not None:
        raise ValueError("checker_source requires a checker command")
    executable = agent_command[0] if agent_command else ""
    executable_path = Path(executable)
    if "/" in executable and not executable_path.is_absolute():
        raise ValueError("agent command executable with a path must be absolute")
    executable_exists = (
        executable_path.is_file() if "/" in executable else shutil.which(executable) is not None
    )
    if not executable_exists:
        raise ValueError(f"agent command executable does not exist: {executable}")
    protected = (
        "lifecycle.json", "agent-events.jsonl", "meta.json", "scorecard.json",
        "checklist-results.json", "failures.json", "cli", "freeze-manifest.json",
        "candidate-before.json", "candidate-isolated-before.json",
        "candidate-after.json", "candidate-isolated-after.json",
        "service-before.json", "service-after.json",
        "evaluator-scorer.py", "evaluator-checker.py", "progress.json",
    )
    if run_dir.exists() and any((run_dir / name).exists() for name in protected):
        raise ValueError(f"run directory already contains measured-run artifacts: {run_dir}")
    if run_dir.exists() and any(run_dir.iterdir()):
        raise ValueError(f"run directory must be absent or empty: {run_dir}")
    if mode == "convergence" and not parent_run_id:
        raise ValueError("convergence runs require parent_run_id")
    if mode == "baseline" and parent_run_id:
        raise ValueError("baseline runs must not set parent_run_id")
    run_resolved = run_dir.expanduser().resolve(strict=False)
    isolation_resolved = isolation_root.expanduser().resolve(strict=False)
    if (is_relative_to(isolation_resolved, run_resolved)
            or is_relative_to(run_resolved, isolation_resolved)):
        raise ValueError("run directory and isolation root must be separate trees")
    agent_command_text = "\0".join(agent_command)
    evaluator_root = str(Path(__file__).resolve().parent.parent)
    evaluator_only_paths = [evaluator_root, str(run_resolved)]
    if checker_source is not None:
        evaluator_only_paths.append(str(checker_source.expanduser().resolve()))
    leaked_paths = [path for path in evaluator_only_paths if path and path in agent_command_text]
    if leaked_paths:
        raise ValueError("agent command contains evaluator-only filesystem paths")
    candidate = load_candidate(candidate_config)
    service_before = capture_service_identity(candidate, service_timeout, service_fetcher)
    run_dir.mkdir(parents=True, exist_ok=True)
    prompt_path = run_dir / "agent-prompt.md"
    append_prompt_policy(prompt_source, prompt_path, mode)
    frozen_scorer = run_dir / "evaluator-scorer.py"
    frozen_scorer_bytes = Path(__file__).with_name("scorer.py").read_bytes()
    frozen_checker = None
    frozen_checker_bytes = None
    if checker_source is not None:
        frozen_checker = run_dir / "evaluator-checker.py"
        frozen_checker_bytes = checker_source.read_bytes()
    isolation, absence = create_isolation(isolation_root, candidate)
    isolated_candidate = load_candidate(candidate_config, isolation.candidate_copy)
    if identity_fingerprint(isolated_candidate) != identity_fingerprint(candidate):
        raise ValueError("isolated candidate copy differs from installed candidate")
    write_json(run_dir / "candidate-before.json", candidate)
    write_json(run_dir / "candidate-isolated-before.json", isolated_candidate)
    write_json(run_dir / "service-before.json", service_before)
    freeze = build_freeze_manifest(
        run_id=run_id, benchmark=benchmark, mode=mode, parent_run_id=parent_run_id,
        model=model, budgets=budgets, prompt_source=prompt_source,
        prompt_path=prompt_path, checker_source=checker_source,
        agent_command=agent_command, checker_command=checker_command,
        candidate_config=candidate_config, candidate=candidate,
        isolated_candidate=isolated_candidate, isolation=isolation, absence=absence,
        frozen_scorer_bytes=frozen_scorer_bytes,
        frozen_checker_bytes=frozen_checker_bytes,
        auth_source=auth_source,
        service_identity=service_before,
    )
    freeze_path = run_dir / "freeze-manifest.json"
    write_json(freeze_path, freeze)
    freeze_sha256 = sha256_file(freeze_path)
    validate_freeze_manifest(
        freeze_path, freeze, isolation, candidate_config, prompt_source,
        prompt_path, checker_source)
    project = isolation.project
    started = clock()
    monitor = RunMonitor(mode, budgets)
    progress = ProgressWriter(
        run_dir / "progress.json", run_id, mode, project, monitor, started)
    lifecycle = {
        "contract_version": CONTRACT_VERSION,
        "run_id": run_id,
        "run_kind": mode,
        "parent_run_id": parent_run_id,
        "state": "agent_running",
        "measurement_complete": False,
        "environment_valid": True,
        "measurement_boundary": "running",
        "started_epoch": started,
        "ended_epoch": None,
        "budgets": budgets.as_dict(),
        "usage": {},
        "termination": None,
        "freeze_manifest_sha256": freeze_sha256,
        "ephemeral_auth_staged": auth_source is not None,
        "auth_cleanup_status": "pending" if auth_source is not None else "not_required",
    }
    write_json(run_dir / "lifecycle.json", lifecycle)
    progress.write(started, force=True)
    values = {
        "run_dir": str(run_dir.resolve()),
        "project": str(project.resolve()),
        "prompt": prompt_path.read_text(encoding="utf-8"),
        "model": model,
        "database": str(isolation.database),
        "candidate_cli": str(isolated_candidate["cli"]),
        "checker": str(frozen_checker.resolve()) if frozen_checker else "",
        "verify_result": "",
        "flow_evidence": "",
    }
    command = expand_command(agent_command, values)
    events_path = run_dir / "agent-events.jsonl"
    stderr_path = run_dir / "agent-stderr.txt"
    auth_redactions = auth_redaction_tokens(auth_source)
    isolated_auth = stage_isolated_auth(auth_source, isolation)
    auth_cleanup_error = None
    try:
        try:
            agent_code = run_agent_process(
                command=command, project=project,
                environment=clean_agent_environment(isolation),
                events_path=events_path, stderr_path=stderr_path, monitor=monitor,
                budgets=budgets, started=started, clock=clock, progress=progress,
            )
        except Exception as error:
            # Never include exception text: a lower layer could embed credential data.
            agent_code = 127
            monitor.stop("agent_process_failed", {
                "reason": "Agent process launch or monitoring failed",
                "error_type": type(error).__name__,
            })
            events_path.touch(exist_ok=True)
            stderr_path.touch(exist_ok=True)
    finally:
        auth_cleanup_error = remove_isolated_auth(isolated_auth)
    agent_ended = clock()
    progress.mark_agent_ended(agent_ended)

    if auth_cleanup_error:
        monitor.stop_state = "environment_invalid_auth_cleanup"
        monitor.stop_detail = {"reason": auth_cleanup_error}
    auth_sanitization_errors = [
        error for error in (
            redact_auth_from_file(events_path, auth_redactions),
            redact_auth_from_file(stderr_path, auth_redactions),
        ) if error
    ]
    if auth_sanitization_errors:
        monitor.stop_state = "environment_invalid_auth_sanitization"
        monitor.stop_detail = {"reason": auth_sanitization_errors[0]}

    artifacts = capture_artifacts(events_path, run_dir)
    session_id = next(iter(monitor.agent_session_ids), None)
    context_error = None
    if len(monitor.agent_session_ids) != 1:
        context_error = "Agent stream must contain exactly one fresh thread.started session"
    elif session_id is not None:
        prior_owner = prior_session_owner(run_dir, session_id)
        if prior_owner is not None:
            context_error = f"Agent session was already used by {prior_owner}"

    candidate_errors = []
    original_error = revalidate_candidate(
        candidate_config, Path(str(candidate["skill_root"])), candidate,
        run_dir / "candidate-after.json")
    isolated_error = revalidate_candidate(
        candidate_config, isolation.candidate_copy, candidate,
        run_dir / "candidate-isolated-after.json")
    if original_error:
        candidate_errors.append({"copy": "installed", "error": original_error})
    if isolated_error:
        candidate_errors.append({"copy": "isolated", "error": isolated_error})

    service_error = None
    try:
        service_after = capture_service_identity(candidate, service_timeout, service_fetcher)
        write_json(run_dir / "service-after.json", service_after)
        if service_after != service_before:
            service_error = "Application Delivery service identity changed during the run"
    except ValueError:
        service_after = {"valid": False, "reason": "service unavailable or identity incomplete"}
        write_json(run_dir / "service-after.json", service_after)
        service_error = "Application Delivery service became unavailable or identity incomplete"

    freeze_errors: list[str] = []
    try:
        freeze_errors = frozen_input_drift(
            freeze_path, freeze_sha256, prompt_source, prompt_path, candidate_config,
            checker_source)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        freeze_errors = [f"freeze_manifest_unreadable: {error}"]

    if auth_sanitization_errors:
        monitor.stop_state = "environment_invalid_auth_sanitization"
        monitor.stop_detail = {"reason": auth_sanitization_errors[0]}
    elif auth_cleanup_error:
        monitor.stop_state = "environment_invalid_auth_cleanup"
        monitor.stop_detail = {"reason": auth_cleanup_error}
    elif context_error:
        monitor.stop_state = "invalid_agent_session_context"
        monitor.stop_detail = {"reason": context_error, "session_ids": sorted(
            monitor.agent_session_ids)}
    elif candidate_errors:
        monitor.stop_state = "environment_invalid_candidate_drift"
        monitor.stop_detail = {"candidate_errors": candidate_errors}
    elif freeze_errors:
        monitor.stop_state = "environment_invalid_freeze_drift"
        monitor.stop_detail = {"drifted_inputs": freeze_errors}
    elif service_error:
        monitor.stop_state = "environment_invalid_service_drift"
        monitor.stop_detail = {"reason": service_error}
    # Evaluator code is materialized only after the Agent exits, so checker and
    # scorer content is absent from the Agent's working tree and run inputs.
    frozen_scorer.write_bytes(frozen_scorer_bytes)
    if frozen_checker is not None and frozen_checker_bytes is not None:
        frozen_checker.write_bytes(frozen_checker_bytes)

    elapsed_after_agent = clock() - started
    if (budgets.wall_clock_seconds is not None
            and elapsed_after_agent > budgets.wall_clock_seconds):
        monitor.stop("budget_exhausted_wall_clock", {
            "observed": round(elapsed_after_agent, 3),
            "limit": budgets.wall_clock_seconds,
            "phase": "agent",
        })
    values["verify_result"] = latest_verify_path(run_dir)
    archived_evidence, evidence_source, evidence_valid, evidence_error = archive_flow_evidence(
        artifacts, flow_evidence_source, run_dir)
    archived_evidence_sha256 = (
        sha256_file(archived_evidence) if archived_evidence is not None else None)
    if archived_evidence is not None:
        values["flow_evidence"] = str(archived_evidence.resolve())
    if evidence_source == "conflict" or (
        evidence_error is not None and evidence_error.startswith("verify contains conflicting")
    ):
        monitor.stop("flow_evidence_conflict", {"reason": evidence_error})
    checker_gate_ready, checker_gate_reason, checker_gate_missing = (
        checker_delivery_readiness(
            artifacts=artifacts,
            agent_result_state=monitor.agent_result_state,
            verify_result=values["verify_result"],
            archived_evidence=archived_evidence,
            evidence_valid=evidence_valid,
            checker_command=checker_command,
        ))
    checker_code: int | None = None
    pre_checker_environment_invalid = monitor.stop_state in {
        "invalid_agent_session_context", "environment_invalid_candidate_drift",
        "environment_invalid_freeze_drift", "environment_invalid_auth_cleanup",
        "environment_invalid_auth_sanitization", "environment_invalid_service_drift",
    }
    baseline_first_failure = monitor.stop_state == "baseline_first_scoring_failure"
    progress.set_phase("checker", clock())
    if pre_checker_environment_invalid:
        progress.checker_allowed = False
        progress.checker_decision_reason = "environment_invalid"
        progress.write(clock(), force=True)
        ensure_checklist(run_dir, None, "environment invalid; evaluator checker not executed")
    elif baseline_first_failure:
        failed_family = (monitor.first_scoring_failure or {}).get("family")
        failure_reason = (
            "baseline_first_failure_verify_failed"
            if failed_family == "verify"
            else "baseline_first_failure_before_verify")
        progress.checker_allowed = False
        progress.checker_decision_reason = failure_reason
        progress.write(clock(), force=True)
        ensure_checklist(
            run_dir, None,
            (
                "baseline sealed at failed verify; checker not executed"
                if failed_family == "verify"
                else "baseline sealed at first scoring failure before verify; "
                     "checker not executed"
            ),
        )
    elif not checker_gate_ready:
        progress.checker_allowed = False
        progress.checker_decision_reason = checker_gate_reason
        progress.write(clock(), force=True)
        ensure_checklist(
            run_dir, None,
            "delivery prerequisites incomplete; evaluator checker not executed: "
            + ", ".join(checker_gate_missing),
        )
    elif checker_command is not None:
        checker_timeout = None
        if budgets.wall_clock_seconds is not None:
            checker_timeout = budgets.wall_clock_seconds - (clock() - started)
        if checker_timeout is not None and checker_timeout <= 0:
            progress.checker_allowed = False
            progress.checker_decision_reason = "wall_clock_budget_exhausted"
            progress.write(clock(), force=True)
            monitor.stop("budget_exhausted_wall_clock", {
                "observed": round(clock() - started, 3),
                "limit": budgets.wall_clock_seconds,
                "phase": "checker",
            })
            ensure_checklist(run_dir, None, "wall-clock budget exhausted before checker")
        else:
            progress.checker_allowed = True
            progress.checker_decision_reason = "eligible"
            progress.write(clock(), force=True)
            checker_code, checker_timed_out = run_auxiliary(
                expand_checker_command(checker_command, values), project,
                run_dir / "checker-stdout.txt", run_dir / "checker-stderr.txt",
                checker_timeout)
            if checker_timed_out:
                monitor.stop("budget_exhausted_wall_clock", {
                    "observed": round(clock() - started, 3),
                    "limit": budgets.wall_clock_seconds,
                    "phase": "checker",
                })
    else:
        progress.checker_allowed = False
        progress.checker_decision_reason = "checker_not_configured"
        progress.write(clock(), force=True)
        ensure_checklist(run_dir, None, "no checker command configured")
    ensure_checklist(run_dir, checker_code)

    evidence_drifted = False
    if archived_evidence is not None and archived_evidence_sha256 is not None:
        try:
            evidence_drifted = sha256_file(archived_evidence) != archived_evidence_sha256
        except OSError:
            evidence_drifted = True
    if evidence_drifted and monitor.stop_state not in {
        "environment_invalid_auth_cleanup", "invalid_agent_session_context",
        "environment_invalid_auth_sanitization",
        "environment_invalid_candidate_drift", "environment_invalid_freeze_drift",
        "environment_invalid_service_drift",
    }:
        monitor.stop_state = "flow_evidence_archive_drift"
        monitor.stop_detail = {
            "reason": "archived business-flow evidence changed during checker execution",
        }

    ended = clock()
    if monitor.stop_state:
        terminal = monitor.stop_state
    elif agent_code != 0:
        terminal = "agent_process_failed"
    elif not checker_gate_ready:
        terminal = "delivery_incomplete"
    elif checker_code not in (None, 0):
        terminal = "acceptance_failed"
    elif checker_code is None:
        terminal = "acceptance_not_executed"
    else:
        terminal = "completed"
    measurement_complete = terminal in {"completed", "acceptance_failed"}
    environment_invalid = monitor.stop_state in {
        "invalid_agent_session_context", "environment_invalid_candidate_drift",
        "environment_invalid_freeze_drift", "environment_invalid_auth_cleanup",
        "environment_invalid_auth_sanitization", "environment_invalid_service_drift",
        "flow_evidence_archive_drift",
    }
    environment_valid = not environment_invalid
    if terminal == "baseline_first_scoring_failure":
        measurement_boundary = "baseline_first_failure_sealed"
    elif terminal == "delivery_incomplete":
        measurement_boundary = "delivery_incomplete"
    elif measurement_complete:
        measurement_boundary = "full_run_sealed"
    else:
        measurement_boundary = "interrupted_or_invalid"
    lifecycle.update({
        "state": terminal,
        "measurement_complete": measurement_complete,
        "environment_valid": environment_valid,
        "measurement_boundary": measurement_boundary,
        "ended_epoch": ended,
        "usage": {
            "wall_clock_seconds": round(ended - started, 3),
            "total_tokens": monitor.total_tokens,
            "cli_invocations_started": monitor.cli_invocations,
            "cli_invocations_captured": len(artifacts),
            "cli_retries_started": monitor.cli_retries,
        },
        "termination": monitor.stop_detail,
        "first_scoring_failure": monitor.first_scoring_failure,
        "agent_result_state": monitor.agent_result_state,
        "agent_exit_code": agent_code,
        "checker_exit_code": checker_code,
        "checker_gate": {
            "ready": checker_gate_ready,
            "reason": checker_gate_reason,
            "missing": checker_gate_missing,
        },
        "agent_ended_epoch": agent_ended,
        "agent_session_id": session_id,
        "auth_cleanup_status": (
            "failed" if auth_cleanup_error else
            "removed" if auth_source is not None else "not_required"),
        "business_flow_evidence_source": evidence_source,
        "business_flow_evidence_contract_valid": evidence_valid,
        "business_flow_evidence_sha256": archived_evidence_sha256,
        "business_flow_evidence_error": evidence_error,
        "service_identity_before_sha256": canonical_json_sha256(service_before),
        "service_identity_after_sha256": canonical_json_sha256(service_after),
    })
    write_json(run_dir / "lifecycle.json", lifecycle)
    if monitor.total_tokens is not None:
        write_json(run_dir / "tokens.json", {"total_tokens": monitor.total_tokens})
    meta = {
        "benchmark": benchmark,
        "candidate_id": candidate["candidate_id"],
        "skill_version": candidate["skill_version"],
        "model": model,
        "run_id": run_id,
        "run_kind": mode,
        "parent_run_id": parent_run_id,
        "terminal_state": terminal,
        "measurement_complete": measurement_complete,
        "environment_valid": environment_valid,
        "agent_declared_done": monitor.agent_declared_done,
        "agent_result_state": monitor.agent_result_state,
        "human_interventions": 0,
        "started_epoch": started,
        "agent_ended_epoch": agent_ended,
        "ended_epoch": ended,
        "project_path": str(project.resolve()),
        "isolation_root": str(isolation.root),
        "codex_home": str(isolation.codex_home),
        "database_path": str(isolation.database),
        "agent_session_id": session_id,
    }
    write_json(run_dir / "meta.json", meta)
    if not (run_dir / "failures.json").exists():
        raw_failures = failures_from_first_scoring_capture(
            artifacts, monitor.first_scoring_failure, terminal)
        if terminal == "delivery_incomplete" and not raw_failures:
            latest_scoring = next((
                artifact for artifact in reversed(artifacts)
                if artifact.get("family") in SCORING_FAMILIES
            ), None)
            latest_family = (
                latest_scoring.get("family")
                if isinstance(latest_scoring, dict) else None)
            delivery_stage = {
                "model_plan": "model",
                "apply_model": "apply",
                "apply_finalize": "apply",
                "verify": "verify",
            }.get(latest_family, "delivery")
            raw_failures.append({
                "stage": delivery_stage,
                "owner": "agent",
                "note": (
                    "Agent declared EVAL_RESULT state not_done before delivery completed"
                    if monitor.agent_result_state == "not_done"
                    else "Agent exited before delivery prerequisites completed"),
                "terminal_state": terminal,
                "detail": {
                    "agent_result_state": monitor.agent_result_state,
                    "latest_scoring_family": latest_family,
                    "missing_prerequisites": checker_gate_missing,
                },
                "attribution_status": "attributed",
            })
        if terminal != "completed" and not raw_failures:
            raw_failures.append({
                "stage": ((monitor.first_scoring_failure or {}).get("family") or "driver"),
                "owner": None,
                "note": f"evaluator terminal state: {terminal}",
                "terminal_state": terminal,
                "detail": monitor.stop_detail,
                "attribution_status": "pending",
            })
        write_json(run_dir / "failures.json", raw_failures)

    progress.set_phase("scorer", clock())
    progress.lifecycle_state = terminal
    progress.write(clock(), force=True)
    scorer_code, _ = run_auxiliary(
        [sys.executable, str(frozen_scorer), str(run_dir)], Path.cwd(),
        run_dir / "scorer-stdout.txt", run_dir / "scorer-stderr.txt")
    lifecycle["scorer_exit_code"] = scorer_code
    lifecycle["state"] = terminal if scorer_code == 0 else "scorer_failed"
    write_json(run_dir / "lifecycle.json", lifecycle)
    final_now = clock()
    progress.set_phase("terminal", final_now)
    progress.phase_timing["terminal"]["ended_epoch"] = final_now
    progress.lifecycle_state = lifecycle["state"]
    progress.terminal = True
    scorecard = load_json_if_object(run_dir / "scorecard.json")
    progress.scorecard = {
        "available": scorecard is not None,
        "pass_at_1": scorecard.get("pass_at_1") if scorecard else None,
        "run_outcome_pass": scorecard.get("run_outcome_pass") if scorecard else None,
    }
    progress.write(final_now, force=True)
    return 0 if terminal == "completed" and scorer_code == 0 else 1


def positive_number(value: str) -> float:
    parsed = float(value)
    if parsed <= 0:
        raise argparse.ArgumentTypeError("budget must be positive")
    return parsed


def positive_integer(value: str) -> int:
    parsed = int(value)
    if parsed <= 0:
        raise argparse.ArgumentTypeError("budget must be positive")
    return parsed


def nonnegative_integer(value: str) -> int:
    parsed = int(value)
    if parsed < 0:
        raise argparse.ArgumentTypeError("budget must not be negative")
    return parsed


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--run-dir", required=True, type=Path)
    parser.add_argument("--isolation-root", required=True, type=Path)
    parser.add_argument("--benchmark", required=True)
    parser.add_argument("--run-id", required=True)
    parser.add_argument("--candidate-config", required=True, type=Path)
    parser.add_argument("--model", required=True)
    parser.add_argument("--service-timeout", type=positive_number, default=5.0)
    parser.add_argument("--mode", required=True, choices=("baseline", "convergence"))
    parser.add_argument("--parent-run-id")
    parser.add_argument("--prompt", required=True, type=Path)
    parser.add_argument("--agent-command-json", required=True)
    parser.add_argument("--checker-command-json")
    parser.add_argument("--checker-source", type=Path)
    parser.add_argument(
        "--auth-source", type=Path,
        help="trusted Codex auth.json; defaults to caller CODEX_HOME/auth.json for codex",
    )
    parser.add_argument(
        "--flow-evidence-source", type=Path,
        help="structured BF evidence to archive after the Agent exits",
    )
    parser.add_argument("--budget-wall-seconds", type=positive_number)
    parser.add_argument("--budget-total-tokens", type=positive_integer)
    parser.add_argument("--budget-cli-invocations", type=positive_integer)
    parser.add_argument("--budget-cli-retries", type=nonnegative_integer)
    args = parser.parse_args()
    try:
        agent = command_from_json(args.agent_command_json, required=True)
        checker = command_from_json(args.checker_command_json)
        return execute_run(
            run_dir=args.run_dir,
            isolation_root=args.isolation_root,
            benchmark=args.benchmark,
            run_id=args.run_id,
            candidate_config=args.candidate_config,
            model=args.model,
            mode=args.mode,
            parent_run_id=args.parent_run_id,
            prompt_source=args.prompt,
            agent_command=agent or [],
            checker_command=checker,
            checker_source=args.checker_source,
            auth_source=args.auth_source,
            service_timeout=args.service_timeout,
            flow_evidence_source=args.flow_evidence_source,
            budgets=Budgets(
                wall_clock_seconds=args.budget_wall_seconds,
                total_tokens=args.budget_total_tokens,
                cli_invocations=args.budget_cli_invocations,
                cli_retries=args.budget_cli_retries,
            ),
        )
    except (OSError, ValueError, json.JSONDecodeError) as error:
        parser.error(str(error))
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
