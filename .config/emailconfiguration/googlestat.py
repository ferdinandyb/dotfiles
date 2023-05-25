import pickle
from datetime import datetime
from email.parser import BytesParser
from email.utils import parsedate_to_datetime
from pathlib import Path

import numpy as np
from dateutil import parser as dateparser
from matplotlib import pyplot as plt

MAILDIR = Path("/home/fbence/.mail")


def checkIfMail(path):
    if path.is_dir():
        return False
    if path.parent.stem in ["cur", "tmp", "new"]:
        return True
    return False


def parseMessage(msg):
    addresses = []
    for header in ["to", "from", "cc", "bcc"]:
        parsed = parseHeader(msg[header])
        if parsed is not None:
            addresses += parsed
    try:
        date = parsedate_to_datetime(msg["date"]).timestamp()
    except ValueError:
        date = 0
    return addresses, date


parser = BytesParser()
counters = {}
for i, msgpath in enumerate(Path(MAILDIR).glob("**/*")):
    if i == 100:
        pass
    if not checkIfMail(msgpath):
        continue
    try:
        msg = parser.parse(open(msgpath, "rb"), headersonly=True)
        try:
            dateheader = msg["date"].replace("Date:", "")
        except AttributeError:
            pass
        try:
            date = dateparser.parse(dateheader)
        except dateparser.ParserError:
            date = parsedate_to_datetime(dateheader)
        year = date.year
        if year not in counters:
            counters[year] = [0, 0]

        for key, val in msg.items():
            if "google.com" in val or "gmail.com" in val:
                counters[year][0] += 1
                break
        counters[year][1] += 1
    except:
        pass
print(counters)
pickle.dump(counters, open("googlestat.pkl", "wb"))
data = []
for key, val in counters.items():
    data.append([key, val[0] / val[1]])
data = sorted(data, key=lambda x: x[0])
data = np.array(data)
fig = plt.figure()
plt.plot(data[:, 0], data[:, 1], "*-")
# plt.legend()
plt.title("gmail ratio")
plt.savefig("googlestat.svg")
# addresses = set()
# datetimes = []
# addressnum = []
# for i, (addresslist, date) in enumerate(sorted(parsed, key=lambda x: x[1])):
#     if date <= 0:
#         continue
#     for addr in addresslist:
#         addresses.add(addr[1])
#     datetimes.append(datetime.fromtimestamp(date))
#     addressnum.append(len(addresses))

# fig = plt.figure()
# plt.plot(datetimes, addressnum, label="# addresses")
# plt.plot(datetimes, [i + 1 for i in range(len(datetimes))], label="# emails")
# plt.legend()
# fig.autofmt_xdate()
# plt.savefig("date-address.svg")


# fig = plt.figure()
# plt.plot([i + 1 for i in range(len(addressnum))], addressnum)
# plt.xlabel("# emails")
# plt.ylabel("# addresses")
# plt.savefig("email-address.svg")
