import importlib.util
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "harness"))
SPEC = importlib.util.spec_from_file_location("preflight", ROOT / "harness/preflight.py")
MOD = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MOD)


def test_health_requires_all_declared_dependencies():
    passed, diagnostics = MOD.assess_health(503, {
        "contract_version": "domainry-control-plane-health-v1",
        "status": "unhealthy",
        "checks": [{"name": "runtime_contract", "status": "failed"}],
    })
    assert passed is False
    assert "service.health_http_503" in diagnostics
    assert "service.check_failed:runtime_contract" in diagnostics


def test_healthy_contract_passes():
    passed, diagnostics = MOD.assess_health(200, {
        "contract_version": "domainry-control-plane-health-v1",
        "status": "healthy",
        "checks": [{"name": "runtime_contract", "status": "passed"}],
    })
    assert passed is True
    assert diagnostics == []


def test_newer_application_delivery_is_candidate_mutation_risk():
    health = {
        "version": "v0.3.15-dirty",
        "checks": [{
            "name": "application_delivery",
            "status": "passed",
            "detail": "v0.3.15-dirty",
        }],
    }
    assert MOD.assess_candidate_update_risk(
        "v0.3.6-54-project-navigation-20260906", health
    ) == ["service.application_delivery_newer_than_candidate"]
    assert MOD.assess_candidate_update_risk(
        "v0.3.16-1-m1-elapsed-time-20260906", health
    ) == []


def test_semver_comparison_matches_cli_prerelease_rules():
    release = MOD.parse_semver("v1.2.3")
    prerelease = MOD.parse_semver("v1.2.3-rc.2")
    later_prerelease = MOD.parse_semver("v1.2.3-rc.10")
    assert release is not None and prerelease is not None and later_prerelease is not None
    assert MOD.compare_semver(release, prerelease) > 0
    assert MOD.compare_semver(later_prerelease, prerelease) > 0
