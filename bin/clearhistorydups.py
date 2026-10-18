#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from shutil import copy2
import os
import re
import sys

# Entries matching one of these in full are purged (so `cd x && make` survives).
UNWANTED_COMMANDS = { r'(builtin\s+)?cd(\s+[^;&|]*)?' }
TS = re.compile(r'#\d+')  # bash HISTTIMEFORMAT marker line


def _err(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def _confirm(prompt: str, default: str) -> bool:
    while True:
        try:
            resp = input(prompt).strip().lower() or default
        except EOFError:
            resp = default
        if resp in ('y', 'n'):
            return resp == 'y'


def _entries(lines: list[str]) -> list[tuple[str | None, str]]:
    """Group lines like bash does: a '#epoch' line owns every following line up
    to the next one (multi-line commands). Lines before any timestamp are one
    entry each. Returns (timestamp | None, command) with the command stripped
    as a whole, inner indentation untouched."""
    groups: list[tuple[str | None, list[str]]] = []
    for line in lines:
        if TS.fullmatch(line):
            groups.append((line, []))
        elif groups and groups[-1][0] is not None:
            groups[-1][1].append(line)
        else:
            groups.append((None, [line]))
    return [(ts, '\n'.join(cmd).strip()) for ts, cmd in groups]


def _keep(command: str, seen: set[str]) -> bool:
    return (command != '' and command not in seen
            and not any(re.fullmatch(p, command) for p in UNWANTED_COMMANDS))


def clear(hist_file: str) -> int:
    if not os.path.isfile(hist_file):
        _err(f'File "{hist_file}" not found (or not a regular file)\nAborted!')
        return 2

    backup_hist = f'{hist_file}.bak'
    copy2(hist_file, backup_hist)
    _err(f'History backup-file written to {backup_hist}')

    if not _confirm(f'File "{hist_file}" will be edited, continue? (y/N) ', 'n'):
        _err('Aborted!')
        os.remove(backup_hist)
        return 3

    with open(hist_file, 'r+', errors='surrogateescape') as f:
        entries = _entries([line.rstrip('\n') for line in f])
        seen: set[str] = set()
        kept = []
        for ts, cmd in reversed(entries):  # newest first, so the last occurrence wins
            if _keep(cmd, seen):
                seen.add(cmd)
                kept.append((ts, cmd))
        kept.reverse()
        if kept and kept != entries:
            f.seek(0)
            for ts, cmd in kept:
                if ts is not None:
                    print(ts, file=f)
                print(cmd, file=f)
            f.truncate()
            purged = len(entries) - len(kept)
            _err(f'{purged} entries have been purged ({purged / len(entries) * 100:.1f}%)')
            if _confirm(f'Delete history backup-file {backup_hist}? (Y/n) ', 'y'):
                os.remove(backup_hist)
        else:
            os.remove(backup_hist)
            _err('No change needed')
    return 0


if __name__ == '__main__':
    if len(sys.argv) > 2 or len(sys.argv) == 2 and sys.argv[1].lower() in ('-h', '--help'):
        _err(f'USAGE: {os.path.basename(sys.argv[0])} [PATH]')
        _err(f'    "{os.environ["HOME"]}/.bash_history" will be used if the PATH argument is not present.')
        sys.exit(1)

    hist_file = f'{os.environ["HOME"]}/.bash_history' if len(sys.argv) == 1 else sys.argv[1]
    sys.exit(clear(hist_file))
