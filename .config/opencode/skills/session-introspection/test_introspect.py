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
            mock.patch.object(introspect, "bridge_v2"),
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


class V2Tests(unittest.TestCase):
    def test_v2_messages_and_tool_spans_are_visible_without_modifying_storage(self):
        db = introspect.sqlite3.connect(":memory:")
        db.row_factory = introspect.sqlite3.Row
        db.execute("""CREATE TABLE session_v2 (
            id TEXT,parent_id TEXT,title TEXT,directory TEXT,time_created INTEGER,cost REAL,
            tokens_input INTEGER,tokens_output INTEGER,tokens_reasoning INTEGER,
            tokens_cache_read INTEGER,tokens_cache_write INTEGER)""")
        db.execute("INSERT INTO session_v2 VALUES ('ses_root',NULL,'Title','/project',1000,0,10,20,0,0,0)")
        db.execute("CREATE TABLE session_message (id TEXT,session_id TEXT,type TEXT,time_created INTEGER,data TEXT)")
        message = {
            "type": "assistant", "finish": "stop", "time": {"created": 1000, "completed": 4000},
            "content": [{"type": "tool", "name": "shell", "time": {"created": 2000, "ran": 2500, "completed": 3000},
                         "state": {"status": "completed", "input": {"command": "pwd"}}}],
        }
        db.execute("INSERT INTO session_message VALUES ('msg_one','ses_root','assistant',1000,?)", (json.dumps(message),))
        introspect.bridge_v2(db)
        self.assertEqual(introspect.resolve_roots(db, ["ses_root"]), [("Title", "ses_root")])
        self.assertEqual(introspect.tree_metrics(db, ["ses_root"])["tin"], 10)
        self.assertEqual(introspect.merged_timeline(db, ["ses_root"]), [1, 2, 4])
        self.assertEqual(introspect.tool_spans(db, ["ses_root"]), [(2.5, 3, "shell")])
        self.assertEqual(json.loads(db.execute("SELECT data FROM main.session_message").fetchone()[0]), message)
        db.close()
