"""Isolated checks; never opens the real OpenCode history."""

import importlib.machinery
import json
import sqlite3
import tempfile
import types
import unittest
from pathlib import Path
from unittest import mock


loader = importlib.machinery.SourceFileLoader(
    "opencode_session", str(Path(__file__).with_name("opencode-session"))
)
oc = types.ModuleType(loader.name)
loader.exec_module(oc)


class SessionTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name).resolve()
        self.data = self.home / ".local/share/opencode"
        self.data.mkdir(parents=True)
        self.path = self.data / "opencode.db"
        with sqlite3.connect(self.path) as db:
            db.executescript("""
                PRAGMA foreign_keys=ON;
                CREATE TABLE session (id TEXT PRIMARY KEY, parent_id TEXT, title TEXT, directory TEXT, time_created INTEGER, time_updated INTEGER);
                CREATE TABLE session_v2 (id TEXT PRIMARY KEY, parent_id TEXT, title TEXT, directory TEXT, time_created INTEGER, time_updated INTEGER);
                CREATE TABLE message (id TEXT PRIMARY KEY, session_id TEXT REFERENCES session(id) ON DELETE CASCADE, data TEXT);
                CREATE TABLE part (id TEXT PRIMARY KEY, message_id TEXT REFERENCES message(id) ON DELETE CASCADE, session_id TEXT, time_created INTEGER, data TEXT);
                CREATE TABLE session_message (id TEXT PRIMARY KEY, session_id TEXT REFERENCES session_v2(id) ON DELETE CASCADE, type TEXT, time_created INTEGER, data TEXT);
                CREATE TABLE todo (session_id TEXT REFERENCES session(id) ON DELETE CASCADE, content TEXT);
                CREATE TABLE session_input (session_id TEXT REFERENCES session_v2(id) ON DELETE CASCADE, prompt TEXT);
                CREATE TABLE session_context_epoch (session_id TEXT REFERENCES session_v2(id) ON DELETE CASCADE, snapshot TEXT);
                CREATE TABLE session_share (session_id TEXT REFERENCES session(id) ON DELETE CASCADE, url TEXT);
                CREATE TABLE event_sequence (aggregate_id TEXT PRIMARY KEY);
                CREATE TABLE event (aggregate_id TEXT REFERENCES event_sequence(aggregate_id) ON DELETE CASCADE, data TEXT);
                CREATE TABLE future_session_cache (session_id TEXT, data TEXT);
            """)
            db.executemany(
                "INSERT INTO session VALUES (?, ?, ?, ?, ?, ?)",
                [
                    ("ses_root", None, "MJÖLNIR migration", "/home/user", 1, 2),
                    (
                        "ses_child",
                        "ses_root",
                        "Database work",
                        "/scattered/folder",
                        3,
                        4,
                    ),
                    ("ses_other", None, "Unrelated", "/home/user", 5, 6),
                ],
            )
            db.execute(
                "INSERT INTO session_v2 VALUES ('ses_grandchild', 'ses_child', 'V2 migration', '/another/folder', 7, 8)"
            )
            for mid, sid, role, text in [
                ("msg_user", "ses_root", "user", "Please migrate Mjölnir."),
                ("msg_assistant", "ses_root", "assistant", "Migration complete."),
                ("msg_child", "ses_child", "user", "Update the database."),
                ("msg_other", "ses_other", "user", "Fix calendar sync."),
            ]:
                data = {"role": role}
                if role == "assistant":
                    data["tokens"] = {
                        "input": 1,
                        "output": 2,
                        "cache": {"read": 0, "write": 0},
                    }
                db.execute(
                    "INSERT INTO message VALUES (?, ?, ?)", (mid, sid, json.dumps(data))
                )
                db.execute(
                    "INSERT INTO part VALUES (?, ?, ?, 10, ?)",
                    (
                        "prt_" + mid,
                        mid,
                        sid,
                        json.dumps({"type": "text", "text": text}),
                    ),
                )
            db.execute(
                "INSERT INTO part VALUES ('prt_tool', 'msg_other', 'ses_other', 11, ?)",
                (
                    json.dumps(
                        {
                            "type": "tool",
                            "state": {
                                "output": "A config mentions mjölnir incidentally."
                            },
                        }
                    ),
                ),
            )
            v2 = {
                "model": {"id": "test", "providerID": "test"},
                "tokens": {"input": 3, "output": 4},
                "content": [
                    {"type": "text", "text": "Deploy MJÖLNIR."},
                    {
                        "type": "tool",
                        "state": {
                            "input": {"command": "mjölnir deploy"},
                            "content": [{"type": "text", "text": "mjölnir deployed"}],
                        },
                    },
                ],
            }
            db.execute(
                "INSERT INTO session_message VALUES ('msg_v2', 'ses_grandchild', 'assistant', 12, ?)",
                (json.dumps(v2),),
            )
            db.execute(
                "INSERT INTO session_message VALUES ('msg_v2user', 'ses_grandchild', 'user', 13, ?)",
                (json.dumps({"text": "Check the Mjölnir deployment."}),),
            )
            for sid in ("ses_root", "ses_child", "ses_grandchild", "ses_other"):
                db.execute("INSERT INTO event_sequence VALUES (?)", (sid,))
                db.execute("INSERT INTO event VALUES (?, 'history')", (sid,))
                db.execute(
                    "INSERT INTO future_session_cache VALUES (?, 'cache')", (sid,)
                )
            db.execute("INSERT INTO todo VALUES ('ses_root', 'migration')")
            db.execute("INSERT INTO session_share VALUES ('ses_root', 'share')")
            db.execute("INSERT INTO session_input VALUES ('ses_grandchild', 'prompt')")
            db.execute(
                "INSERT INTO session_context_epoch VALUES ('ses_grandchild', 'snapshot')"
            )
        self.report = {
            "groupBy": "session,model",
            "entries": [
                {"sessionId": "ses_root", "cost": 1.1},
                {"sessionId": "ses_root", "cost": 0.2},
                {"sessionId": "ses_child", "cost": 2.2},
                {"sessionId": "ses_grandchild", "cost": 3.3},
                {"sessionId": "ses_other", "cost": 100},
            ],
        }

    def history(self, writable=False):
        history = oc.History(self.home, writable=writable)
        self.addCleanup(history.close)
        return history

    def write_json(self, relative, data):
        path = self.data / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(data))
        return path

    def search(self, history, query="mjölnir", sources=(), offset=0, limit=50):
        return oc.search(
            history,
            types.SimpleNamespace(
                query=query,
                source=sources,
                offset=offset,
                limit=limit,
                roots_only=False,
            ),
        )

    def price(self, history, roots, report=None):
        result = types.SimpleNamespace(
            returncode=0, stdout=json.dumps(report or self.report), stderr=""
        )
        with mock.patch.object(oc.subprocess, "run", return_value=result) as run:
            priced = oc.price(history, roots)
            command = run.call_args.args[0]
            self.assertEqual(command[:3], ["npx", "--yes", "tokscale@latest"])
            self.assertIn("session,model", command)
            self.assertEqual(command[-2:], ["--home", str(self.home)])
            run.assert_called_once()
            return priced

    def test_search_unicode_literal_sources_and_pagination(self):
        history = self.history()
        result = self.search(history)
        sessions = {s["id"]: s for s in result["sessions"]}
        self.assertEqual(set(sessions), {"ses_root", "ses_grandchild", "ses_other"})
        self.assertIn("title", {m["source"] for m in sessions["ses_root"]["matches"]})
        self.assertIn("user", {m["source"] for m in sessions["ses_root"]["matches"]})
        self.assertEqual(
            {m["source"] for m in sessions["ses_other"]["matches"]}, {"tool_output"}
        )
        users = self.search(history, sources=["user"])
        self.assertEqual(
            {s["id"] for s in users["sessions"]}, {"ses_root", "ses_grandchild"}
        )
        self.assertEqual(self.search(history, "mjölnir.*")["total_sessions"], 0)
        self.assertEqual(
            self.search(history, "scattered", ["directory"])["sessions"][0]["id"],
            "ses_child",
        )
        page = self.search(history, offset=1, limit=1)
        self.assertEqual(page["total_sessions"], 3)
        self.assertEqual(len(page["sessions"]), 1)

    def test_show_tree_and_v2_tool_content(self):
        history = self.history()
        args = types.SimpleNamespace(
            session_ids=["ses_root"], tree=True, offset=0, limit=100, source=[]
        )
        result = oc.show(history, args)
        self.assertEqual(
            {s["id"] for s in result["descendants"]}, {"ses_child", "ses_grandchild"}
        )
        self.assertEqual(
            {i["session_id"] for i in result["items"]},
            {"ses_root", "ses_child", "ses_grandchild"},
        )
        output = [i for i in result["items"] if i["source"] == "tool_output"]
        self.assertEqual(output[0]["text"], "mjölnir deployed")
        args.tree = False
        self.assertEqual(
            {i["session_id"] for i in oc.show(history, args)["items"]}, {"ses_root"}
        )

    def test_root_search_and_batch_show_source_filter(self):
        history = self.history()
        result = oc.search(
            history,
            types.SimpleNamespace(
                query="mjölnir", source=[], roots_only=True, offset=1, limit=1
            ),
        )
        self.assertEqual(result["total_sessions"], 2)
        self.assertEqual(result["sessions"][0]["id"], "ses_root")
        result = oc.show(
            history,
            types.SimpleNamespace(
                session_ids=["ses_root", "ses_other", "ses_root"],
                tree=False,
                source=["user"],
                offset=0,
                limit=100,
            ),
        )
        self.assertEqual(
            [s["id"] for s in result["sessions"]], ["ses_root", "ses_other"]
        )
        self.assertEqual(
            [i["text"] for i in result["items"]],
            ["Fix calendar sync.", "Please migrate Mjölnir."],
        )

    def test_inventory_selection_and_validation(self):
        path = self.write_json(
            "inventory.json",
            {
                "sessions": [
                    {"id": "ses_root", "category": "migration"},
                    {"id": "ses_child", "category": "migration", "include": False},
                    {"id": "ses_other", "category": "peer_review"},
                    {"id": "ses_root", "category": "migration"},
                ]
            },
        )
        self.assertEqual(oc.inventory_ids(path), ["ses_root", "ses_other"])
        self.assertEqual(oc.inventory_ids(path, ["migration"]), ["ses_root"])
        self.assertEqual(oc.inventory_ids(path, ["missing"]), [])
        with (
            mock.patch(
                "sys.argv",
                [
                    "opencode-session",
                    "--home",
                    str(self.home),
                    "show",
                    "--sessions-file",
                    str(path),
                    "--category",
                    "migration",
                    "--source",
                    "user",
                    "--json",
                ],
            ),
            mock.patch("builtins.print") as output,
        ):
            oc.main()
        shown = json.loads(output.call_args.args[0])
        self.assertEqual(shown["session"]["id"], "ses_root")
        self.assertEqual(
            [i["text"] for i in shown["items"]], ["Please migrate Mjölnir."]
        )
        for data in (
            [],
            {"sessions": [{}]},
            {"sessions": [{"id": "ses_root", "include": "false"}]},
        ):
            path.write_text(json.dumps(data))
            with self.assertRaises(ValueError):
                oc.inventory_ids(path)

    def test_prices_models_trees_and_overlaps_once(self):
        result = self.price(self.history(), ["ses_root", "ses_child", "ses_root"])
        self.assertEqual([e["price"] for e in result["entries"]], [6.8, 5.5])
        self.assertEqual(result["total"], 6.8)
        self.assertEqual(len(result["entries"]), 2)

    def test_missing_and_failed_pricing_is_not_zero(self):
        history = self.history()
        report = {"groupBy": "session,model", "entries": []}
        with self.assertRaisesRegex(ValueError, "refusing to report"):
            self.price(history, ["ses_root"], report)
        result = types.SimpleNamespace(returncode=1, stdout="", stderr="pricing failed")
        with mock.patch.object(oc.subprocess, "run", return_value=result):
            with self.assertRaisesRegex(ValueError, "pricing failed"):
                oc.price(history, ["ses_root"])
        with mock.patch.object(oc.subprocess, "run") as run:
            with self.assertRaisesRegex(ValueError, "Session not found"):
                oc.price(history, ["ses_missing"])
            run.assert_not_called()

    def test_zero_cost_usage_is_explicit(self):
        self.report["entries"][0].update(cost=0, input=100)
        result = self.price(self.history(), ["ses_root"])
        self.assertEqual(result["zero_cost_usage"], ["ses_root"])

    def test_legacy_copies_and_channel_copies_are_deduplicated(self):
        self.write_json(
            "storage/session/global/ses_root.json",
            {"id": "ses_root", "title": "Old title", "time": {"updated": 1}},
        )
        self.write_json(
            "storage/message/ses_root/msg_user.json", {"id": "msg_user", "role": "user"}
        )
        self.write_json(
            "storage/part/msg_user/prt_text.json",
            {"type": "text", "text": "Please migrate Mjölnir."},
        )
        source = sqlite3.connect(self.path)
        copy = sqlite3.connect(self.data / "opencode-dev.db")
        source.backup(copy)
        source.close()
        copy.close()
        history = self.history()
        result = self.search(history, sources=["user"])
        root = next(s for s in result["sessions"] if s["id"] == "ses_root")
        self.assertEqual(root["match_count"], 1)
        self.assertEqual(root["title"], "MJÖLNIR migration")
        self.assertEqual(len(root["locations"]), 3)

    def test_delete_dry_run_then_purges_tree_and_legacy(self):
        session_file = self.write_json(
            "storage/session/global/ses_root.json", {"id": "ses_root"}
        )
        self.write_json(
            "storage/message/ses_root/msg_user.json", {"id": "msg_user", "role": "user"}
        )
        self.write_json("storage/part/msg_user/prt_text.json", {"text": "migration"})
        diff = self.write_json("storage/session_diff/ses_child.json", [])
        untouched = self.write_json("storage/session_diff/ses_other.json", [])
        dry = oc.delete(self.history(), ["ses_root"], dry_run=True)
        self.assertEqual(
            set(dry["session_ids"]), {"ses_root", "ses_child", "ses_grandchild"}
        )
        self.assertTrue(session_file.exists())
        history = self.history(writable=True)
        oc.delete(history, ["ses_root", "ses_child"])
        self.assertFalse(session_file.exists())
        self.assertFalse(diff.exists())
        self.assertFalse((self.data / "storage/message/ses_root").exists())
        self.assertFalse((self.data / "storage/part/msg_user").exists())
        self.assertTrue(untouched.exists())
        with sqlite3.connect(self.path) as db:
            self.assertEqual(
                db.execute("SELECT id FROM session").fetchall(), [("ses_other",)]
            )
            for table in (
                "session_v2",
                "session_message",
                "session_input",
                "session_context_epoch",
                "todo",
                "session_share",
            ):
                self.assertEqual(
                    db.execute(f"SELECT count(*) FROM {table}").fetchone()[0], 0
                )
            for table in ("event", "event_sequence", "future_session_cache"):
                self.assertEqual(
                    db.execute(f"SELECT count(*) FROM {table}").fetchone()[0], 1
                )
            self.assertEqual(
                db.execute("SELECT DISTINCT session_id FROM part").fetchall(),
                [("ses_other",)],
            )

    def test_bad_batch_does_not_delete_anything(self):
        history = self.history(writable=True)
        with self.assertRaisesRegex(ValueError, "Session not found"):
            oc.delete(history, ["ses_root", "ses_missing"])
        self.assertEqual(
            history.dbs[0][1].execute("SELECT count(*) FROM session").fetchone()[0], 3
        )

    def test_vacuum_dry_run_and_execution(self):
        history = self.history()
        args = types.SimpleNamespace(db=None, dry_run=True)
        dry = oc.vacuum(history, args)
        self.assertEqual(len(dry["results"]), 1)
        self.assertTrue(dry["results"][0]["dry_run"])
        self.assertGreater(dry["results"][0]["before_bytes"], 0)

        history2 = self.history()
        args.dry_run = False
        res = oc.vacuum(history2, args)
        self.assertEqual(len(res["results"]), 1)
        self.assertFalse(res["results"][0]["dry_run"])
        self.assertGreater(res["results"][0]["after_bytes"], 0)


if __name__ == "__main__":
    unittest.main()
