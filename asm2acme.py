#!/bin/python3

import sys
import re

for line in sys.stdin:
    # Skip zero length lines
    if len(line.strip()) == 0:
        continue

    # Skip comments or other short lines
    elif line[0] == ';' or len(line) < 18:
        continue

    # Cut lines removing addresses and binary data
    line = line[18:]

    # Line contains something which is not just an instruction?
    # fix it in compliance with acme compiler
    # ORG $address => * = $address
    if "ORG " in line:
        line = line.replace("ORG ", "* =")

    # BYTE $data => !byte $data
    if " BYTE " in line:
        line = line.replace("BYTE", "!byte")

    # LABEL EQU $address => LABEL = $address
    if " EQU " in line:
        line = line.replace("EQU", " = ")
    # LABEL   ... (mnemonics) => LABEL:  ....
    elif line[0] != ' ':
        line = re.sub(r"^([\w0-9]+) ", r"\1:", line)

    # ASL A -> ASL
    line = line.replace("ASL A", "ASL  ")

    print(line, end='')
