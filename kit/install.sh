#!/usr/bin/env bash
# One command sets up this workspace on a machine: the folder that holds agent-kit/ gets every repo listed in
# root/workspace.conf (cloned when missing) and the whole agent wiring. Idempotent — rerun it after a kit update,
# a new repo in workspace.conf, or a broken link.
#
#   mkdir <workspace> && cd <workspace>
#   git clone <this kit's remote> agent-kit      # the folder name must be agent-kit
#   agent-kit/install.sh                         # clone missing repos + wire everything + check
#   agent-kit/install.sh --no-clone              # wire only the repos already there
#   agent-kit/install.sh --refresh               # after a kit change: replace kit-owned copies that drifted
#
# Steps: 1) clone every repo in root/workspace.conf that is missing (same Git host/owner as this kit's remote)
# 2) link-repo.sh --root  3) link-repo.sh --kit  4) link-repo.sh <repo> for each repo  5) check-drift.sh
# Personal permissions go in <dir>/.claude/settings.local.json — never shared, never created here.
set -uo pipefail
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WS="$(dirname "$KIT")"
clone=1; refresh=""
for a in "$@"; do
  case "$a" in --no-clone) clone=0 ;; --refresh) refresh=--refresh ;; *) echo "usage: install.sh [--no-clone] [--refresh]" >&2; exit 2 ;; esac
done
[ "$(basename "$KIT")" = agent-kit ] || { echo "install: this folder must be named agent-kit (the settings point to it)" >&2; exit 2; }
[ -f "$KIT/root/workspace.conf" ] || { echo "install: no root/workspace.conf — create it with the template's install.sh" >&2; exit 2; }

# shellcheck source=hooks/_changed.sh
. "$KIT/hooks/_changed.sh"   # conf_repos: validated folder names only
all=$(conf_repos "$KIT/root/workspace.conf" | cut -d' ' -f1)
repos=$(conf_repos "$KIT/root/workspace.conf" 'backend|frontend' | cut -d' ' -f1)
set -f   # the loops below split names on whitespace only
remote=$(git -C "$KIT" remote get-url origin 2>/dev/null || true)
# sibling repos live next to this kit on the same host/owner: https://host/owner/agent-kit(.git)(/) → https://host/owner/,
# git@host:owner/agent-kit.git → git@host:owner/, git@host:agent-kit.git → git@host:
clean="${remote%/}"; suffix=""; case "$clean" in *.git) suffix=".git"; clean="${clean%.git}" ;; esac
case "$clean" in */*) base="${clean%/*}/" ;; *:*) base="${clean%%:*}:" ;; *) base="" ;; esac

echo "== workspace: $WS"
missing=""
for r in $all; do   # every repo of the workspace is cloned; only backend/frontend ones get the kit
  [ -d "$WS/$r/.git" ] && continue
  if [ "$clone" = 1 ] && [ -n "$remote" ]; then
    echo "-- clone $r"
    git clone -q "$base$r$suffix" "$WS/$r" || missing="$missing $r"
  else
    missing="$missing $r"
  fi
done

"$KIT/scripts/link-repo.sh" --root $refresh
"$KIT/scripts/link-repo.sh" --kit $refresh
failed=""
for r in $repos; do
  [ -d "$WS/$r/.git" ] || continue
  "$KIT/scripts/link-repo.sh" "$r" $refresh || failed="$failed $r"
done

fresh=""
for r in $repos; do   # a branch cut before the kit reached it: the wiring shows up as local changes
  [ -d "$WS/$r/.git" ] && [ -n "$(git -C "$WS/$r" status --porcelain -- .claude .github .gitignore AGENTS.md CLAUDE.md)" ] \
    && fresh="$fresh $r"
done

echo
drift=0; report="$("$KIT/scripts/check-drift.sh" 2>&1)" || drift=1
printf '%s\n' "$report" | tail -1
[ "$drift" = 0 ] || printf '%s\n' "$report" | grep -vE '^(ok |==|check-drift)' | sed 's/^/  /'
[ -n "$fresh" ] && echo "install: kit wiring is new (uncommitted) in:$fresh — commit it there once, on a branch, through a PR"
[ -n "$missing" ] && echo "install: not cloned:$missing (no access, no remote, or --no-clone) — clone them next to agent-kit and rerun"
[ -n "$failed" ] && echo "install: link-repo.sh failed for:$failed — see the output above"
echo "Start Claude here:  cd \"$WS\" && claude"
[ -z "$missing$failed" ] && [ "$drift" = 0 ]
