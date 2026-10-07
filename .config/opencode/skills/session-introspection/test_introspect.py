import io
import json
import unittest
from unittest import mock

import introspect


class ExportTests(unittest.TestCase):
    def test_json_export_keeps_same_titled_sessions_separate(self):
        output = io.StringIO()
        db = mock.Mock()
        roots = [("Same title", "ses_one"), ("Same title", "ses_two")]
        with (
            mock.patch("sys.argv", ["introspect.py", "--session", "ses_one", "ses_two", "--json"]),
            mock.patch("sys.stdout", output),
            mock.patch.object(introspect.sqlite3, "connect", return_value=db),
            mock.patch.object(introspect, "resolve_roots", return_value=roots),
            mock.patch.object(introspect, "descendants", side_effect=lambda db, sid: [sid]),
            mock.patch.object(introspect, "scan_log", return_value=({}, None)) as scan,
            mock.patch.object(introspect, "analyze_tree", side_effect=lambda db, title, sid, asks, key, threshold: {"root_id": sid, "tree_key": key}),
        ):
            introspect.main()
        self.assertEqual(scan.call_args.args[1], {"ses_one": {"ses_one"}, "ses_two": {"ses_two"}})
        self.assertEqual(json.loads(output.getvalue())["results"], [
            {"root_id": "ses_one", "tree_key": "ses_one"},
            {"root_id": "ses_two", "tree_key": "ses_two"},
        ])
        db.close.assert_called_once()
