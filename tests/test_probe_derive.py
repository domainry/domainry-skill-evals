import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from harness.probe_derive import (
    DeriveError,
    _s1_status_report_key,
    _s1_writable_ticket_fields,
)


class S1ProbeDerivationTest(unittest.TestCase):
    def test_excludes_runtime_owned_create_fields(self):
        manifest = {
            "state_machines": [{
                "object_key": "ticket",
                "field_key": "status",
            }],
        }
        ticket = {"fields": [
            {"key": "title"},
            {"key": "priority"},
            {"key": "status"},
            {"key": "assignee_user_id", "config": {
                "auto_assign_current_user": True,
                "scope_owner": True,
            }},
            {"key": "owner_department_id"},
            {"key": "owner_department_path"},
            {"key": "assignee_profile_id"},
        ]}

        writable, runtime_owned = _s1_writable_ticket_fields(manifest, ticket)

        self.assertEqual(writable, ["title", "priority", "assignee_profile_id"])
        self.assertEqual(runtime_owned, {
            "status", "assignee_user_id",
            "owner_department_id", "owner_department_path",
        })

    def test_derives_unique_ticket_status_report(self):
        manifest = {"reports": [
            {"key": "unrelated_report"},
            {"key": "ticket_status_counts"},
        ]}
        self.assertEqual(
            _s1_status_report_key(manifest), "ticket_status_counts")

    def test_rejects_ambiguous_reports(self):
        with self.assertRaises(DeriveError):
            _s1_status_report_key({"reports": [
                {"key": "ticket_status_daily"},
                {"key": "ticket_status_monthly"},
            ]})


if __name__ == "__main__":
    unittest.main()
