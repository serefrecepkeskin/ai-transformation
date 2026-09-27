#!/usr/bin/env bash
# Wire the agent kit into one repo, the workspace root or the kit itself. Idempotent; never overwrites a real file
# (a kit-owned copy that drifted is reported, not replaced — --refresh replaces it: that is how a kit update lands). This file is the ONE definition of "correctly wired":
# --check walks the same steps and only reports (check-drift.sh and install.sh --check call it).
#
#   scripts/link-repo.sh <repo> [--profile backend|frontend] [--tool claude|copilot|both] [--copy] [--check|--refresh]
#   scripts/link-repo.sh --root [--check]      # the workspace folder that holds agent-kit/ and the repos
#   scripts/link-repo.sh --kit  [--check]
#
# Two modes for a repo:
#   link (workspace)  the kit lives at <workspace>/agent-kit; kit-owned files are RELATIVE SYMLINKS into it
#   copy (single repo, --copy)  kit-owned files are COPIES; --check compares them byte for byte with the kit
# Kit-owned (linked or copied):
#   .claude/skills/<skill>  .claude/agents/<agent>.md  .claude/hooks   — skills/agents limited by profile (only_for)
#   copy mode also: docs/engineering/principles.md (the workspace keeps them in the root AGENTS.md instead)
# Always copies, compared byte for byte: .claude/settings.json (settings.<profile>.json; not for tool=copilot),
#   .github/workflows/pr-evidence.yml (the CI half of the PR gate)
# Repo-owned seeds, written only when absent: AGENTS.md, CLAUDE.md, templates/repo.<profile>/** (docs, gates,
#   Copilot files) — after the bootstrap prompt they belong to the repo and are never compared.
# Generated: .github/agents/<agent>.agent.md Copilot twins (scripts/sync-copilot-agents.py; tool copilot|both).
# Remembered in <repo>/.claude/kit.conf (profile, tool, mode), so a rerun needs no flags.
# Root: AGENTS.md, CLAUDE.md -> agent-kit/platform/ · .claude/{skills,agents} -> ../agent-kit/… ·
#   .claude/settings.json (copy of settings.root.json) · workspace.code-workspace (generated from root/workspace.conf)
#   · agent-work/
# Kit: CLAUDE.md imports AGENTS.md · .claude/settings.json copy of settings.kit.json · .gitignore has the personal
#   settings file · nothing under humans/ is larger than 2 MB
set -euo pipefail
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WS="$(dirname "$KIT")"
CONF="$KIT/root/workspace.conf"
# shellcheck source=../hooks/_changed.sh
. "$KIT/hooks/_changed.sh"   # conf_get, conf_repos, detect_profile

check=0; refresh=0; mode=repo; profile=""; tool=""; m=""; target=""
while [ $# -gt 0 ]; do
  case "$1" in
    --check) check=1 ;;
    --root) mode=root ;;
    --kit) mode=kit ;;
    --copy) m=copy ;;
    --refresh) refresh=1 ;;
    --profile) profile="${2:?--profile needs backend|frontend}"; shift ;;
    --tool) tool="${2:?--tool needs claude|copilot|both}"; shift ;;
    *) target="$1" ;;
  esac
  shift
done

fail=0
say() { # say ok|warn|<finding> <message> — anything but ok/warn marks the run as failed
  printf '%-7s %s\n' "$1" "$2"
  case "$1" in ok|warn) ;; *) fail=1 ;; esac
}

link() { # link <dest> <relative-target>
  local dest="$1" rel="$2"
  if [ -L "$dest" ]; then
    if [ "$(readlink "$dest")" != "$rel" ]; then
      [ "$check" = 1 ] && { say drift "$dest -> $(readlink "$dest") (want $rel)"; return; }
      ln -sfn "$rel" "$dest"; echo "relink  $dest -> $rel"; return
    fi
    if [ -e "$dest" ]; then say ok "$dest"; else say missing "$dest -> $rel (dangling)"; fi
    return
  fi
  [ -e "$dest" ] && { say skip "$dest exists and is not a symlink — an older hand-made copy? move it away (e.g. to <name>.old) and rerun"; return; }
  [ "$check" = 1 ] && { say missing "$dest"; return; }
  mkdir -p "$(dirname "$dest")"; ln -s "$rel" "$dest"; echo "link    $dest -> $rel"
}

same() { # same <kit-file-or-dir> <dest> — identical content (bytecode caches ignored)
  if [ -d "$1" ]; then diff -rq -x __pycache__ -x .DS_Store "$1" "$2" > /dev/null 2>&1; else cmp -s "$1" "$2"; fi
}

put() { # put <kit-file-or-dir> <dest> — the copy itself, without bytecode caches
  rm -rf "$2"; mkdir -p "$(dirname "$2")"; cp -Rp "$1" "$2"
  [ -d "$2" ] && find "$2" \( -name __pycache__ -o -name .DS_Store \) -prune -exec rm -rf {} + 2>/dev/null
  return 0
}

copy() { # copy <kit-file-or-dir> <dest> — copy when absent; a present copy must be identical (--refresh replaces it)
  local src="$1" dest="$2"
  if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
    [ "$check" = 1 ] && { say missing "$dest (copy of ${src#"$KIT"/})"; return; }
    put "$src" "$dest"; echo "copy    $dest"
  elif [ -L "$dest" ]; then
    say drift "$dest is a symlink but this repo is in copy mode"
  elif same "$src" "$dest"; then
    say ok "$dest"
  elif [ "$refresh" = 1 ] && [ "$check" = 0 ]; then
    put "$src" "$dest"; echo "refresh $dest"
  else
    say drift "$dest differs from ${src#"$KIT"/} — rerun with --refresh to take the kit's version (personal Claude rules go in settings.local.json)"
  fi
}

seed() { # seed <kit-file> <dest> [sed-expression] — write once when absent; afterwards the repo owns it
  local src="$1" dest="$2" expr="${3:-}"
  [ -e "$dest" ] && return 0
  mkdir -p "$(dirname "$dest")"
  if [ -n "$expr" ]; then sed "$expr" "$src" > "$dest"; else cp -p "$src" "$dest"; fi
  echo "seed    $dest"
}

ignore() { # ignore <.gitignore> <line> — make sure a line is present
  local file="$1" line="$2"
  if grep -qxF "$line" "$file" 2>/dev/null; then say ok "$file has $line"
  elif [ "$check" = 1 ]; then say missing "$line in $file"
  else
    [ -s "$file" ] && [ -n "$(tail -c1 "$file")" ] && echo >> "$file"
    echo "$line" >> "$file"; echo "add     $line to $file"
  fi
}

only_for() { # only_for <skill|agent[.md]> — the one profile it belongs to; empty = every profile
  case "${1%.md}" in
    new-endpoint|db-migration|backend-reviewer) echo backend ;;
    verify-ui|ui-check|impeccable|frontend-reviewer) echo frontend ;;
  esac
}

place() { # place <dest> <kit-path> <link-target> — link (workspace) or copy (single repo)
  if [ "$m" = copy ]; then copy "$2" "$1"; else link "$1" "$3"; fi
}

wire() { # wire <dest> <kit-path> <link-target> <name> — place it, or prune it when it belongs to the other profile
  local p; p="$(only_for "$4")"
  if [ -n "$p" ] && [ "$p" != "$profile" ]; then
    [ -e "$1" ] || [ -L "$1" ] || return 0
    # only the kit's own link or an untouched kit copy is removed; anything else is the repo's
    if [ "$(readlink "$1" 2>/dev/null)" != "$3" ] && ! same "$2" "$1"; then
      say warn "$1 has the name of a $p-only kit item but is the repo's own — left alone"; return 0
    fi
    if [ "$check" = 1 ]; then say stale "$1 (only for $p repos)"; else rm -rf "$1"; echo "prune   $1"; fi
    return 0
  fi
  place "$1" "$2" "$3"
}

prune_links() { # prune_links <dir> — kit links whose target the kit no longer has
  local l
  for l in "$1"/*; do
    [ -L "$l" ] && [ ! -e "$l" ] || continue
    if [ "$check" = 1 ]; then say stale "$l (kit no longer has it)"; else rm "$l"; echo "prune   $l"; fi
  done
}

workspace_file() { # the .code-workspace the root gets: the root, the kit, then every repo in workspace.conf
  conf_repos "$CONF" | python3 -c '
import json, sys
folders = [{"path": "."}, {"path": "agent-kit"}] + [{"path": line.split()[0]} for line in sys.stdin if line.strip()]
print(json.dumps({"folders": folders, "settings": {}}, indent=2))'
}

if [ "$mode" = root ]; then
  echo "== root $WS"
  [ -f "$CONF" ] || { echo "no $CONF — run the template's install.sh on the workspace first" >&2; exit 2; }
  [ "$check" = 1 ] || mkdir -p "$WS/.claude" "$WS/agent-work"
  link "$WS/AGENTS.md" "agent-kit/platform/AGENTS.md"
  link "$WS/CLAUDE.md" "agent-kit/platform/CLAUDE.md"
  link "$WS/.claude/skills" "../agent-kit/skills"
  link "$WS/.claude/agents" "../agent-kit/agents"
  copy "$KIT/templates/settings.root.json" "$WS/.claude/settings.json"
  want="$(workspace_file)"
  if [ -f "$WS/workspace.code-workspace" ] && [ "$(cat "$WS/workspace.code-workspace")" = "$want" ]; then
    say ok "$WS/workspace.code-workspace"
  elif [ "$check" = 1 ]; then
    say drift "$WS/workspace.code-workspace does not list root/workspace.conf's repos — rerun link-repo.sh --root"
  else
    printf '%s\n' "$want" > "$WS/workspace.code-workspace"; echo "write   $WS/workspace.code-workspace"
  fi
  exit "$fail"
fi

if [ "$mode" = kit ]; then
  echo "== kit $KIT"
  if grep -qx '@AGENTS.md' "$KIT/CLAUDE.md" 2>/dev/null; then say ok "$KIT/CLAUDE.md"
  else say missing "$KIT/CLAUDE.md importing @AGENTS.md"; fi
  copy "$KIT/templates/settings.kit.json" "$KIT/.claude/settings.json"
  ignore "$KIT/.gitignore" ".claude/settings.local.json"
  big="$(find "$KIT/humans" -type f -size +2M 2>/dev/null || true)"
  if [ -n "$big" ]; then say oversize "humans/ files over 2 MB (keep them outside git): $(echo "$big" | tr '\n' ' ')"
  else say ok "$KIT/humans has no file over 2 MB"; fi
  exit "$fail"
fi

[ -n "$target" ] || { echo "usage: link-repo.sh <repo> [--profile p] [--tool t] [--copy] [--check] | --root | --kit" >&2; exit 2; }
[[ "$target" = /* ]] || target="$WS/$target"
target="$(cd "$target" && pwd)"
repoconf="$target/.claude/kit.conf"
name="$(basename "$target")"
# flags, else what the repo remembers, else the workspace file, else autodetect
# flags win; then the source of truth for the mode: workspace.conf in a workspace (link), kit.conf in a single repo
# (copy); then autodetect. kit.conf only mirrors what was applied, so a workspace.conf edit takes effect on rerun.
[ -n "$m" ] || m="$(conf_get "$repoconf" mode)"; [ "$m" = copy ] || m=link
ws_profile="$(conf_repos "$CONF" | awk -v n="$name" '$1 == n { p = $2 } END { print p }')"
if [ "$m" = link ]; then
  [ -n "$profile" ] || profile="$ws_profile"
  [ -n "$tool" ] || tool="$(conf_get "$CONF" tool)"
fi
[ -n "$profile" ] || profile="$(conf_get "$repoconf" profile)"
[ -n "$profile" ] || profile="$(detect_profile "$target")"
[ -n "$profile" ] || profile=backend
[ -n "$tool" ] || tool="$(conf_get "$repoconf" tool)"
[ -n "$tool" ] || tool=both
case "$profile" in backend|frontend) ;; *) echo "unknown profile $profile" >&2; exit 2 ;; esac
case "$tool" in claude|copilot|both) ;; *) echo "unknown tool $tool" >&2; exit 2 ;; esac
echo "== $name ($profile, $tool, $m)"

skip_for_tool() { # repo-relative seed paths that belong only to the runtime not in use
  case "$tool" in
    claude)  case "$1" in .github/copilot-instructions.md|.github/agents/*|.github/hooks/*|.github/workflows/copilot-setup-steps.yml|.vscode/*) return 0 ;; esac ;;
    copilot) case "$1" in .mcp.json) return 0 ;; esac ;;
  esac
  return 1
}

if [ "$m" = copy ]; then
  platform_line='Principles: `docs/engineering/principles.md` (imported by CLAUDE.md; read it first otherwise).'
  claude_md='@AGENTS.md\n@docs/engineering/principles.md'
  guide='[AGENTS.md](../AGENTS.md) and [docs/engineering/principles.md](../docs/engineering/principles.md)'
else
  platform_line='Platform guide: `../AGENTS.md` (loaded by Claude Code started at the workspace root; read it first otherwise).'
  claude_md='@AGENTS.md'
  guide='the workspace platform guide [AGENTS.md](../../AGENTS.md) (the folder above this repo), then this repo'"'"'s [AGENTS.md](../AGENTS.md)'
fi

# kit-owned: skills, agents, hooks (+ principles in copy mode)
[ "$check" = 1 ] || mkdir -p "$target/.claude/skills" "$target/.claude/agents"
[ "$m" = copy ] || { prune_links "$target/.claude/skills"; prune_links "$target/.claude/agents"; }
for s in "$KIT"/skills/*/; do
  n="$(basename "$s")"; wire "$target/.claude/skills/$n" "$KIT/skills/$n" "../../../agent-kit/skills/$n" "$n"
done
for a in "$KIT"/agents/*.md; do
  n="$(basename "$a")"; wire "$target/.claude/agents/$n" "$a" "../../../agent-kit/agents/$n" "$n"
done
place "$target/.claude/hooks" "$KIT/hooks" "../../agent-kit/hooks"
[ "$m" = copy ] && copy "$KIT/platform/principles.md" "$target/docs/engineering/principles.md"

# kit-owned copies
[ "$tool" = copilot ] || copy "$KIT/templates/settings.$profile.json" "$target/.claude/settings.json"
copy "$KIT/templates/pr-evidence.yml" "$target/.github/workflows/pr-evidence.yml"
ignore "$target/.gitignore" ".claude/settings.local.json"
[ "$m" = copy ] && ignore "$target/.gitignore" "agent-work/"

# repo-owned seeds — written once, then the repo's; never compared
if [ "$check" = 0 ]; then
  seed "$KIT/templates/AGENTS.$profile.md" "$target/AGENTS.md" "s|{{PLATFORM_LINE}}|$platform_line|"
  if [ "$tool" != copilot ] && [ ! -e "$target/CLAUDE.md" ]; then
    printf '# Agent instructions\n\n%b\n' "$claude_md" > "$target/CLAUDE.md"; echo "seed    $target/CLAUDE.md"
  fi
  seeds="$KIT/templates/repo.$profile"
  while IFS= read -r -d '' f; do
    rel="${f#"$seeds"/}"
    skip_for_tool "$rel" && continue
    if [ "$rel" = .github/copilot-instructions.md ]; then seed "$f" "$target/$rel" "s|{{GUIDE}}|$guide|"
    else seed "$f" "$target/$rel"; fi
  done < <(find "$seeds" -type f -print0)
  printf 'profile=%s\ntool=%s\nmode=%s\n' "$profile" "$tool" "$m" > "$repoconf.new"
  if cmp -s "$repoconf.new" "$repoconf"; then rm "$repoconf.new"; else mv "$repoconf.new" "$repoconf"; echo "write   $repoconf"; fi
fi

# Copilot twins of the agents
if [ "$tool" != claude ]; then
  if [ "$check" = 1 ]; then
    if python3 "$KIT/scripts/sync-copilot-agents.py" "$target" --check > /dev/null; then say ok "$target/.github/agents"
    else say stale "$target/.github/agents — rerun link-repo.sh"; fi
  else
    python3 "$KIT/scripts/sync-copilot-agents.py" "$target" | grep -v '^ok ' || true
  fi
fi

if [ "$check" = 1 ]; then
  if [ "$(printf 'profile=%s\ntool=%s\nmode=%s' "$profile" "$tool" "$m")" != "$(cat "$repoconf" 2>/dev/null)" ]; then
    say drift "$repoconf does not match the settings in effect ($profile, $tool, $m) — rerun link-repo.sh"
  fi
  if [ "$tool" != copilot ]; then
    if grep -qx '@AGENTS.md' "$target/CLAUDE.md" 2>/dev/null; then say ok "$target/CLAUDE.md"
    else say drift "$target/CLAUDE.md does not import @AGENTS.md"; fi
  fi
  tpl="$KIT/templates/AGENTS.$profile.md"
  if [ ! -f "$target/AGENTS.md" ]; then
    say missing "$target/AGENTS.md"
  else
    want="$(grep '^## ' "$tpl")"; got="$(grep '^## ' "$target/AGENTS.md")"
    if [ "$want" = "$got" ]; then say ok "$target/AGENTS.md headings"
    else say drift "$target/AGENTS.md headings differ from templates/AGENTS.$profile.md"; diff <(echo "$want") <(echo "$got") | sed 's/^/        /' || true; fi
    n="$(wc -c < "$target/AGENTS.md" | tr -d ' ')"
    [ "$n" -le 12000 ] || say warn "$target/AGENTS.md is $n bytes (target ≤ 12000 — it loads on every request)"
  fi
  exit "$fail"
fi
echo "done: $target"
