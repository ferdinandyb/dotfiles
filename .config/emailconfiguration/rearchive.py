import argparse
import re
from datetime import datetime, timezone
from email.parser import BytesParser
from email.utils import parsedate_to_datetime
from pathlib import Path

from dateutil import parser as dateparser
from dateutil.relativedelta import relativedelta


def setUpMaildir(date):
    date = str(date)
    Path.mkdir(Path(date) / "cur", parents=True, exist_ok=True)
    Path.mkdir(Path(date) / "tmp", parents=True, exist_ok=True)
    Path.mkdir(Path(date) / "new", parents=True, exist_ok=True)


def move_maildir(path, targetfolder):
    # print("moving:", path.name, targetfolder)
    filename = path.name
    # print(filename)
    try:
        name, _, flags = filename.split(",")
    except ValueError:
        name, flags = filename.split(",")
    path.rename(targetfolder / "cur" / f"{name}:2,{flags}")


def main(path, targetpath):
    parser = BytesParser()
    if targetpath is None:
        targetpath = path
    print("source:", path, "target:", targetpath)
    totalmessages = 0
    movedmessages = 0
    for i, msgpath in enumerate(Path(path).glob("cur/*")):
        totalmessages += 1
        msg = parser.parse(open(msgpath, "rb"), headersonly=True)
        # print(msg["date"])
        if msg["date"] is None:
            continue
        try:
            dateheader = msg["date"].replace("Date:", "")
        except AttributeError:
            pass
        try:
            date = dateparser.parse(dateheader)
        except dateparser.ParserError:
            date = parsedate_to_datetime(dateheader)
        if date.tzinfo is None or date.tzinfo.utcoffset(date) is None:
            date = date.replace(tzinfo=timezone.utc)
        if datetime.now(timezone.utc) - relativedelta(years=1) >= date:
            targetfolder = Path(targetpath) / str(date.year)
            setUpMaildir(targetfolder)
            move_maildir(msgpath, targetfolder)
            movedmessages += 1
    print(f"Moved {movedmessages} messages out of {totalmessages}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        usage="""python3 rearchive.py ~/mail/account/Archive [-t ~/mail/otherfolder/Archive]

The script will look for messages in ~/mail/account/Archive/cur and move them
to yearly archived folders in the maildir (e.g. to Archive/2022/cur) if the
message is older than one year. That is if the current date is 2023.03.15, then
all emails from 2021 will be in the 2021 folder, but emails from after
2022.03.15 will still be in the top folder. The target folder can optionally be
changed to a different one then the original.

"""
    )
    parser.add_argument("folder", type=str)
    parser.add_argument("-t", "--target", type=str)
    args = parser.parse_args()
    main(args.folder, args.target)
