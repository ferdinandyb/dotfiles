#!/usr/bin/env python3
import os

from notmuch import Database, Query

db = Database(
    "/home/fbence/.mail/.notmuch", create=False, mode=Database.MODE.READ_WRITE
)


def move_maildir(msg, folder):
    print(msg, folder)
    path = msg.get_filename().replace("/.notmuch", "")
    account = "/".join(path.split("/")[:5])
    account = account.replace("/.notmuch", "")
    filename = path.split("/")[-1]
    name, uid, flags = filename.split(",")
    os.rename(path, f"{account}/{folder}/cur/{name}:2,{flags}")


# move folders
foldernames = [
    "1_megválaszolni",
    "2_rám_vár",
    "3_másra_vár",
    "4_olvasni",
    "5_információ",
    "6_visszaigazolások",
    "7_hivatalos+pénzügyek",
    "Archive",
]
msgs = Query(
    db,
    "tag:aerc",
).search_messages()

for msg in msgs:
    for t in msg.get_tags():
        if t in foldernames:
            move_maildir(msg, t)
            break
    for f in foldernames:
        msg.remove_tag(f)
        msg.remove_tag("aerc")

del msgs
# sync inbox

path1 = "elte/Inbox/**"
path2 = "priestoferis/Inbox/**"
path3 = "formsense/Inbox/**"
path4 = "pharmahungary/Inbox/**"

msgs = Query(
    db,
    f"tag:inbox and not (path:{path1} or path:{path2} or path:{path3} or path:{path4})",
).search_messages()

for msg in msgs:
    msg.remove_tag("inbox")

del msgs

msgs = Query(
    db,
    f"(path:{path1} or path:{path2} or path:{path3} or path:{path4}) and not tag:inbox",
).search_messages()

for msg in msgs:
    msg.add_tag("inbox")

del msgs
# sync unread
msgs = Query(
    db,
    f"tag:unread and not (path:{path1} or path:{path2} or path:{path3} or path:{path4})",
).search_messages()

for msg in msgs:
    msg.remove_tag("unread", sync_maildir_flags=True)
del msgs

db.close()
del db
