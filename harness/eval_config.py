#!/usr/bin/env python3
"""Resolve the installed Builder Skill from its authoritative identity manifest."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


REPOSITORY = Path(__file__).resolve().parent.parent
DEFAULT_CONFIG = REPOSITORY / "config.json"


def load(path: Path = DEFAULT_CONFIG) -> dict[str, str]:
    config = json.loads(path.read_text(encoding="utf-8"))
    identity_path = Path(config["skill_identity"]).expanduser().resolve(strict=True)
    identity = json.loads(identity_path.read_text(encoding="utf-8"))
    skill_name = identity.get("skill_name")
    if identity.get("contract_version") != "domainry-builder-skill-identity-v1":
        raise ValueError("unsupported Builder Skill identity contract")
    if not isinstance(skill_name, str) or not skill_name or "/" in skill_name:
        raise ValueError("Builder Skill name must be one path segment")
    install_parent = Path(config["skill_install_parent"]).expanduser().resolve()
    skill_root = install_parent / skill_name
    cli_relative = Path(config["cli_relative"])
    if cli_relative.is_absolute() or ".." in cli_relative.parts:
        raise ValueError("Builder CLI path must be a safe Skill-relative path")
    return {
        **config,
        "skill_name": skill_name,
        "skill_root": str(skill_root),
        "cli": str(skill_root / cli_relative),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", type=Path, default=DEFAULT_CONFIG)
    parser.add_argument("--field", choices=("skill_name", "skill_root", "cli", "plane_repo", "plane_url"))
    parser.add_argument("--json", action="store_true")
    arguments = parser.parse_args()
    resolved = load(arguments.config)
    if arguments.field:
        print(resolved[arguments.field])
    else:
        print(json.dumps(resolved, sort_keys=True, separators=(",", ":")))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
