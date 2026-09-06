#!/usr/bin/env bash
# Install one kit profile into a repository — by copy, inside the repo. Idempotent; never overwrites a
# file that is already there (--force does).
#   ./install.sh <backend|frontend|analyst> <repo-path> [--tool claude|copilot|both] [--force] [--new]
# The profile folder (backend/, frontend/, analyst/) IS the repo layout: every file under it lands at the
# same relative path in the target. --tool picks the AI runtime the repo uses and leaves the other
# runtime's files out (asked interactively when omitted on a terminal; `both` otherwise):
#   claude   skips .github/copilot-instructions.md, .github/agents/, .github/hooks/, copilot-setup-steps.yml, .vscode/
#   copilot  skips CLAUDE.md, .claude/settings.json, .mcp.json
#   (.claude/skills, .claude/hooks and .claude/agents are always copied: Copilot reads the skills natively,
#    its hook manifests call the same scripts, and the agents are the source the .agent.md twins come from)
# Afterwards the script appends `agent-work/**/shots/` to the repo's .gitignore (the work trail itself is
# committed with feature branches and deleted at merge) and prints the bootstrap prompt
# (--new: the greenfield one). Requires bash (Windows: Git Bash or WSL).
set -euo pipefail
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() { echo "usage: install.sh <backend|frontend|analyst> <repo-path> [--tool claude|copilot|both] [--force] [--new]" >&2; exit 2; }
[ $# -ge 2 ] || usage
profile="$1"; target="$2"; shift 2
force=0; new=0; tool=""
while [ $# -gt 0 ]; do
  case "$1" in
    --force) force=1 ;;
    --new) new=1 ;;
    --tool) shift; tool="${1:-}" ;;
    --tool=*) tool="${1#--tool=}" ;;
    *) usage ;;
  esac
  shift
done
case "$profile" in backend|frontend|analyst) ;; *) usage ;; esac
if [ -z "$tool" ]; then
  if [ -t 0 ]; then
    echo "Which AI tool does this repo use?"
    echo "  1) claude   — Claude Code"
    echo "  2) copilot  — GitHub Copilot (VS Code agent mode / coding agent)"
    echo "  3) both     — default"
    read -r -p "> " ans
    case "$ans" in 1|claude) tool=claude ;; 2|copilot) tool=copilot ;; ""|3|both) tool=both ;; *) usage ;; esac
  else
    tool=both
  fi
fi
case "$tool" in claude|copilot|both) ;; *) usage ;; esac

skip_for_tool() { # <repo-relative path> → 0 when the file belongs only to the runtime not in use
  case "$tool" in
    claude)  case "$1" in .github/copilot-instructions.md|.github/agents/*|.github/hooks/*|.github/workflows/copilot-setup-steps.yml|.vscode/*) return 0 ;; esac ;;
    copilot) case "$1" in CLAUDE.md|.claude/settings.json|.mcp.json) return 0 ;; esac ;;
  esac
  return 1
}

src="$KIT/$profile"
[ -d "$target" ] || { echo "error: $target is not a directory" >&2; exit 1; }
target="$(cd "$target" && pwd)"
[ -d "$target/.git" ] || echo "warn: $target is not a git repository — hooks resolve their paths through git" >&2
manifest=0
for m in package.json pyproject.toml setup.py go.mod Cargo.toml; do [ -e "$target/$m" ] && manifest=1; done
if [ "$new" = 0 ] && [ "$manifest" = 0 ]; then
  echo "note: no manifest found — if this repo is empty, rerun with --new for the greenfield prompt" >&2
elif [ "$new" = 1 ] && [ "$manifest" = 1 ]; then
  echo "warn: --new given, but this repo has a manifest — without --new you get the prompt that surveys it" >&2
fi

written=0; skipped=""; other=0
while IFS= read -r -d '' f; do            # file by file, dotfiles included, mode preserved
  rel="${f#"$src"/}"
  if skip_for_tool "$rel"; then other=$((other + 1)); continue; fi
  if [ -e "$target/$rel" ] && [ "$force" = 0 ]; then skipped="${skipped}${rel}"$'\n'; continue; fi
  mkdir -p "$(dirname "$target/$rel")"
  cp -p "$f" "$target/$rel"
  written=$((written + 1))
done < <(find "$src" -type f -not -name .DS_Store -print0)

if ! grep -qsxF 'agent-work/**/shots/' "$target/.gitignore"; then
  printf '\n# agent work trail (company kit): spec / plan / report / review ride with the branch; screenshots do not\nagent-work/**/shots/\n' >> "$target/.gitignore"
  echo "gitignore: added agent-work/**/shots/"
fi

echo
echo "$written file(s) written into $target (profile: $profile, tool: $tool)"
[ "$other" -gt 0 ] && echo "$other file(s) left out — they belong to the runtime this repo does not use ($tool)"
if [ -n "$skipped" ]; then
  n=$(printf '%s' "$skipped" | grep -c .)
  echo "$n left untouched (already present — rerun with --force to overwrite):"
  printf '%s' "$skipped" | head -20 | sed 's/^/  · /'
  [ "$n" -gt 20 ] && echo "  · … and $((n - 20)) more"
  if printf '%s' "$skipped" | grep -qx 'AGENTS.md'; then
    echo
    echo "note: the repo's own AGENTS.md was kept. Merge the 'Capabilities', 'Guardrails' and 'Work trail'"
    echo "      sections from $src/AGENTS.md into it — the bootstrap prompt's 'existing AGENTS.md' section"
    echo "      tells the agent to do exactly that."
  fi
fi

prompt="$KIT/bootstrap-prompt.md"
[ "$new" = 1 ] && prompt="$KIT/bootstrap-prompt-greenfield.md"
echo
echo "========================================================================"
echo "NEXT: open the repo in your agent and paste everything below this line."
echo "      (source: $(basename "$prompt") · profile: $profile · tool: $tool)"
echo "========================================================================"
echo
sed -e "s/{{PROFILE}}/$profile/g" -e "s/{{TOOL}}/$tool/g" "$prompt"
