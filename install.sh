#!/usr/bin/env bash
# Install the company agent kit into a repo or a whole workspace. Looks at the target, asks, then sets it up.
# Idempotent; it never overwrites a file the repo owns. After a template update: rerun with --refresh, which replaces
# the kit-owned copies (skills, agents, hooks, settings, CI check) that differ from the new kit.
#
#   ./install.sh [target]                         # target: a repo, or a folder of repos (default: current dir)
#   ./install.sh ~/code/api-service               # one backend repo  (pyproject.toml / requirements.txt / setup.py)
#   ./install.sh ~/code/web-app                   # one frontend repo (package.json)
#   ./install.sh ~/code/shop                      # a workspace: a folder whose sub-folders are git repos
#   ./install.sh <target> --check                 # report drift only, change nothing
#
# Flags (skip the questions): --tool claude|copilot|both · --profile backend|frontend (single repo) ·
#   --kit-remote <url> (workspace: the remote of the new agent-kit repo) · --new (empty repo: greenfield prompt) ·
#   --yes (accept every detected default) · --check · --refresh · --standalone (a repo inside a workspace, on purpose)
#
# What it builds:
#   single repo  kit files COPIED into <repo>/.claude/ (+ settings, CI check, docs/, gates, Copilot files),
#                12 engineering principles in docs/engineering/principles.md; agent-work/ in .gitignore
#   workspace    <workspace>/agent-kit — a new git repo made from kit/ (push it to your own remote), then
#                agent-kit/install.sh: the root (AGENTS.md, CLAUDE.md, .claude/, workspace.code-workspace,
#                agent-work/) and every repo linked to the kit by profile
# Then it prints the bootstrap prompt: paste it into the agent to fill the PLACEHOLDERs from the real code.
# Requires bash, git, python3 (Windows: Git Bash or WSL; symlinks need Developer Mode — or install repos one by one).
set -euo pipefail
TEMPLATE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT="$TEMPLATE/kit"
# shellcheck source=kit/hooks/_changed.sh
. "$KIT/hooks/_changed.sh"   # conf_get, conf_repos, detect_profile — the kit's own readers

target="."; tool=""; profile=""; kit_remote=""; new=0; yes=0; check=0; refresh=""; standalone=0
while [ $# -gt 0 ]; do
  case "$1" in
    --tool) tool="${2:?--tool needs claude|copilot|both}"; shift ;;
    --tool=*) tool="${1#--tool=}" ;;
    --profile) profile="${2:?--profile needs backend|frontend}"; shift ;;
    --kit-remote) kit_remote="${2:?--kit-remote needs a url}"; shift ;;
    --new) new=1 ;;
    --yes|-y) yes=1 ;;
    --check) check=1 ;;
    --refresh) refresh=--refresh ;;
    --standalone) standalone=1 ;;
    -h|--help) sed -n '2,23p' "$0"; exit 0 ;;
    -*) echo "unknown flag $1 (see --help)" >&2; exit 2 ;;
    *) target="$1" ;;
  esac
  shift
done
[ -d "$target" ] || { echo "error: $target is not a directory" >&2; exit 2; }
target="$(cd "$target" && pwd)"
[ "$target" = "$TEMPLATE" ] && { echo "error: that is the template itself — give the repo or workspace to install into" >&2; exit 2; }

interactive=0; [ "$yes" = 0 ] && [ -t 0 ] && interactive=1
ask() { # ask <question> <default> — the answer (the default without a terminal or with --yes)
  local a=""
  if [ "$interactive" = 1 ]; then read -r -p "$1 [$2] " a < /dev/tty || true; fi
  printf '%s' "${a:-$2}"
}
pick_tool() {
  [ -n "$tool" ] && return
  tool="$(ask "Which AI tool does the team use? claude / copilot / both" both)"
  case "$tool" in claude|copilot|both) ;; *) echo "unknown tool $tool" >&2; exit 2 ;; esac
}
print_prompt() { # print_prompt <profile> <mode>
  local prompt="$TEMPLATE/bootstrap-prompt.md"
  [ "$new" = 1 ] && prompt="$TEMPLATE/bootstrap-prompt-greenfield.md"
  echo
  echo "========================================================================"
  echo "NEXT: open the repo in your agent and paste everything below this line."
  echo "      (source: $(basename "$prompt") · profile: $1 · tool: $tool · mode: $2)"
  echo "========================================================================"
  echo
  sed -e "s/{{PROFILE}}/$1/g" -e "s/{{TOOL}}/$tool/g" -e "s/{{MODE}}/$2/g" "$prompt"
}

# ---------- what is the target? ----------
kind=""
if [ -e "$target/.git" ]; then
  kind=repo
else
  children=()
  for d in "$target"/*/; do
    d="${d%/}"; n="$(basename "$d")"
    [ -e "$d/.git" ] && [ "$n" != agent-kit ] && children+=("$n")
  done
  [ ${#children[@]} -gt 0 ] && kind=workspace
fi
[ -n "$kind" ] || { echo "error: $target is neither a git repo nor a folder of git repos — clone the repos first (an empty repo: git init, then rerun with --new)" >&2; exit 2; }

# ---------- single repo ----------
if [ "$kind" = repo ]; then
  sibling="$(dirname "$target")/agent-kit"
  if [ "$check" = 1 ]; then
    if [ "$(conf_get "$target/.claude/kit.conf" mode)" = link ]; then exec "$sibling/scripts/link-repo.sh" "$target" --check; fi
    exec "$KIT/scripts/link-repo.sh" "$target" --copy --check
  fi
  if [ -f "$sibling/root/workspace.conf" ] && [ "$standalone" = 0 ]; then
    echo "error: $(basename "$target") belongs to the workspace at $(dirname "$target") — install that folder (or add the repo" >&2
    echo "       to agent-kit/root/workspace.conf); --standalone copies the kit into this one repo anyway" >&2
    exit 2
  fi
  if [ -z "$profile" ]; then
    detected="$(detect_profile "$target")"
    if [ -f "$target/package.json" ] && { [ -f "$target/pyproject.toml" ] || [ -f "$target/setup.py" ] || ls "$target"/requirements*.txt > /dev/null 2>&1; }; then
      echo "note: both package.json and a Python manifest — is this a frontend or a Python service with JS tooling?" >&2
    fi
    if [ -z "$detected" ]; then
      [ "$new" = 1 ] || echo "note: no manifest found — an empty repo? rerun with --new for the greenfield prompt" >&2
      detected=backend
    fi
    profile="$(ask "$(basename "$target") looks like a $detected repo. Profile? backend / frontend" "$detected")"
  fi
  case "$profile" in backend|frontend) ;; *) echo "unknown profile $profile" >&2; exit 2 ;; esac
  pick_tool
  if [ -f "$(dirname "$target")/agent-kit/scripts/link-repo.sh" ]; then
    echo "note: $(dirname "$target")/agent-kit exists — this repo belongs to a workspace; install the workspace instead" >&2
  fi
  echo "== single repo: $target ($profile, $tool)"
  "$KIT/scripts/link-repo.sh" "$target" --profile "$profile" --tool "$tool" --copy $refresh
  echo
  "$KIT/scripts/link-repo.sh" "$target" --copy --check | grep -v '^ok ' || true
  print_prompt "$profile" single
  exit 0
fi

# ---------- workspace ----------
ws="$target"; kitdir="$ws/agent-kit"
if [ "$check" = 1 ]; then
  [ -x "$kitdir/scripts/check-drift.sh" ] || { echo "error: $kitdir is missing — install the workspace first" >&2; exit 2; }
  exec "$kitdir/scripts/check-drift.sh"
fi
echo "== workspace: $ws"
if [ -f "$kitdir/root/workspace.conf" ]; then
  echo "agent-kit already exists — rewiring from its root/workspace.conf (template files are not copied over it)."
  [ -n "$tool" ] || tool="$(conf_get "$kitdir/root/workspace.conf" tool)"
  for n in "${children[@]}"; do
    conf_repos "$kitdir/root/workspace.conf" | cut -d' ' -f1 | grep -qxF "$n" \
      || echo "note: $n is not in agent-kit/root/workspace.conf — add 'repo $n <backend|frontend|skip>' and rerun"
  done
else
  pick_tool
  conf="tool=$tool                  # claude | copilot | both"$'\n'
  echo "Repos found (profile from the manifest; 'skip' = no kit wiring):"
  for n in "${children[@]}"; do
    p="$(detect_profile "$ws/$n")"; p="${p:-skip}"
    p="$(ask "  $n" "$p")"
    case "$p" in backend|frontend|skip) ;; *) echo "unknown profile $p" >&2; exit 2 ;; esac
    conf+="repo $n $p"$'\n'
  done
  [ -e "$kitdir" ] && { echo "error: $kitdir exists but is not a kit (no root/workspace.conf)" >&2; exit 2; }
  mkdir -p "$kitdir"
  cp -Rp "$KIT/." "$kitdir/"
  printf '# The one list of this workspace — read by install.sh, link-repo.sh and check-drift.sh (see README.md here).\n%s' "$conf" \
    > "$kitdir/root/workspace.conf"
  sha="$(git -C "$TEMPLATE" rev-parse --short HEAD 2>/dev/null || echo unknown)"
  "$kitdir/scripts/link-repo.sh" --kit > /dev/null   # the kit's own settings, before the first commit
  git -C "$kitdir" init -q && git -C "$kitdir" symbolic-ref HEAD refs/heads/main   # git < 2.28 has no init -b
  git -C "$kitdir" add -A
  if git -C "$kitdir" commit -q -m "chore: agent kit from the ai-transformation template ($sha)"; then
    echo "agent-kit: new git repo, first commit made"
  else
    echo "agent-kit: created, but the first commit failed (git user.name/user.email?) — commit it yourself" >&2
  fi
  if [ -n "$kit_remote" ]; then
    git -C "$kitdir" remote add origin "$kit_remote" && echo "agent-kit: origin = $kit_remote (push it: git -C agent-kit push -u origin main)"
  else
    echo "agent-kit: no remote yet — create a repo for it and: git -C agent-kit remote add origin <url> && git -C agent-kit push -u origin main"
  fi
fi
status=0; "$kitdir/install.sh" --no-clone $refresh || status=$?
print_prompt "<each repo's profile>" workspace
exit "$status"
