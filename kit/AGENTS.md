# agent-kit — Agent Guide

The single home of this workspace's agent setup. Repos do not copy it: `scripts/link-repo.sh` links skills, agents
and hooks into each repo and copies the settings and CI templates; `scripts/check-drift.sh` proves every copy and
link is current. Rules for the product code live in `platform/AGENTS.md` and each repo's `AGENTS.md`.

## Layout
- `platform/` — the workspace guide (linked as the root `AGENTS.md`/`CLAUDE.md`) and `principles.md` (the 12
  engineering principles; the guide embeds the same text).
- `skills/` — workflow and stack skills (+ `impeccable`, vendored) · `agents/` — reviewer agents.
- `hooks/` — format, reminders + session summary, the PR/push gate (`pr-gate.sh` → `pr_gate.py`).
- `templates/` — `AGENTS.{backend,frontend}.md` (fixed headings), `settings.{backend,frontend,root,kit}.json`,
  `pr-evidence.yml`, task-spec / plan / report / review, `repo.{backend,frontend}/` (seeds written once per repo).
- `scripts/` — `link-repo.sh` (the definition of "wired"), `check-drift.sh`, `sync-copilot-agents.py`.
- `root/` — `workspace.conf` (tool + repo → profile: the one list) and its README.
- `humans/` — for people (the AI-standards guide, reports, presentations). Do not read it unless asked.

## When you change something, what must follow
- A skill or agent body → nothing to relink (symlinks); an agent's name/description → rerun
  `scripts/link-repo.sh <repo>` in every repo and commit its regenerated `.github/agents/*.agent.md` there.
- `templates/settings.*.json` or `pr-evidence.yml` → the copies drift: recopy (delete + rerun `link-repo.sh`) and
  commit them in each repo; `settings.root.json` → rerun `link-repo.sh --root`.
- `templates/AGENTS.*.md` headings → every repo's `AGENTS.md` must follow in the same round.
- A new repo → a `repo <name> <backend|frontend>` line in `root/workspace.conf`, then `install.sh`.
- A hook → probe it from inside a repo **and** from the workspace root (it must work in both).
- `platform/principles.md` → paste the same text into `platform/AGENTS.md` (they must stay identical).
- Always finish with `scripts/check-drift.sh` → `check-drift: clean`.

## Rules
- `skills/impeccable/` is third-party (pbakaus/impeccable, Apache 2.0): update only with `npx impeccable update`,
  never by hand.
- A skill stays ≤ ~80 lines (detail in `references/`); scripts stay bash 3.2 / python3-stdlib compatible.
- No file over 2 MB in git (`link-repo.sh --kit --check` flags it); large decks stay outside the repo.

## Workflow
- Gates: `bash -n install.sh scripts/*.sh hooks/*.sh && python3 -m py_compile scripts/*.py hooks/*.py && scripts/check-drift.sh`
- Commit/PR via `$commit-and-pr`, base `main`; the PR gate applies here too.
