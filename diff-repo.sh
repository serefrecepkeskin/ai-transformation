#!/usr/bin/env bash
# Show how an installed repo has drifted from the kit. Read-only; exit 1 when anything is reported.
#   ./diff-repo.sh <backend|frontend|analyst> <repo-path> [--tool claude|copilot|both]
# Kit-owned files must be byte-identical (reported as `drift`): CLAUDE.md, copilot-instructions.md, hook
# scripts and manifests, the shared skills (commit-and-pr, implement-task, write-spec, verify-ui), agents and
# their Copilot twins.
# Everything else is repo-owned after the bootstrap prompt (AGENTS.md, docs/, stack skills with PLACEHOLDERs,
# settings, gate files) and is reported only when `missing`. Files of a runtime the repo does not use are
# ignored; --tool says which (auto-detected from CLAUDE.md / copilot-instructions.md when omitted). The
# vendored impeccable skill has its own updater and is skipped.
set -euo pipefail
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
usage() { echo "usage: diff-repo.sh <backend|frontend|analyst> <repo-path> [--tool claude|copilot|both]" >&2; exit 2; }
[ $# -ge 2 ] || usage
profile="$1"; target="$2"; shift 2
tool=""
while [ $# -gt 0 ]; do
  case "$1" in --tool) shift; tool="${1:-}" ;; --tool=*) tool="${1#--tool=}" ;; *) usage ;; esac
  shift
done
case "$profile" in backend|frontend|analyst) ;; *) usage ;; esac
src="$KIT/$profile"
[ -d "$target" ] || { echo "error: $target is not a directory" >&2; exit 1; }
target="$(cd "$target" && pwd)"
if [ -z "$tool" ]; then
  c=0; p=0; [ -e "$target/CLAUDE.md" ] && c=1; [ -e "$target/.github/copilot-instructions.md" ] && p=1
  if [ "$c$p" = 10 ]; then tool=claude; elif [ "$c$p" = 01 ]; then tool=copilot; else tool=both; fi
fi
case "$tool" in claude|copilot|both) ;; *) usage ;; esac

skip_for_tool() { # same rule as install.sh
  case "$tool" in
    claude)  case "$1" in .github/copilot-instructions.md|.github/agents/*|.github/hooks/*|.github/workflows/copilot-setup-steps.yml|.vscode/*) return 0 ;; esac ;;
    copilot) case "$1" in CLAUDE.md|.claude/settings.json|.mcp.json) return 0 ;; esac ;;
  esac
  return 1
}
owned() { # repo-relative path → 0 when the repo must keep it byte-identical
  case "$1" in
    CLAUDE.md|.github/copilot-instructions.md|.claude/hooks/*|.github/hooks/*|.claude/agents/*) return 0 ;;
    .github/agents/code-reviewer.agent.md|.github/agents/security-reviewer.agent.md) return 0 ;;
    .claude/skills/commit-and-pr/*|.claude/skills/implement-task/*|.claude/skills/write-spec/*) return 0 ;;
    .claude/skills/verify-ui/*) return 0 ;;
  esac
  return 1
}

status=0
report() { echo "$1 $2"; status=1; }
while IFS= read -r -d '' f; do
  rel="${f#"$src"/}"
  skip_for_tool "$rel" && continue
  if [ ! -e "$target/$rel" ]; then report missing "$rel"
  elif owned "$rel" && ! cmp -s "$f" "$target/$rel"; then report drift "$rel"
  fi
done < <(find "$src" -type f -not -name .DS_Store -not -path '*/impeccable/*' -print0)

[ "$status" = 0 ] && echo "clean: $target matches the kit ($profile, tool: $tool)"
exit $status
