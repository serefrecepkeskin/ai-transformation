#!/usr/bin/env bash
# postToolUse hook: auto-format the file the agent just edited.
# Scope: the path(s) named in the hook JSON on stdin ("file_path" / "filePath" / "path") — so the
# developer's own half-done work in the tree is left alone. Only when the JSON names no file at all (other
# runtime, schema change) does it fall back to every changed file in the working tree — a named file
# outside the repo (a memory note, a scratchpad) formats nothing. One script for both ecosystems: Python
# via ruff, JS/TS/CSS/MD via prettier + eslint; each branch is skipped silently when the repo does not
# use that tool — prettier runs only in a repo that adopted it (a prettier config or dependency), and
# only the repo's own node_modules copies are run, never one the global npx cache happens to hold.
# Guardrail and kit-owned paths (.claude/, .agents/skills/impeccable/, .github/hooks|agents/, .husky/,
# .impeccable/, agent-work/) are never touched. Never blocks: always exits 0. Windows: Git Bash/WSL — TODO(confirm) if the
# team develops on Windows.
set -u
input=$(cat)

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
root=$(pwd)

# 1. files named by the hook payload (repo-relative, existing, inside the repo)
changed=""
named=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  named=1
  case "$f" in /*) ;; *) f="$root/$f" ;; esac
  case "$f" in "$root"/*) [ -f "$f" ] && changed="${changed}${f#"$root"/}"$'\n' ;; esac
done < <(printf '%s' "$input" | grep -oE '"(file_path|filePath|path)" *: *"[^"]+"' | sed -E 's/^"[^"]+" *: *"//; s/"$//')
# 2. fallback: everything changed in the working tree — ONLY when the payload named no file at all.
#    A named file outside the repo (a memory note, a scratchpad) must not reformat the developer's
#    unrelated uncommitted work.
[ "$named" = 1 ] || changed=$( (git diff --name-only HEAD -- 2>/dev/null; git ls-files --others --exclude-standard) | sort -u )
# Never reformat the guardrails or kit-owned files: rewriting them is how a repo silently drifts from the
# company kit, and the agent is not allowed to edit them by hand either (see .vscode/settings.json).
changed=$(printf '%s\n' "$changed" | grep -vE '^(\.claude/|\.agents/skills/impeccable/|\.github/(hooks|agents)/|\.husky/|\.impeccable/|agent-work/)' || true)
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
  # Prettier only when the repo opted in (a prettier config or a dependency) — not whenever some
  # binary resolves: `npx --no-install` also finds a copy in the global npx cache, which restyled a
  # prettier-free repo wholesale (double quotes, semicolons).
  if ls .prettierrc* prettier.config.* > /dev/null 2>&1 || grep -qs '"prettier"' package.json; then
    [ -x node_modules/.bin/prettier ] && run "$(printf '%s\n' "$changed" | grep -E '\.(ts|tsx|js|jsx|vue|css|scss|json|md|yml|yaml)$' || true)" node_modules/.bin/prettier --write
  fi
  [ -x node_modules/.bin/eslint ] && run "$(printf '%s\n' "$changed" | grep -E '\.(ts|tsx|js|jsx|vue)$' || true)" node_modules/.bin/eslint --fix
fi

exit 0
