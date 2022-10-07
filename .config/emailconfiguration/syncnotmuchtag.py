#!/usr/bin/env python3
from notmuch import Database, Query

db = Database(
    "/home/fbence/.mail/.notmuch", create=False, mode=Database.MODE.READ_WRITE
)
path1 = "ferdinandy.bence_elte/Inbox/**"
path2 = "priestoferis_gmail/Inbox/**"
path3 = "bence.ferdinandy_formsense/Inbox/**"
msgs = Query(
    db, f"tag:inbox and not (path:{path1} or path:{path2} or path:{path3})"
).search_messages()

for msg in msgs:
    msg.remove_tag("inbox")

msgs = Query(
    db,
    f"tag:unread and not (path:{path1} or path:{path2} or path:{path3})",
).search_messages()

for msg in msgs:
    msg.remove_tag("unread")

msgs = Query(
    db, f"(path:{path1} or path:{path2} or path:{path3}) and not tag:inbox"
).search_messages()

for msg in msgs:
    msg.add_tag("inbox")
