# AI Transformation — Company Agent Kit

> Türkçe: [README.md](README.md) · Rationale (Turkish):
> [`humans/ai-coding-standardi-v2.docx`](humans/ai-coding-standardi-v2.docx) · Team walkthrough deck
> (Turkish): [`sunum.html`](sunum.html)

The shared structure for AI-assisted development. **One template, two tools:** Claude Code and GitHub Copilot read
the same skills and agent definitions. `install.sh` looks at its target and sets up one of three things:

| Target | Detected by | What it sets up |
|---|---|---|
| **A frontend repo** | `package.json` | Kit files **copied** into the repo: skills, reviewer agents, hooks, permissions, the PR gate, the `docs/` knowledge base, the commit gate (husky + lint-staged), a Playwright e2e floor, Copilot files |
| **A backend repo** | `pyproject.toml` / `requirements*.txt` / `setup.py` | The same with the backend profile: `new-endpoint`, `db-migration`, the pre-commit gate |
| **A workspace** | a folder whose sub-folders are git repos | Creates the workspace's own **`agent-kit` repo** next to them (from this template), wires the root and **links** every repo to the kit by profile — one set of rules and tools, identical in every repo |

## Install

```bash
git clone <this repo> ~/code/ai-transformation
~/code/ai-transformation/install.sh ~/code/customer-portal     # a workspace (several repos)
~/code/ai-transformation/install.sh ~/code/service-repo        # a single repo — profile from its manifest
~/code/ai-transformation/install.sh ~/code/new-repo --new      # an empty repo: the greenfield prompt
```

It asks: the target type and profile (guessed from the manifest), the AI tool (`claude` / `copilot` / `both`), and in
a workspace each repo's profile (`backend` / `frontend` / `skip`). Skip the questions with `--yes`, `--tool`,
`--profile`, `--kit-remote <url>`. It never overwrites a file; rerunning is safe. At the end it prints the
**bootstrap prompt** — paste it into the agent, which fills every `PLACEHOLDER` in `AGENTS.md` and `docs/` from the
real code, leaves what it cannot verify as `TODO(confirm)`, and wires the quality gate.

**After a workspace install:** `agent-kit/` is a new git repo — create a repo for it on your git server and push it.
Teammates never touch the template: `mkdir <workspace> && cd <workspace> && git clone <agent-kit url> agent-kit &&
agent-kit/install.sh` clones the missing repos and wires everything.

Check: `install.sh <target> --check` (a single repo: copies compared byte for byte with the kit; a workspace:
`agent-kit/scripts/check-drift.sh`) → `check-drift: clean`.

## How we work — one task, six steps

```
1. $write-spec          → agent-work/<branch-slug>/spec.md  (+ plan.md when it spans sessions)
2. $implement-task      → one report per repo: agent-work/<branch-slug>/<repo>/report.md
3. verify               → the orchestrator reads the diff and runs the tests itself ("green" in a report is not evidence)
4. THE GATE             → /simplify · /code-review · <profile>-reviewer · security (/security-review | security-reviewer)
                          findings → agent-work/<branch-slug>/<repo>/review.md
5. UI changed           → $verify-ui
6. $commit-and-pr       → only when asked; merging is always a human's call
```

- **PR gate:** in Claude Code a hook stops `git push` / `gh pr create` until step 4 really ran in the session; for
  Copilot and people the CI check `pr-evidence.yml` (installed in every repo) holds the same line on the PR
  description. Deliberate exception: `KIT_GATE_SKIP=1 KIT_GATE_REASON=<why>`, logged.
- **Trail:** `agent-work/` is never committed — at the workspace root, or inside a single repo (gitignored).
- **12 engineering principles** load in every session (the root `AGENTS.md` in a workspace,
  `docs/engineering/principles.md` in a single repo). The first five carry Andrej Karpathy's principles for LLM
  coding: think first, define done and prove it, gates green, the simplicity ladder, surgical changes; then root
  cause, tests, boundary validation, secrets, what is left for humans, ADRs, texts owned by others.

## Single repo or workspace

| | Single repo | Workspace |
|---|---|---|
| Kit files | **copied** into the repo (`.claude/`) | **linked** to `agent-kit/` — one change reaches every repo |
| Rules | `docs/engineering/principles.md` + the repo's `AGENTS.md` | the root `AGENTS.md` (platform guide: repo map, shared data, branches, principles) + the repo's `AGENTS.md` |
| Claude starts at | the repo | **the workspace root** — the root settings (permissions, hooks, the gate) apply to every repo |
| Update | pull the template → `install.sh <repo> --refresh` (replaces kit-owned copies); `--check` shows drift | update the kit → `agent-kit/install.sh --refresh`; `check-drift.sh` |
| When | a repo that lives on its own; the Copilot coding agent (cloud) | repos that touch each other: API + panel + worker … |

**Limits:** the Copilot coding agent (cloud) clones one repo; links to the sibling `agent-kit` are empty there —
install that repo in single-repo mode. On Windows, symlinks need Developer Mode + `git config core.symlinks true`;
otherwise use single-repo mode. The root `.claude/settings.json` applies only when Claude starts at the root.

## Directory

```
ai-transformation/
  install.sh                        the one entry: inspects the target, asks, installs (--check: drift report)
  bootstrap-prompt.md               existing repo / workspace: fill the PLACEHOLDERs from the code
  bootstrap-prompt-greenfield.md    empty repo: decisions first, then the skeleton
  kit/                              becomes <workspace>/agent-kit, or is copied piecewise into a single repo
    platform/  skills/  agents/  hooks/  scripts/  templates/  root/  humans/
  tests/selftest.sh                 installs all three targets into temp folders and checks them (also in CI)
  humans/                           the template's own human documents (the v1 rationale)
```

## Migrating from v1

v1 shipped three copied profile folders (`backend/`, `frontend/`, `analyst/`) and `install.sh <profile> <repo>`. Now
`install.sh <repo>` detects the profile (or take `--profile`); the analyst profile is gone. In a repo installed with
v1: `install.sh <repo>` adds the missing kit files; v1 skill copies that differ from the kit show up as `drift` in
`--check` — delete them and rerun. `agent-work/` is no longer committed.
