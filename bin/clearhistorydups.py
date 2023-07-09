#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from shutil import copy2
import os
import re
import sys

UNWANTED_COMMANDS = { r'(builtin\s+)?cd\s+' }


def _err(*args, **kwargs) -> None:
    print(*args, file=sys.stderr, **kwargs)


def _keep(command: str, seen: set) -> bool:
    if command == '' or command in seen:
        return False
    for p in filter(lambda p: re.match(p, command), UNWANTED_COMMANDS):
        return False
    return True


def clear(hist_file: str) -> int:
    if not os.path.isfile(hist_file):
        _err(f'File "{hist_file}" not found (or not a regular file)\nAborted!')
        return 2

    backup_hist = f'{hist_file}.bak'
    copy2(hist_file, backup_hist)
    _err(f'History backup-file written to {backup_hist}')

    resp = None
    while resp is None or resp not in 'yYnN':
        resp = input(f'File "{hist_file}" will be edited, continue? (y/N) ').strip()

    if resp in 'nN':
        _err('Aborted!')
        os.remove(backup_hist)
        return 3

    with open(hist_file, 'r+') as f:
        history = [ line.strip() for line in f.read().splitlines() ][::-1]
        seen = set()
        result = []
        for h in filter(lambda x: _keep(x, seen), history):
            if not re.match(r'#\d+', h) or result and not re.match(r'#\d+', result[-1]):
                result.append(h)
                seen.add(h)
        if result and result != history:
            f.seek(0)
            print(*result[::-1], file=f, sep='\n')
            f.truncate()
            _err(f'{len(history) - len(result)} lines have been purged ({(len(history) - len(result)) / len(history) * 100:.1f}%)')
            resp = None
            while resp is None or resp not in 'yYnN':
                resp = input(f'Delete history backup-file {backup_hist}? (Y/n)').strip()
            if resp in 'yY':
                os.remove(backup_hist)
        else:
            os.remove(backup_hist)
            _err('No change needed')
    return 0


if __name__ == '__main__':
    if len(sys.argv) > 2 or len(sys.argv) == 2 and sys.argv[1].lower() in ('-h', '--help'):
        _err(f'USAGE: {sys.argv[0].split("/")[-1]} [PATH]')
        _err(f'    "{os.environ["HOME"]}/.bash_history" will be used if the PATH argument is not present.')
        sys.exit(1)

    hist_file = f'{os.environ["HOME"]}/.bash_history' if len(sys.argv) == 1 else sys.argv[1]
    sys.exit(clear(hist_file))
