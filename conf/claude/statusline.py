#!/usr/bin/env python3
"""Claude Code status line (Nerd Font + true color). Reads the session JSON on stdin, prints two lines:
  󰚩 model │ ██████░░░░ 42% 200k │ $0.31 │ 2m5s │ 5h:23% 7d:10%
   branch* │ +12/-3 │ dir │ worktree:name
"""
import json
import os
import subprocess
import sys

RST, GRAY, CYAN, BLUE = "\033[0m", "\033[90m", "\033[36m", "\033[34m"
GREEN, YELLOW, RED = "\033[32m", "\033[33m", "\033[31m"
PURPLE = "\033[38;2;114;102;234m"  # Anthropic brand purple
SEP = f" {GRAY}│{RST} "
# Nerd Font glyphs (code point in the comment, in case a paste strips them again)
I_BRAND = "󰚩"   # U+F06A9 nf-md-robot
I_BRANCH = ""  # U+E725 nf-dev-git_branch
I_COST = ""    # U+F155 nf-fa-dollar
I_TIME = "󰔟"    # U+F051F nf-md-timer_outline
I_WARN = "󰀦"    # U+F0026 nf-md-alert
I_AGENT = ""   # U+F013 nf-fa-cog

# Context bar: 10 cells, green → red gradient
BAR_RGB = [(46, 204, 113), (116, 195, 89), (186, 186, 64), (241, 196, 15), (239, 161, 24),
           (236, 126, 34), (233, 101, 44), (231, 76, 60), (211, 66, 50), (192, 57, 43)]
EMPTY_RGB = (60, 60, 60)


def rgb(r, g, b):
    return f"\033[38;2;{r};{g};{b}m"


def get(obj, path, default):
    """Nested lookup: get(d, "a.b.c", 0). Missing or null → default."""
    for key in path.split("."):
        obj = obj.get(key) if isinstance(obj, dict) else None
    return default if obj is None else obj


def git(cwd, *args):
    """stdout of `git -C cwd args...`, or None if git fails."""
    r = subprocess.run(["git", "-C", cwd, *args], capture_output=True, text=True)
    return r.stdout.strip() if r.returncode == 0 else None


def main():
    d = json.load(sys.stdin)
    model = get(d, "model.display_name", "?")
    pct = int(get(d, "context_window.used_percentage", 0))
    size = int(get(d, "context_window.context_window_size", 0))
    cost = f"{float(get(d, 'cost.total_cost_usd', 0)):.2f}"
    dur = int(get(d, "cost.total_duration_ms", 0)) // 1000
    add = int(get(d, "cost.total_lines_added", 0))
    rm = int(get(d, "cost.total_lines_removed", 0))
    r5 = int(get(d, "rate_limits.five_hour.used_percentage", -1))
    r7 = int(get(d, "rate_limits.seven_day.used_percentage", -1))
    cwd = get(d, "workspace.current_dir", ".")
    branch = get(d, "worktree.branch", "")
    wt = get(d, "worktree.name", "")
    agent = get(d, "agent.name", "")

    # Line 1: model │ context bar │ cost │ duration │ rate limits
    bar = "".join(rgb(*BAR_RGB[i]) + "█" if i < pct // 10 else rgb(*EMPTY_RGB) + "░" for i in range(10))
    pct_color = RED if pct >= 90 else YELLOW if pct >= 70 else GREEN
    ctx = f"{bar}{RST} {pct_color}{pct}%{RST}"
    if pct >= 90:
        ctx += f" {RED}{I_WARN}{RST}"
    if size >= 1_000_000:
        ctx += f" {GRAY}1M{RST}"
    elif size > 0:
        ctx += f" {GRAY}{size // 1000}k{RST}"

    cost_color = GRAY if cost == "0.00" else RED if float(cost) >= 10 else YELLOW

    line1 = [f"{PURPLE}{I_BRAND}{RST} {CYAN}{model}{RST}", ctx, f"{cost_color}{I_COST} ${cost}{RST}"]
    if dur > 0:
        line1.append(f"{GRAY}{I_TIME} {dur // 60}m{dur % 60}s{RST}")
    rate = [f"{RED if v >= 80 else GRAY}{label}:{v}%{RST}" for label, v in (("5h", r5), ("7d", r7)) if v >= 0]
    if rate:
        line1.append(" ".join(rate))

    # Line 2: branch │ +add/-rm │ dir │ worktree/agent
    line2 = []
    if os.path.isdir(cwd) and git(cwd, "rev-parse", "--git-dir") is not None:
        branch = branch or git(cwd, "branch", "--show-current") or git(cwd, "rev-parse", "--short", "HEAD") or ""
        dirty = "" if git(cwd, "diff", "--quiet", "HEAD") is not None else "*"
        line2.append(f"{GRAY}{I_BRANCH} {branch}{dirty}{RST}")
    if add > 0 or rm > 0:
        line2.append(f"{GREEN}+{add}{RST}/{RED}-{rm}{RST}")
    line2.append(f"{BLUE}{os.path.basename(cwd)}{RST}")
    if wt:
        line2.append(f"{YELLOW}{I_AGENT} worktree:{wt}{RST}")
    elif agent:
        line2.append(f"{YELLOW}{I_AGENT} {agent}{RST}")

    print(SEP.join(line1))
    print(SEP.join(line2), end="")


if __name__ == "__main__":
    main()
