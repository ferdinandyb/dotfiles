MAILDIRS = [
    "elte",
    "priestoferis",
    "formsense",
    "pharmahungary",
    "elte",
    "bence"
]

FOLDERS = [
    "Inbox",
    "1_megválaszolni",
    "2_rám_vár",
    "3_másra_vár",
    "4_olvasni",
    "5_információ",
    "6_visszaigazolások",
    "7_hivatalos+pénzügyek",
    "8_talán",
    "Sent",
    "Archive",
]


with open("notmuchmap.conf", "w") as f:
    # RECENT
    s = "Recent=date:30days..today and not ("
    for i, m in enumerate(MAILDIRS):
        s += f"path:{m}/Spam/**"
        if i != len(MAILDIRS) - 1:
            s += " or "
    s += ")\n"
    f.write(s)

    # THREADED INBOX
    s = 'InboxThreaded=thread:"{('
    for i, m in enumerate(MAILDIRS):
        s += f"path:{m}/Inbox/**"
        if i != len(MAILDIRS) - 1:
            s += " or "
    s += ') and not tag:aerc}"\n'
    f.write(s)

    # FOLDERS
    for folder in FOLDERS:
        s = f'{folder}=('
        for i, m in enumerate(MAILDIRS):
            s += f"path:{m}/{folder}/**"
            if i != len(MAILDIRS) - 1:
                s += " or "
        s += ') and not tag:aerc}"\n'
        f.write(s)


