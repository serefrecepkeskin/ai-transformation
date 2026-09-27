# Sourced by the hooks, the kit scripts and the template's install.sh — the one reader of workspace.conf / kit.conf.
# changed_files [dir] — every changed path in the repo at <dir> (default: cwd): modified, staged, untracked; one per
# line, repo-relative. One `git status` walk; renames report the new path.
changed_files() {
  git -C "${1:-.}" status --porcelain=v1 -uall --no-renames 2>/dev/null | cut -c4- | sort -u
}

# session_summary <hook-json> — "skills: … · agents: …" this session ran; same parser as the PR gate.
session_summary() {
  printf '%s' "$1" | python3 -B "$(dirname "${BASH_SOURCE[0]}")/pr_gate.py" --summary 2>/dev/null
}

# conf_get <file> <key> — the value of "key=value" in workspace.conf / kit.conf (a trailing # comment is dropped)
conf_get() {
  [ -f "$1" ] || return 0
  sed -n "s/^$2=\([^#[:space:]]*\).*/\1/p" "$1" | tail -1
}

# conf_repos <workspace.conf> [profiles-regex] — "<name> <profile>" per repo line (default: every profile). Names are
# plain folder names ([A-Za-z0-9._-]+, never . or ..): no path escapes the workspace, no glob expands.
conf_repos() {
  [ -f "$1" ] || return 0
  sed -nE "s/^repo[[:space:]]+([A-Za-z0-9._-]+)[[:space:]]+(${2:-backend|frontend|skip})([[:space:]].*)?\$/\1 \2/p" "$1" \
    | grep -vE '^\.{1,2} ' || true
}

# detect_profile <repo> — frontend | backend | "" (no manifest)
detect_profile() {
  if [ -f "$1/package.json" ]; then echo frontend
  elif [ -f "$1/pyproject.toml" ] || [ -f "$1/setup.py" ] || [ -f "$1/Pipfile" ] || ls "$1"/requirements*.txt > /dev/null 2>&1; then echo backend
  fi
}

# wired_repos <workspace-root> — every backend/frontend repo of workspace.conf that exists
wired_repos() {
  local name _
  while read -r name _; do
    [ -d "$1/$name/.git" ] && echo "$1/$name"
  done < <(conf_repos "$1/agent-kit/root/workspace.conf" 'backend|frontend')
}
