#!/usr/bin/env bash
# postToolUse hook: auto-format the file the agent just edited.
# Scope: the path(s) named in the hook JSON on stdin ("file_path" / "filePath" / "path") — so the
# developer's own half-done work in the tree is left alone. When the JSON names no file (other runtime,
# schema change), it falls back to every changed file in the working tree. One script for both
# ecosystems: Python via ruff, JS/TS/CSS/MD via prettier + eslint; each branch is skipped silently when
# its tool is not installed. Guardrail and kit-owned paths (.claude/, .github/hooks|agents/, .husky/,
# .impeccable/, agent-work/) are never touched. Never blocks: always exits 0. Windows: Git Bash/WSL — TODO(confirm) if the
# team develops on Windows.
set -u
input=$(cat)

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
root=$(pwd)

# 1. files named by the hook payload (repo-relative, existing, inside the repo)
changed=""
for f in $(printf '%s' "$input" | grep -oE '"(file_path|filePath|path)" *: *"[^"]+"' | sed -E 's/^"[^"]+" *: *"//; s/"$//'); do
  case "$f" in /*) ;; *) f="$root/$f" ;; esac
  case "$f" in "$root"/*) [ -f "$f" ] && changed="${changed}${f#"$root"/}"$'\n' ;; esac
done
# 2. fallback: everything changed in the working tree
[ -n "$changed" ] || changed=$( (git diff --name-only HEAD -- 2>/dev/null; git ls-files --others --exclude-standard) | sort -u )
# Never reformat the guardrails or kit-owned files: rewriting them is how a repo silently drifts from the
# company kit, and the agent is not allowed to edit them by hand either (see .vscode/settings.json).
changed=$(printf '%s\n' "$changed" | grep -vE '^(\.claude/|\.github/(hooks|agents)/|\.husky/|\.impeccable/|agent-work/)' || true)
[ -n "$changed" ] || exit 0

run() { # run <newline-separated files> <command...> — NUL-safe, silent
  local files="$1"; shift
  [ -n "$files" ] || return 0
  printf '%s\n' "$files" | grep . | tr '\n' '\0' | xargs -0 "$@" > /dev/null 2>&1
}

py=$(printf '%s\n' "$changed" | grep -E '\.py$' || true)
if [ -n "$py" ]; then
  # the repo's own interpreter first, PATH second, uv last — `uv run` in a non-uv project fails silently
  if   [ -x .venv/bin/ruff ]; then RUFF=.venv/bin/ruff
  elif [ -x venv/bin/ruff ];  then RUFF=venv/bin/ruff
  elif command -v ruff > /dev/null 2>&1; then RUFF=ruff
  elif command -v uv > /dev/null 2>&1;   then RUFF="uv run ruff"
  else RUFF=""; fi
  if [ -n "$RUFF" ]; then
    # shellcheck disable=SC2086
    run "$py" $RUFF format; run "$py" $RUFF check --fix
  fi
fi

if command -v npx > /dev/null 2>&1; then
  run "$(printf '%s\n' "$changed" | grep -E '\.(ts|tsx|js|jsx|vue|css|scss|json|md|yml|yaml)$' || true)" npx --no-install prettier --write
  run "$(printf '%s\n' "$changed" | grep -E '\.(ts|tsx|js|jsx|vue)$' || true)" npx --no-install eslint --fix
fi

exit 0
