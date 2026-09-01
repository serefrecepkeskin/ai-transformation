#!/usr/bin/env bash
# agentStop hook: non-blocking reminders when the session ends with code changed
# but the knowledge base untouched (docs and code must not drift — AGENTS.md).
# Output goes to the agent/log as plain text; always exits 0.
set -u
cat > /dev/null  # drain stdin

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
changed=$( (git diff --name-only HEAD -- 2>/dev/null; git ls-files --others --exclude-standard) | sort -u )
[ -z "$changed" ] && exit 0

src=$(echo "$changed" | grep -vE '^docs/' | grep -E '\.(ts|tsx|js|jsx|vue|css|scss)$|package\.json|tsconfig')
docs=$(echo "$changed" | grep -E '^docs/')

if [ -n "$src" ] && [ -z "$docs" ]; then
  echo "Reminder: source/config changed but docs/ was not updated. If this change affects architecture, conventions or the stack, update the doc and record an ADR in the same PR (AGENTS.md rule #7)."
fi

if echo "$changed" | grep -qE 'package\.json|tsconfig' && ! echo "$changed" | grep -qE '^docs/decisions/'; then
  echo "Reminder: dependency/config files changed but no new ADR was added. A stack or tooling decision usually deserves one (record-decision skill)."
fi

exit 0
