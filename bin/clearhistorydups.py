#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import print_function
import os
import re
import sys


def err(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


if len(sys.argv) > 2 or len(sys.argv) == 2 and sys.argv[1].lower() in ('-h', '--help'):
    err(f'USAGE: {sys.argv[0].split("/")[-1]} [PATH]')
    err(f'       "{os.environ["HOME"]}/.bash_history" will be used if the PATH argument is not present.')
    err(f'       The file will be edited in-place, you better create a backup before running this script.')
    sys.exit(1)

hist_file = f'{os.environ["HOME"]}/.bash_history' if len(sys.argv) == 1 else sys.argv[1]

if not os.path.isfile(hist_file):
    err(f'File "{hist_file}" not found (or not a regular file)\nAborted!')
    sys.exit(2)

resp = None
while resp is None or resp not in 'yYnN':
    resp = input(f'File "{hist_file}" will be edited, continue? (y/N) ').strip()

if resp in 'nN':
    err('Aborted!')
    sys.exit(3)

with open(hist_file, 'r+') as f:
    history = [ line.strip() for line in f.read().splitlines() ][::-1]
    seen = set()
    result = []
    for h in filter(lambda x: x != '' and x not in seen, history):
        if not re.match(r'#\d+', h) or not re.match(r'#\d+', result[-1]):
            result.append(h)
            seen.add(h)
    if result and result != history:
        f.seek(0)
        print(*result[::-1], file=f, sep='\n')
        f.truncate()
        err(f'{len(history) - len(result)} lines have been purged ({(len(history) - len(result)) / len(history) * 100:.1f}%)')
    else:
        err('No change needed')
