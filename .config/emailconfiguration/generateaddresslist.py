#!/usr/bin/env python3

import subprocess 
import json
import re
from collections import Counter


def getMostFrequent(List):
    occurence_count = Counter(List)
    return occurence_count.most_common(1)[0][0]

def addrFilter(addr):
    # RFC 5322 compliant regex from Moritz Poldrack (moritz@poldrack.dev)
    regex = r"""(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])"""
    if not re.fullmatch(regex,addr["address"]):
        return False
    filterlist = [
        "do-not-reply",
        "no-reply",
        "bounce",
        "noreply"
    ]
    for filt in filterlist:
        if filt in addr["address"].split("@")[0]:
            return False

    return True

output = subprocess.getoutput("notmuch address --output=sender --output=recipients --deduplicate=no --format=json '*'")
data = json.loads(output)
datastore = {}
for addr in data:
    if addrFilter(addr):
        address = addr["address"].lower()
        if not address in datastore:
            datastore[address] = [addr["name"]]
        else:
            datastore[address].append(addr["name"])
weighted = []
for key, value in datastore.items():
    weighted.append({
        "address": key,
        "name": getMostFrequent(value),
        "count": len(value)
    })
with open("emailaddresses.txt", "w") as f:
    for addr in  sorted(weighted, key=lambda x: x["count"], reverse=True):
        f.write((f'{addr["address"]}\t{addr["name"]}\n'))
