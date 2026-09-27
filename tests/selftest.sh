#!/usr/bin/env bash
# Self-test of the template: installs into throwaway repos/workspaces and checks the result. bash 3.2 + python3 + git.
#   tests/selftest.sh            # exit 0 = every check passed; the first failure stops it with a reason
set -uo pipefail
T="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(cd "$(mktemp -d)" && pwd -P)"; trap 'rm -rf "$TMP"' EXIT   # -P: macOS /var is a symlink to /private/var
export GIT_AUTHOR_NAME=selftest GIT_AUTHOR_EMAIL=selftest@example.invalid
export GIT_COMMITTER_NAME=selftest GIT_COMMITTER_EMAIL=selftest@example.invalid
pass=0
ok()   { pass=$((pass + 1)); printf 'ok    %s\n' "$1"; }
fail() { printf 'FAIL  %s\n' "$1" >&2; [ -n "${2:-}" ] && printf '%s\n' "$2" | sed 's/^/      /' >&2; exit 1; }
check() { local msg="$1"; shift; if "$@" > /dev/null 2>&1; then ok "$msg"; else fail "$msg"; fi; }
repo() { # repo <dir> <manifest> — a git repo with one commit
  mkdir -p "$1" && ( cd "$1" && git init -q && printf '%s\n' "$3" > "$2" && git add -A && git commit -qm init )
}
gate() { # gate <hooks-dir> <payload-json> — exit code of the PR gate reached through the repo's hooks
  local hooks="$1"; shift
  printf '%s' "$1" | "$hooks/pr-gate.sh" > "$TMP/gate.out" 2>&1
}

# ---------- (d) (e) (g) static ----------
hits="$(grep -rIn -i 'vira' --exclude-dir=.git --exclude-dir=node_modules --exclude=selftest.sh "$T" || true)"
[ -z "$hits" ] || fail "no workspace-specific name in the template" "$hits"
ok "no workspace-specific name in the template"
for f in "$T"/install.sh "$T"/kit/install.sh "$T"/kit/scripts/*.sh "$T"/kit/hooks/*.sh "$T"/tests/*.sh; do
  bash -n "$f" || fail "bash -n $f"
done
ok "bash -n every script"
python3 -m py_compile "$T"/kit/scripts/*.py "$T"/kit/hooks/*.py || fail "py_compile"
ok "py_compile every python file"
python3 - "$T" <<'PY' || fail "every JSON file parses (JSONC comments stripped)"
import json, pathlib, re, sys
for p in pathlib.Path(sys.argv[1]).rglob("*.json"):
    if "node_modules" in p.parts or "impeccable" in p.parts:
        continue
    text = re.sub(r"^\s*//.*$", "", p.read_text(), flags=re.M)
    json.loads(text)
PY
ok "every JSON file parses"
python3 -c "import sys; a=open(sys.argv[1]).read(); p=open(sys.argv[2]).read(); sys.exit(0 if p in a else 1)" \
  "$T/kit/platform/AGENTS.md" "$T/kit/platform/principles.md" || fail "platform/AGENTS.md embeds principles.md verbatim"
ok "platform/AGENTS.md embeds principles.md verbatim"
for h in "$T"/kit/hooks/*.sh "$T"/kit/hooks/pr_gate.py "$T"/kit/scripts/*.sh "$T"/kit/scripts/*.py "$T"/kit/install.sh "$T"/install.sh; do
  [ -x "$h" ] || fail "executable: $h"
done
ok "hooks and scripts are executable"

# ---------- (a) workspace ----------
W="$TMP/ws"
repo "$W/py-svc" pyproject.toml '[project]
name = "py-svc"'
repo "$W/web-app" package.json '{"name": "web-app"}'
repo "$W/docs-site" README.md 'docs'
"$T/install.sh" "$W" --yes --tool both > "$TMP/ws.log" 2>&1 || fail "workspace install exits 0" "$(tail -20 "$TMP/ws.log")"
ok "workspace install exits 0"
grep -qx 'check-drift: clean' "$TMP/ws.log" || fail "workspace install ends clean" "$(grep -v '^ok ' "$TMP/ws.log" | tail -20)"
ok "workspace install ends clean"
check "agent-kit is a git repo with a commit and a clean tree" \
  sh -c "git -C '$W/agent-kit' log --oneline -1 && [ -z \"\$(git -C '$W/agent-kit' status --porcelain)\" ]"
[ -z "$(cd "$W" && find . -type l ! -exec test -e {} \; -print)" ] || fail "no dangling symlink"
ok "no dangling symlink"
check "root AGENTS.md is the platform guide" test "$(readlink "$W/AGENTS.md")" = agent-kit/platform/AGENTS.md
check "workspace kit carries the platform docs" test -f "$W/agent-kit/platform/SECURITY.md" -a -f "$W/agent-kit/platform/DEPLOYMENT.md" -a -f "$W/agent-kit/platform/SCHEMA.md"
check "backend gets new-endpoint, not verify-ui" sh -c "[ -L '$W/py-svc/.claude/skills/new-endpoint' ] && [ ! -e '$W/py-svc/.claude/skills/verify-ui' ]"
check "frontend gets verify-ui + impeccable, not new-endpoint" \
  sh -c "[ -L '$W/web-app/.claude/skills/verify-ui' ] && [ -L '$W/web-app/.claude/skills/impeccable' ] && [ ! -e '$W/web-app/.claude/skills/new-endpoint' ]"
check "Copilot twins generated per profile" \
  sh -c "[ -f '$W/web-app/.github/agents/frontend-reviewer.agent.md' ] && [ ! -e '$W/py-svc/.github/agents/frontend-reviewer.agent.md' ]"
check "skip repo left untouched" sh -c "[ -z \"\$(git -C '$W/docs-site' status --porcelain)\" ]"
check "workspace file lists every repo" grep -q docs-site "$W/workspace.code-workspace"
check "repo AGENTS.md has the template headings" sh -c "grep -c '^## ' '$W/py-svc/AGENTS.md' | grep -qx 8"

# gate: a new branch with no trail is blocked, the skip passes and is logged, a review.md with a Gate block passes
git -C "$W/py-svc" switch -q -c feat/try
H="$W/py-svc/.claude/hooks"
payload="{\"tool_input\":{\"command\":\"git -C $W/py-svc push\"},\"cwd\":\"$W\",\"session_id\":\"none\"}"
gate "$H" "$payload"; [ $? = 2 ] || fail "gate blocks a push without reviews" "$(cat "$TMP/gate.out")"
grep -q "agent-work/feat-try/py-svc/review.md" "$TMP/gate.out" || fail "gate names the per-repo review path" "$(cat "$TMP/gate.out")"
ok "gate blocks a push without reviews and names agent-work/<branch>/<repo>/review.md"
skip="{\"tool_input\":{\"command\":\"KIT_GATE_SKIP=1 KIT_GATE_REASON=selftest git -C $W/py-svc push\"},\"cwd\":\"$W\",\"session_id\":\"none\"}"
gate "$H" "$skip" || fail "gate skip passes" "$(cat "$TMP/gate.out")"
check "gate skip is logged at the workspace root" test -s "$W/agent-work/feat-try/py-svc/gate-skips.log"
mkdir -p "$W/agent-work/feat-try/py-svc"
printf '# review\n\n## Gate\nsimplify · code-review · backend-reviewer · security-review\n' > "$W/agent-work/feat-try/py-svc/review.md"
gate "$H" "$payload" || fail "gate passes with a carried Gate block" "$(cat "$TMP/gate.out")"
ok "gate passes with a carried Gate block"

# (f) idempotent
"$T/install.sh" "$W" --yes > "$TMP/ws2.log" 2>&1 || fail "workspace rerun exits 0" "$(tail -20 "$TMP/ws2.log")"
changes="$(grep -E '^(link|relink|copy|seed|write|wrote|add|prune) ' "$TMP/ws2.log" || true)"
[ -z "$changes" ] || fail "workspace rerun changes nothing" "$changes"
ok "workspace rerun changes nothing"

# drift is caught
printf '\n' >> "$W/web-app/.github/workflows/pr-evidence.yml"
"$W/agent-kit/scripts/check-drift.sh" > "$TMP/drift.log" 2>&1 && fail "check-drift catches an edited kit copy" "$(cat "$TMP/drift.log")"
grep -q "drift .*pr-evidence.yml" "$TMP/drift.log" || fail "check-drift names the drifted file" "$(cat "$TMP/drift.log")"
ok "check-drift catches an edited kit copy"
"$W/agent-kit/install.sh" --no-clone > "$TMP/kd.log" 2>&1 && fail "agent-kit/install.sh exits non-zero while drift remains" "$(tail -5 "$TMP/kd.log")"
ok "agent-kit/install.sh exits non-zero while drift remains"
"$W/agent-kit/install.sh" --no-clone --refresh > "$TMP/kr.log" 2>&1 || fail "--refresh brings the kit copy back" "$(tail -10 "$TMP/kr.log")"
ok "--refresh brings the kit copy back (check-drift clean)"
grep -q 'tool: both' "$TMP/ws2.log" || fail "a workspace rerun keeps the tool from workspace.conf" "$(grep -m1 'tool:' "$TMP/ws2.log")"
ok "a workspace rerun keeps the tool from workspace.conf"

# workspace.conf is the source of truth: a profile edit takes effect on the next install
sed -i.bak 's/^repo py-svc backend/repo py-svc frontend/' "$W/agent-kit/root/workspace.conf"
"$W/agent-kit/install.sh" --no-clone > "$TMP/sw.log" 2>&1 || true
[ -L "$W/py-svc/.claude/skills/verify-ui" ] && [ ! -e "$W/py-svc/.claude/skills/new-endpoint" ] && grep -qx profile=frontend "$W/py-svc/.claude/kit.conf" \
  || fail "a workspace.conf profile edit takes effect" "$(grep -v '^ok ' "$TMP/sw.log" | tail -8)"
ok "a workspace.conf profile edit takes effect"
mv "$W/agent-kit/root/workspace.conf.bak" "$W/agent-kit/root/workspace.conf"
"$W/agent-kit/install.sh" --no-clone > /dev/null 2>&1; [ -L "$W/py-svc/.claude/skills/new-endpoint" ] || fail "switching back restores the backend kit"

"$T/install.sh" "$W/web-app" --yes > "$TMP/in.log" 2>&1 && fail "a single-repo install inside a workspace is refused" "$(tail -3 "$TMP/in.log")"
ok "a single-repo install inside a workspace is refused"
"$T/install.sh" "$T" --yes > /dev/null 2>&1 && fail "installing into the template itself is refused"
ok "installing into the template itself is refused"
promo="{\"tool_input\":{\"command\":\"cd $W/py-svc && gh pr create --base production --title t\"},\"cwd\":\"$W\",\"session_id\":\"none\"}"
gate "$H" "$promo" || fail "a promotion PR passes the gate (as in pr-evidence.yml)" "$(cat "$TMP/gate.out")"
ok "a promotion PR passes the gate (as in pr-evidence.yml)"
python3 -c "import json,sys; p=json.load(open(sys.argv[1]))['permissions']; sys.exit(0 if 'Bash(gh pr merge:*)' in p['ask'] and 'Bash(gh pr merge:*)' not in p['deny'] else 1)" \
  "$W/py-svc/.claude/settings.json" || fail "gh pr merge asks, it is not denied"
ok "gh pr merge asks, it is not denied"

# a repo's own item with the name of the other profile's skill is never pruned
mkdir -p "$W/web-app/.claude/skills/new-endpoint" && echo own > "$W/web-app/.claude/skills/new-endpoint/SKILL.md"
"$W/agent-kit/scripts/link-repo.sh" web-app > /dev/null 2>&1 || true
[ -f "$W/web-app/.claude/skills/new-endpoint/SKILL.md" ] || fail "a repo's own same-named skill survives link-repo"
ok "a repo's own same-named skill survives link-repo"
rm -rf "$W/web-app/.claude/skills/new-endpoint"

# gh pr create -R <repo> from the workspace root reaches that repo's gate; an unknown target is blocked
root_pr="{\"tool_input\":{\"command\":\"gh pr create -R acme/py-svc --title t --body x\"},\"cwd\":\"$W\",\"session_id\":\"none\"}"
gate "$H" "$root_pr"; [ $? = 2 ] && grep -q "py-svc@feat/try" "$TMP/gate.out" || fail "gh pr create -R from the root is gated for that repo" "$(cat "$TMP/gate.out")"
ok "gh pr create -R from the root is gated for that repo"
nowhere="{\"tool_input\":{\"command\":\"gh pr create -R acme/elsewhere --title t\"},\"cwd\":\"$W\",\"session_id\":\"none\"}"
gate "$H" "$nowhere"; [ $? = 2 ] || fail "a PR for an unknown repo from the root is blocked" "$(cat "$TMP/gate.out")"
ok "a PR for an unknown repo from the root is blocked"

# ---------- (b) single frontend repo ----------
F="$TMP/lone-web"
repo "$F" package.json '{"name": "lone-web"}'
"$T/install.sh" "$F" --yes --tool both > "$TMP/f.log" 2>&1 || fail "single frontend install exits 0" "$(tail -20 "$TMP/f.log")"
[ -z "$(find "$F" -type l)" ] || fail "single repo has no symlinks" "$(find "$F" -type l)"
ok "single repo has no symlinks"
check "single frontend: skills copied by profile" sh -c "[ -d '$F/.claude/skills/verify-ui' ] && [ ! -e '$F/.claude/skills/new-endpoint' ]"
check "single repo: principles copied" test -f "$F/docs/engineering/principles.md"
check "single repo: security doc seeded" test -f "$F/docs/engineering/security.md"
[ -z "$(find "$F/.claude" -name __pycache__)" ] || fail "no bytecode cache copied into the repo"
ok "no bytecode cache copied into the repo"
check "single repo: CLAUDE.md imports the principles" grep -qx '@docs/engineering/principles.md' "$F/CLAUDE.md"
check "single repo: agent-work ignored" grep -qx 'agent-work/' "$F/.gitignore"
check "single repo: Copilot pointer names the principles" grep -q principles.md "$F/.github/copilot-instructions.md"
"$T/install.sh" "$F" --check > "$TMP/fc.log" 2>&1 || fail "single repo --check is clean" "$(grep -v '^ok ' "$TMP/fc.log")"
ok "single repo --check is clean"
echo '{}' | (cd "$F" && CLAUDE_PROJECT_DIR="$F" "$F/.claude/hooks/remind-docs.sh") > /dev/null || fail "Stop hook runs in a copied repo"
ok "Stop hook runs in a copied repo"
git -C "$F" switch -q -c fix/x
gate "$F/.claude/hooks" "{\"tool_input\":{\"command\":\"git push\"},\"cwd\":\"$F\",\"session_id\":\"none\"}"
[ $? = 2 ] && grep -q "under $F" "$TMP/gate.out" || fail "single-repo gate keeps agent-work inside the repo" "$(cat "$TMP/gate.out")"
ok "single-repo gate keeps agent-work inside the repo"

# ---------- (c) single backend repo, Claude only ----------
B="$TMP/lone-api"
repo "$B" requirements.txt 'fastapi'
"$T/install.sh" "$B" --yes --tool claude > "$TMP/b.log" 2>&1 || fail "single backend install exits 0" "$(tail -20 "$TMP/b.log")"
check "backend: pre-commit seed" test -f "$B/.pre-commit-config.yaml"
mkdir -p "$B/api/routes" && echo 'x = 1' > "$B/api/routes/orders.py"
reminders="$(cd "$B" && echo '{}' | CLAUDE_PROJECT_DIR="$B" "$B/.claude/hooks/remind-docs.sh")"   # no pipe: grep -q + pipefail = SIGPIPE
printf '%s' "$reminders" | grep -q 'routes/endpoints changed but no test' || fail "the Stop hook notices a route change without a test" "$reminders"
ok "the Stop hook notices a route change without a test"
check "claude only: no Copilot files" sh -c "[ ! -e '$B/.github/copilot-instructions.md' ] && [ ! -d '$B/.github/agents' ] && [ ! -d '$B/.vscode' ]"
check "claude only: settings present" test -f "$B/.claude/settings.json"
"$T/install.sh" "$B" --check > /dev/null 2>&1 || fail "single backend --check is clean"
ok "single backend --check is clean"

echo "selftest: $pass checks passed"
