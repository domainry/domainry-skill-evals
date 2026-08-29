import importlib.util
from pathlib import Path
import sqlite3


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("run_m1_baseline", ROOT / "harness/run_m1_baseline.py")
MOD = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MOD)


def test_fresh_cohort_requires_exact_seed_count(tmp_path):
    db = tmp_path / "runtime.db"
    with sqlite3.connect(db) as conn:
        conn.execute("CREATE TABLE lead (id TEXT PRIMARY KEY)")
        conn.executemany("INSERT INTO lead(id) VALUES (?)", [("a",), ("b",)])
    MOD.assert_fresh_sqlite(db, "lead", 2)
    try:
        MOD.assert_fresh_sqlite(db, "lead", 1)
    except RuntimeError as exc:
        assert "acceptance residue" in str(exc)
    else:
        raise AssertionError("dirty cohort was accepted")


def test_feature_mapping_covers_frozen_denominator():
    assert set(MOD.FEATURES) == {f"M{i:02d}" for i in range(1, 20)}
    assert set(MOD.FLOW_TESTS) == {f"BF{i:02d}" for i in range(1, 9)}


def test_fresh_cohort_uses_manifest_derived_lead_table(tmp_path):
    db = tmp_path / "runtime.db"
    with sqlite3.connect(db) as conn:
        conn.execute("CREATE TABLE sales_lead (id TEXT PRIMARY KEY)")
        conn.execute("INSERT INTO sales_lead(id) VALUES ('seed')")
    MOD.assert_fresh_sqlite(db, "sales_lead", 1)


def test_composed_businessflow_may_satisfy_multiple_frozen_flows():
    aliases = {key for key, names in MOD.FLOW_TESTS.items()
               if "TestBF05DirectorFunnelAuthorization" in names}
    assert aliases == {"BF07", "BF08"}
