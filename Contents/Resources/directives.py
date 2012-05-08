#!/usr/bin/python
"""
Search the top of a file for !TEX directives

Usage:   directives.py command1 [command2 [...]] filename

Example: directives.py root program foo.tex

Results are printed, one per line, in the order the arguments are listed.
"""

import re
import sys

def search(directive, head):
    """
    Search for a directive, e.g. "% !TEX root = filename"
    """
    try:
        m = re.search(r"%\s?!\s?TEX (TS-)?" + directive +
          r"\s?=\s?([^\s]*)", head)
        if m:
            return m.group(2)
        else:
            return ""
    except re.error as message:
        sys.stderr.write("Invalid regular expression: %s" % message)
        sys.exit(1)


if len(sys.argv) == 1:
    sys.stderr.write("At least one argument is required")
    sys.exit(1)

filename = sys.argv[-1]
head = open(filename,'r').read(1000)
d = dict()
commands = sys.argv[1:-1]

for c in commands:
    d[c] = search(c, head)

if "root" in commands:
    if d["root"] == "":
        d["root"] = filename
    elif d["root"][0] != '/':
        d["root"] = filename[:filename.rfind('/')+1] + d["root"]

for c in commands:
    print d[c]

