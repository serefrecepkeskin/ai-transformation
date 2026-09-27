#!/usr/bin/env bash
# Prove the workspace root, the kit and the repos are wired the way link-repo.sh leaves them. Read-only; exit 1 on
# any finding. What "wired" means lives only in link-repo.sh (--check mode); this script runs it everywhere.
#   agent-kit/scripts/check-drift.sh               # root + kit + every repo listed in root/workspace.conf
#   agent-kit/scripts/check-drift.sh api web …     # root + kit + just these
set -uo pipefail
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WS="$(dirname "$KIT")"
fail=0
run() { "$@" | grep -v '^ok ' ; [ "${PIPESTATUS[0]}" = 0 ] || fail=1; }

run "$KIT/scripts/link-repo.sh" --root --check
run "$KIT/scripts/link-repo.sh" --kit --check

# shellcheck source=../hooks/_changed.sh
. "$KIT/hooks/_changed.sh"
while IFS= read -r r; do run "$KIT/scripts/link-repo.sh" "$r" --check; done \
  < <(if [ $# -gt 0 ]; then printf '%s\n' "$@"; else wired_repos "$WS"; fi)

[ "$fail" = 0 ] && echo "check-drift: clean" || echo "check-drift: FINDINGS"
exit "$fail"
