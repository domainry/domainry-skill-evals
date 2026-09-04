#!/usr/bin/env python3
"""Resolve and verify the installed Builder Skill used as the candidate.

The evaluator deliberately knows no Skill or Domainry Plane source checkout.
All candidate identity comes from the installed, packaged Skill root named in
``config.json``. A run freezes this identity before the Agent starts and
verifies it again after the Agent exits.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
from urllib.parse import urlparse


REPOSITORY = Path(__file__).resolve().parent.parent
DEFAULT_CONFIG = REPOSITORY / "config.json"
IDENTITY_CONTRACT = "domainry-builder-skill-identity-v1"
PACKAGE_CONTRACT = "domainry-builder-skill-package-v1"
TARGET_FLAGS = {"--environment", "--service"}
CONFIG_KEYS = {"note", "candidate_skill_root", "cli_relative", "apply_target", "cli_note"}
SHA256_PATTERN = re.compile(r"[0-9a-f]{64}")


def sha256(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest()


def installed_tree_sha256(root: Path, package_name: str) -> str:
    """Reproduce the package installer's path/content tree identity."""
    files: dict[str, bytes] = {}
    for path in root.rglob("*"):
        relative = path.relative_to(root)
        if path.is_symlink():
            raise ValueError(f"candidate Skill contains symlink: {relative}")
        if (not path.is_file() or relative.as_posix() == package_name
                or "__pycache__" in relative.parts or path.suffix == ".pyc"):
            continue
        files[relative.as_posix()] = path.read_bytes()
    digest = hashlib.sha256()
    for relative in sorted(files):
        digest.update(relative.encode("utf-8"))
        digest.update(b"\0")
        digest.update(sha256(files[relative]).encode("ascii"))
        digest.update(b"\n")
    return digest.hexdigest()


def validate_target(raw: object) -> tuple[str, str]:
    if not isinstance(raw, dict) or set(raw) != {"flag", "value"}:
        raise ValueError("apply_target must contain exactly flag and value")
    flag, value = raw.get("flag"), raw.get("value")
    if flag not in TARGET_FLAGS or not isinstance(value, str) or not value:
        raise ValueError("apply_target is invalid")
    if flag == "--environment" and value not in {"local", "dev", "stage", "online"}:
        raise ValueError("apply_target environment is invalid")
    if flag == "--service":
        parsed = urlparse(value)
        if (
            parsed.scheme not in {"http", "https"}
            or not parsed.hostname
            or parsed.username is not None
            or parsed.password is not None
            or parsed.path not in {"", "/"}
            or parsed.params
            or parsed.query
            or parsed.fragment
        ):
            raise ValueError("apply_target service URL is invalid")
    return flag, value


def load(path: Path = DEFAULT_CONFIG, candidate_skill_root: Path | None = None) -> dict[str, object]:
    config = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(config, dict) or not set(config) <= CONFIG_KEYS:
        raise ValueError("config contains unsupported keys; source checkout settings are forbidden")
    root_value = candidate_skill_root or config.get("candidate_skill_root")
    if not isinstance(root_value, (str, Path)) or not str(root_value):
        raise ValueError("candidate_skill_root is required")
    configured_root = Path(root_value).expanduser()
    if configured_root.is_symlink():
        raise ValueError("candidate Skill root must not be a symlink")
    skill_root = configured_root.resolve(strict=True)
    if not skill_root.is_dir():
        raise ValueError("candidate Skill root must be a real directory")

    identity_path = skill_root / "skill-identity.json"
    identity_raw = identity_path.read_bytes()
    identity = json.loads(identity_raw)
    if identity.get("contract_version") != IDENTITY_CONTRACT:
        raise ValueError("unsupported Builder Skill identity contract")
    skill_name = identity.get("skill_name")
    if not isinstance(skill_name, str) or not skill_name or "/" in skill_name:
        raise ValueError("Builder Skill name must be one path segment")
    if skill_root.name != skill_name:
        raise ValueError("candidate Skill root name differs from packaged identity")

    package_name = identity.get("package_metadata_filename")
    if not isinstance(package_name, str) or Path(package_name).name != package_name:
        raise ValueError("Builder Skill package metadata filename is invalid")
    package_path = skill_root / package_name
    package = json.loads(package_path.read_text(encoding="utf-8"))
    cli_relative = Path(str(config.get("cli_relative", "")))
    if cli_relative.is_absolute() or ".." in cli_relative.parts or not cli_relative.parts:
        raise ValueError("Builder CLI path must be a safe Skill-relative path")
    cli = skill_root / cli_relative
    skill_document = skill_root / "SKILL.md"

    actual_tree_sha256 = installed_tree_sha256(skill_root, package_name)
    runtime_contract_version = package.get("runtime_api_contract_version")
    runtime_contract_hash = package.get("runtime_api_contract_hash")
    if (
        package.get("contract_version") != PACKAGE_CONTRACT
        or package.get("skill_name") != skill_name
        or package.get("skill_identity_contract_version") != IDENTITY_CONTRACT
        or package.get("skill_identity_sha256") != sha256(identity_raw)
        or package.get("entrypoint") != cli_relative.as_posix()
        or package.get("skill_tree_sha256") != actual_tree_sha256
        or not isinstance(package.get("version"), str)
        or not package.get("version")
        or not skill_document.is_file()
        or skill_document.is_symlink()
        or not cli.is_file()
        or cli.is_symlink()
        or not os.access(cli, os.X_OK)
        or package.get("cli_binary_sha256") != sha256(cli.read_bytes())
        or not isinstance(runtime_contract_version, str)
        or not runtime_contract_version
        or not isinstance(runtime_contract_hash, str)
        or SHA256_PATTERN.fullmatch(runtime_contract_hash) is None
    ):
        raise ValueError("installed Builder Skill package identity closure differs")

    target_flag, target_value = validate_target(config.get("apply_target"))
    candidate_id = f"{package['version']}+{actual_tree_sha256[:12]}"
    return {
        "candidate_id": candidate_id,
        "skill_name": skill_name,
        "skill_root": str(skill_root),
        "cli": str(cli),
        "skill_version": package["version"],
        "skill_identity_sha256": sha256(identity_raw),
        "package_metadata_sha256": sha256(package_path.read_bytes()),
        "skill_tree_sha256": actual_tree_sha256,
        "cli_binary_sha256": package["cli_binary_sha256"],
        "runtime_api_contract_version": runtime_contract_version,
        "runtime_api_contract_hash": runtime_contract_hash,
        "apply_target_flag": target_flag,
        "apply_target_value": target_value,
        "apply_target_args": [target_flag, target_value],
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", type=Path, default=DEFAULT_CONFIG)
    parser.add_argument("--candidate-skill-root", type=Path,
                        help="validate an isolated copy with the same evaluator config")
    parser.add_argument("--field", choices=(
        "candidate_id", "skill_name", "skill_root", "cli", "skill_version",
        "skill_identity_sha256", "package_metadata_sha256", "skill_tree_sha256",
        "cli_binary_sha256", "runtime_api_contract_version", "runtime_api_contract_hash",
        "apply_target_flag", "apply_target_value",
    ))
    parser.add_argument("--json", action="store_true")
    arguments = parser.parse_args()
    resolved = load(arguments.config, arguments.candidate_skill_root)
    if arguments.field:
        print(resolved[arguments.field])
    else:
        print(json.dumps(resolved, sort_keys=True, separators=(",", ":")))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
