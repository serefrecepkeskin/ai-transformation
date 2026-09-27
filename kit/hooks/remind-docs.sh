#!/usr/bin/env bash
# Stop hook: non-blocking reminders for the rules that are easiest to forget when a session ends, plus a
# one-line summary of the skills and agents this session actually ran. Reads each repo's working tree
# (uncommitted + untracked); prints plain text; always exits 0. From a repo it checks that repo; from the workspace root
# (not a git repo) it checks every wired repo that has changes, prefixing each reminder with the repo name.
set -u
input=$(cat)
here="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=_changed.sh
. "$here/_changed.sh"

remind_repo() { # remind_repo <repo-dir> [prefix]
  local dir="$1" pre="${2:-}" changed screen_chain
  changed=$(changed_files "$dir")
  [ -n "$changed" ] || return 0
  has() { printf '%s\n' "$changed" | grep -qE "$1"; }

  # ORM models without a migration: the schema drifts from the code (paths: the common Python layouts)
  if has '(^|/)models?(/.*)?\.py$' && ! has '(^|/)(migrations|alembic)/'; then
    echo "${pre}Reminder: models changed but no migration did. Schema changes follow \$db-migration (and the workspace guide's Shared data section when another repo maps the table)."
  fi
  if has '(^|/)(routes?|routers?|endpoints?|views|controllers|websocket|api)/.*\.(py|ts|js)$' && ! has '(^|/)(tests?|__tests__)/|(_test|\.test|\.spec)\.'; then
    echo "${pre}Reminder: routes/endpoints changed but no test did. Every behaviour change ships with a test (and the repo's guard tests must still pass)."
  fi
  if has '^requirements[^/]*\.txt$'; then
    echo "${pre}Reminder: dependencies changed. Check them against OSV / pip-audit; an accepted vulnerability needs a code-backed reason in docs/engineering/security.md."
  fi

  # Frontends. screen_chain = the files that define which screens exist (router, route table, menu, app shell) in the
  # common layouts; a repo whose chain lives elsewhere names it in AGENTS.md › Where code goes › Adding.
  if [ -f "$dir/package.json" ]; then
    screen_chain='^(src/)?(routes?/|router/|app/.*(page|layout)\.(jsx|tsx)$|App\.(jsx|tsx)$|.*(menu|navigation|nav|paths|routes)\.(js|jsx|ts|tsx)$)'
    if printf '%s\n' "$changed" | grep -vE '\.test\.[jt]sx?$' \
        | grep -qE "^src/(pages|components|screens|layouts?)/|$screen_chain|\.(css|scss)$|(^|/)locales/"; then
      echo "${pre}Reminder: UI files changed — browser smoke pending. The orchestrator runs \$verify-ui before the item is called done; without a browser, say \"browser smoke pending\"."
    fi
    if [ -f "$dir/docs/screens.md" ] && has "$screen_chain" && ! has '^docs/screens\.md$'; then
      echo "${pre}Reminder: a route/menu/screen-chain file changed but docs/screens.md did not — it drives \$ui-check and the e2e sweep (e2e/screens.ts)."
    fi
    # every locale under a locales/ folder must move together: compare the locales changed with the ones present
    # paths are data, never code: awk compares them as strings
    printf '%s\n' "$changed" | awk -F/ '{ for (i = 1; i < NF; i++) if ($i == "locales") { base = $1; for (j = 2; j <= i; j++) base = base "/" $j; sub(/\..*/, "", $(i + 1)); print base "\t" $(i + 1) } }' \
      | sort -u | cut -f1 | uniq -c \
      | while read -r got base; do
          all=$(find "$dir/$base" -mindepth 1 -maxdepth 1 ! -name '.*' 2>/dev/null | sed 's#.*/##; s/\..*//' | sort -u | grep -c .)
          [ "$got" -lt "$all" ] && echo "${pre}Reminder: $got of $all locales in $base changed. Every user-facing key lives in every locale (the fallback hides a missing key)."
        done
    if has '^package\.json$'; then
      echo "${pre}Reminder: package.json changed. Run npm audit --audit-level=high and state the result; an accepted vulnerability needs a written reason."
    fi
  fi
}

start="${CLAUDE_PROJECT_DIR:-$PWD}"   # where the session started, not where its last `cd` left the shell
if top=$(git -C "$start" rev-parse --show-toplevel 2>/dev/null); then
  remind_repo "$top"
else   # the workspace root: every wired repo
  while IFS= read -r d; do remind_repo "$d" "[$(basename "$d")] "; done < <(wired_repos "$start")
fi

summary=$(session_summary "$input")
[ -n "$summary" ] && echo "This session ran — $summary. Before a push or PR the gate needs /simplify, /code-review, the repo's *-reviewer agent and a security pass."
exit 0
