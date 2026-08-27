#!/usr/bin/env bash
# preToolUse hook: technical enforcement of AGENTS.md rule #1 (read-only).
# Scans every tool call's JSON input for write/DDL SQL patterns and DENIES the
# call when one matches. Defense in depth: the primary protection is still the
# read-only DB login — this hook only catches slips earlier.
# May rarely deny a harmless call that merely quotes such SQL in text; the
# deny reason explains why, and the analyst can rephrase.
# Windows: no powershell variant configured — TODO(confirm) if needed.
set -u
input=$(cat)

if printf '%s' "$input" | grep -qiE '\b(insert[[:space:]]+into|update[[:space:]]+[[:alnum:]_."]+[[:space:]]+set|delete[[:space:]]+from|drop[[:space:]]+(table|database|schema|index|view)|truncate([[:space:]]+table)?|alter[[:space:]]+(table|database|schema)|create[[:space:]]+(table|database|schema|index)|grant[[:space:]]+|revoke[[:space:]]+)\b'; then
  printf '{"permissionDecision":"deny","permissionDecisionReason":"This workspace is read-only (AGENTS.md rule #1): write/DDL SQL is not allowed against any database. If data must change, describe the change inside the task for developers instead."}'
  exit 0
fi

# Empty output = default permission behavior.
exit 0
