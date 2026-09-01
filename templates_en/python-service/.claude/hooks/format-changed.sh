#!/usr/bin/env bash
# postToolUse hook: auto-format Python files changed in the working tree.
# Reads the hook JSON from stdin but does not depend on its schema — it acts on
# git state instead. Never blocks: always exits 0. Windows: no powershell
# variant configured — TODO(confirm) if the team develops on Windows.
set -u
cat > /dev/null  # drain stdin

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0

changed=$( (git diff --name-only HEAD -- 2>/dev/null; git ls-files --others --exclude-standard) | sort -u | grep -E '\.py$' )
[ -z "$changed" ] && exit 0

if command -v uv > /dev/null 2>&1; then
  RUFF="uv run ruff"
elif command -v ruff > /dev/null 2>&1; then
  RUFF="ruff"
else
  exit 0
fi

echo "$changed" | xargs $RUFF format > /dev/null 2>&1
echo "$changed" | xargs $RUFF check --fix > /dev/null 2>&1

exit 0
