#!/usr/bin/env bash
# agentStop hook: non-blocking reminders when the session ends with code changed
# but the knowledge base untouched (docs and code must not drift — AGENTS.md).
# Output goes to the agent/log as plain text; always exits 0.
set -u
cat > /dev/null  # drain stdin

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
changed=$( (git diff --name-only HEAD -- 2>/dev/null; git ls-files --others --exclude-standard) | sort -u )
[ -z "$changed" ] && exit 0

src=$(echo "$changed" | grep -vE '^docs/' | grep -E '\.(py|ts|tsx|js|jsx|vue|css|scss)$|pyproject\.toml|requirements|package\.json|tsconfig' || true)
docs=$(echo "$changed" | grep -E '^docs/' || true)
deps=$(echo "$changed" | grep -E 'pyproject\.toml|requirements|package\.json|tsconfig' || true)

if [ -n "$src" ] && [ -z "$docs" ]; then
  echo "Reminder: source/config changed but docs/ was not updated. If this change affects architecture, conventions or the stack, update the doc and record an ADR in the same PR (AGENTS.md: \"Keep docs short and current\")."
fi

# A reminder that fires on every lockfile bump gets ignored; ask for the check that matters instead.
if [ -n "$deps" ]; then
  echo "Reminder: dependency/config files changed. Run the audit (npm audit --audit-level=high / pip-audit) and state the result; an accepted vulnerability needs a written reason. A new library or tool is an ADR."
fi

exit 0
