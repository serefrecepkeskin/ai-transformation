#!/usr/bin/env bash
# agentStop hook: end-of-session checks. Formatting runs here rather than on
# every edit (postToolUse) because dotnet format scans the whole solution —
# too slow per tool call, deliberate trade-off. Non-blocking: always exits 0.
# Windows: no powershell variant configured — TODO(confirm) if needed.
set -u
cat > /dev/null  # drain stdin

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
changed=$( (git diff --name-only HEAD -- 2>/dev/null; git ls-files --others --exclude-standard) | sort -u )
[ -z "$changed" ] && exit 0

if echo "$changed" | grep -qE '\.cs$' && command -v dotnet > /dev/null 2>&1; then
  if ! dotnet format --verify-no-changes > /dev/null 2>&1; then
    echo "Reminder: 'dotnet format --verify-no-changes' fails. Run 'dotnet format' before the PR (run-quality-gates skill)."
  fi
fi

src=$(echo "$changed" | grep -vE '^docs/' | grep -E '\.cs$|\.csproj$|Directory\.Build\.props')
docs=$(echo "$changed" | grep -E '^docs/')

if [ -n "$src" ] && [ -z "$docs" ]; then
  echo "Reminder: source/config changed but docs/ was not updated. If this change affects architecture, conventions or the stack, update the doc and record an ADR in the same PR (AGENTS.md rule #7)."
fi

if echo "$changed" | grep -qE '\.csproj$|Directory\.Build\.props' && ! echo "$changed" | grep -qE '^docs/decisions/'; then
  echo "Reminder: project/dependency files changed but no new ADR was added. A stack or tooling decision usually deserves one (record-decision skill)."
fi

exit 0
