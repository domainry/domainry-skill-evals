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
