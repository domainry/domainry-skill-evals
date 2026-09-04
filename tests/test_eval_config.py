import hashlib
import importlib.util
import json
from pathlib import Path

import pytest


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("eval_config", ROOT / "harness/eval_config.py")
eval_config = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(eval_config)


def write_candidate(tmp_path: Path) -> tuple[Path, Path]:
    root = tmp_path / "skills" / "domainry-builder-v1"
    (root / "bin").mkdir(parents=True)
    identity = {
        "contract_version": "domainry-builder-skill-identity-v1",
        "skill_name": "domainry-builder-v1",
        "package_metadata_filename": "skill-package.json",
    }
    identity_raw = json.dumps(identity, separators=(",", ":")).encode()
    (root / "skill-identity.json").write_bytes(identity_raw)
    (root / "SKILL.md").write_text("candidate\n")
    cli = root / "bin" / "domainry-cli"
    cli.write_bytes(b"#!/bin/sh\nexit 0\n")
    cli.chmod(0o755)
    tree = eval_config.installed_tree_sha256(root, "skill-package.json")
    package = {
        "contract_version": "domainry-builder-skill-package-v1",
        "skill_name": "domainry-builder-v1",
        "skill_identity_contract_version": "domainry-builder-skill-identity-v1",
        "skill_identity_sha256": hashlib.sha256(identity_raw).hexdigest(),
        "entrypoint": "bin/domainry-cli",
        "skill_tree_sha256": tree,
        "cli_binary_sha256": hashlib.sha256(cli.read_bytes()).hexdigest(),
        "version": "test-v1",
        "runtime_api_contract_version": "runtime-domain-api-v1",
        "runtime_api_contract_hash": "a" * 64,
    }
    (root / "skill-package.json").write_text(json.dumps(package))
    config = tmp_path / "config.json"
    config.write_text(json.dumps({
        "candidate_skill_root": str(root),
        "cli_relative": "bin/domainry-cli",
        "apply_target": {"flag": "--service", "value": "http://127.0.0.1:8283"},
    }))
    return root, config


def test_load_uses_only_installed_candidate(tmp_path):
    root, config = write_candidate(tmp_path)
    resolved = eval_config.load(config)
    assert resolved["skill_root"] == str(root)
    assert resolved["skill_version"] == "test-v1"
    assert resolved["apply_target_args"] == ["--service", "http://127.0.0.1:8283"]
    assert not any("repo" in key for key in resolved)


def test_load_rejects_installed_tree_drift(tmp_path):
    root, config = write_candidate(tmp_path)
    (root / "SKILL.md").write_text("tampered\n")
    with pytest.raises(ValueError, match="identity closure"):
        eval_config.load(config)


def test_load_rejects_external_identity_shape(tmp_path):
    root, config = write_candidate(tmp_path)
    raw = json.loads(config.read_text())
    raw["skill_identity"] = "/source/repo/skill-identity.json"
    raw["candidate_skill_root"] = str(root)
    config.write_text(json.dumps(raw))
    with pytest.raises(ValueError, match="unsupported keys"):
        eval_config.load(config)


def test_load_rejects_symlink_candidate_root(tmp_path):
    root, config = write_candidate(tmp_path)
    linked = tmp_path / "linked-candidate"
    linked.symlink_to(root, target_is_directory=True)
    raw = json.loads(config.read_text())
    raw["candidate_skill_root"] = str(linked)
    config.write_text(json.dumps(raw))
    with pytest.raises(ValueError, match="must not be a symlink"):
        eval_config.load(config)


def test_load_can_revalidate_isolated_copy(tmp_path):
    root, config = write_candidate(tmp_path)
    resolved = eval_config.load(config, root)
    assert resolved["skill_root"] == str(root)
    assert len(resolved["package_metadata_sha256"]) == 64
