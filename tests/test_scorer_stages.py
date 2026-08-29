import importlib.util
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("scorer", ROOT / "harness/scorer.py")
MOD = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MOD)


def test_c5_has_only_the_five_builder_stages():
    assert MOD.C5_STAGES == ("requirements", "model", "apply", "implement", "verify")


def test_unknown_stage_is_not_emitted():
    result = MOD.normalize_stage_seconds({
        "verify": {"started": 10, "ended": 20},
        "acceptance": {"started": 20, "ended": 30},
    })
    assert result == {
        "requirements": None,
        "model": None,
        "apply": None,
        "implement": None,
        "verify": 10,
    }
