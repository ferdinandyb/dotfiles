import argparse
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


def main(path):
    parser = BytesParser()
    for i, msgpath in enumerate(Path(path).glob("cur/*")):
        print(msgpath)
        msg = parser.parse(open(msgpath, "rb"), headersonly=True)
        if msg["date"] is None:
            continue
        dateheader = msg["date"].replace("Date:", "")
        try:
            date = dateparser.parse(dateheader)
        except dateparser.ParserError:
            date = parsedate_to_datetime(dateheader)
        if date.tzinfo is None or date.tzinfo.utcoffset(date) is None:
            date = date.replace(tzinfo=timezone.utc)
        if datetime.now(timezone.utc) - relativedelta(years=1) >= date:
            targetfolder = Path(path) / str(date.year)
            setUpMaildir(targetfolder)
            msgpath.rename(targetfolder / "cur" / msgpath.name)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        usage="""python3 rearchive.py ~/mail/account/Archive

The script will look for messages in ~/mail/account/Archive/cur and move them
to yearly archived folders in the maildir (e.g. to Archive/2022/cur) if the
message is older than one year. That is if the current date is 2023.03.15, then
all emails from 2021 will be in the 2021 folder, but emails from after
2022.03.15 will still be in the top folder.

"""
    )
    parser.add_argument("folder", type=str)
    args = parser.parse_args()
    main(args.folder)
