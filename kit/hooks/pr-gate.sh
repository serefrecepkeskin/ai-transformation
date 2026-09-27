#!/usr/bin/env bash
# PreToolUse hook (Bash): the PR/push evidence gate. Logic lives in pr_gate.py; this wrapper only makes a missing
# python3 fail open (the CI check pr-evidence.yml is the backstop). Exit 2 blocks the command; stderr says why.
here="$(cd "$(dirname "$0")" && pwd)"
input="$(cat)"
case "$input" in *push*|*create*) ;; *) exit 0 ;; esac   # nearly every Bash call: no python start at all
command -v python3 > /dev/null 2>&1 || exit 0
printf '%s' "$input" | exec python3 -B "$here/pr_gate.py"   # -B: no __pycache__ inside a repo's .claude/hooks
