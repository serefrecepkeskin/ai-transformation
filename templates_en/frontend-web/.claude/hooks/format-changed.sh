#!/usr/bin/env bash
# postToolUse hook: auto-format files changed in the working tree.
# Reads the hook JSON from stdin but does not depend on its schema — it acts on
# git state instead, so it keeps working across Copilot versions. Never blocks:
# always exits 0. Windows: no powershell variant configured — TODO(confirm) if
# the team develops on Windows.
set -u
cat > /dev/null  # drain stdin

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
command -v npx > /dev/null 2>&1 || exit 0

changed=$( (git diff --name-only HEAD -- 2>/dev/null; git ls-files --others --exclude-standard) | sort -u )
[ -z "$changed" ] && exit 0

fmt=$(echo "$changed" | grep -E '\.(ts|tsx|js|jsx|vue|css|scss|json|md|yml|yaml)$')
if [ -n "$fmt" ]; then
  echo "$fmt" | xargs npx --no-install prettier --write > /dev/null 2>&1
fi

lint=$(echo "$changed" | grep -E '\.(ts|tsx|js|jsx|vue)$')
if [ -n "$lint" ]; then
  echo "$lint" | xargs npx --no-install eslint --fix > /dev/null 2>&1
fi

exit 0
