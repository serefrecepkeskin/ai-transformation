#!/usr/bin/env bash
# PostToolUse hook (Edit|Write): format the file the agent just edited. Never blocks: always exits 0.
#
# Works from a repo or from the workspace root (not a git repo): each named file is formatted inside the repo it belongs
# to, with that repo's own tools. Scope: only the path(s) named in the hook JSON ("file_path" / "filePath" /
# "path"), so the developer's half-done work is left alone; only when the payload names no file does it fall back
# to the changed files of the cwd's repo. Kit-owned and guarded paths (.claude/ .github/agents/ agent-work/)
# are never touched.
#
# Python (only in a repo with a ruff config): `ruff format` + import sorting only (`--select I`). Not a full
# `ruff check --fix`: the backends run `select = ["ALL"]` with everything fixable, and a full fix between two
# edits deletes the import the agent just added before the code using it lands (F401). The full fix runs at
# commit time (pre-commit, $commit-and-pr). KIT_FULL_FIX=1 restores it here.
# JS/TS: the repo's own prettier (only if the repo adopted it) and eslint --fix.
set -u
input=$(cat)
here="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=_changed.sh
. "$here/_changed.sh"

pairs=""   # "<repo-root><TAB><repo-relative path>" per line (bash 3.2: no associative arrays)
named=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  named=1
  case "$f" in /*) ;; *) f="$PWD/$f" ;; esac
  [ -f "$f" ] || continue
  top=$(git -C "$(dirname "$f")" rev-parse --show-toplevel 2>/dev/null) || continue   # not in a repo: skip
  pairs="${pairs}${top}"$'\t'"${f#"$top"/}"$'\n'
done < <(printf '%s' "$input" | grep -oE '"(file_path|filePath|path)" *: *"[^"]+"' | sed -E 's/^"[^"]+" *: *"//; s/"$//' | sort -u)
if [ "$named" = 0 ]; then
  top=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0   # the non-git workspace root: nothing to fall back to
  pairs=$(changed_files "$top" | sed "s|^|$top	|")
fi
[ -n "$pairs" ] || exit 0

run() { # run <newline-separated files> <command...> — NUL-safe, silent
  local files="$1"; shift
  [ -n "$files" ] || return 0
  printf '%s\n' "$files" | grep . | tr '\n' '\0' | xargs -0 "$@" > /dev/null 2>&1
}

format_repo() { # format_repo <files> — cwd is the repo root
  local changed="$1" py RUFF fix
  py=$(printf '%s\n' "$changed" | grep -E '\.py$' || true)
  if [ -n "$py" ] && { [ -f pyproject.toml ] || [ -f ruff.toml ] || [ -f .ruff.toml ]; }; then
    if   [ -x .venv/bin/ruff ]; then RUFF=.venv/bin/ruff
    elif [ -x venv/bin/ruff ];  then RUFF=venv/bin/ruff
    elif command -v ruff > /dev/null 2>&1; then RUFF=ruff
    else RUFF=""; fi
    if [ -n "$RUFF" ]; then
      if [ "${KIT_FULL_FIX:-0}" = 1 ]; then fix="check --fix"; else fix="check --fix --select I"; fi
      # shellcheck disable=SC2086
      run "$py" "$RUFF" $fix
      run "$py" "$RUFF" format
    fi
  fi
  if [ -f package.json ] && [ -d node_modules/.bin ]; then
    # prettier only in a repo that opted in; only the repo's own binaries, never a global npx cache copy
    if ls .prettierrc* prettier.config.* > /dev/null 2>&1 || grep -qs '"prettier"' package.json; then
      [ -x node_modules/.bin/prettier ] && run "$(printf '%s\n' "$changed" | grep -E '\.(ts|tsx|js|jsx|css|scss|json|md|yml|yaml)$' || true)" node_modules/.bin/prettier --write --cache
    fi
    [ -x node_modules/.bin/eslint ] && run "$(printf '%s\n' "$changed" | grep -E '\.(ts|tsx|js|jsx)$' || true)" node_modules/.bin/eslint --fix --cache --cache-location node_modules/.cache/eslint/
  fi
}

while IFS= read -r top; do   # one repo root per line — a path with spaces stays whole
  files=$(printf '%s' "$pairs" | awk -F'\t' -v t="$top" '$1 == t { print $2 }' | sort -u \
    | grep -vE '^(\.claude/|\.github/agents/|agent-work/)' || true)
  [ -n "$files" ] && ( cd "$top" && format_repo "$files" )
done < <(printf '%s' "$pairs" | cut -f1 | sort -u)
exit 0
