# AI Transformation — Agent Project Templates

> Türkçe sürüm: [README.md](README.md)

Standard, copy-and-use scaffolding for AI-assisted development. **One layout,
two runtimes:** the same files are read by GitHub Copilot (VS Code agent mode)
and Claude Code.

| Piece            | Location                              | Who reads it                      |
| ---------------- | ------------------------------------- | --------------------------------- |
| Agent guide      | `AGENTS.md`                           | Copilot natively · Claude via `CLAUDE.md` |
| Knowledge base   | `docs/`                               | Short references the guide links to |
| Skills           | `.claude/skills/*/SKILL.md`           | **Both, natively** ([VS Code docs](https://code.visualstudio.com/docs/agent-customization/agent-skills)) |
| Custom agents    | `.claude/agents/` · `.github/agents/` | Same content, each runtime's format |
| Hook scripts     | `.claude/hooks/*.sh`                  | One script; manifests in `.claude/settings.json` + `.github/hooks/` |
| MCP servers      | `.mcp.json` · `.vscode/mcp.json`      | Same servers, one file per runtime |
| Feature memory   | `.ai/STATE.md` · `.ai/plans/`         | Cross-session state and plans     |

## Templates

- `templates_en/python-service/` — Python services and APIs
- `templates_en/frontend-web/` — UI / frontend projects (React, Next.js, …)
- `templates_en/analyst-workspace/` — business analysts: DB research + task authoring

## Install

```bash
python3 templates_en/start.py                          # interactive
python3 templates_en/start.py frontend-web ~/code/app  # direct
```

The script copies the template into the target repo (it never overwrites an
existing file; `--force` does), then prints the **bootstrap prompt**. Paste that
into Copilot or Claude Code: it surveys the repo, fills every `PLACEHOLDER` in
`AGENTS.md` and `docs/` with real evidence, marks what it cannot verify as
`TODO(confirm)`, rewrites the stack-specific skills with real paths, and reports
missing prerequisites. The prompt also stands alone:
`templates_en/bootstrap-prompt.md`.

Then: review the `TODO(confirm)` items with the team, sign ADR 0001, and make
one edit to confirm the hooks actually fire.

## Skills

| Skill               | What it does                                                     |
| ------------------- | ---------------------------------------------------------------- |
| `implement-task`    | A request end to end: understand → build → prove → gates → self-review → PR |
| `plan-feature`      | Work bigger than one session: plan file first, then task by task  |
| `debug-issue`       | Root cause before any fix: reproduce, instrument boundaries, trace to source |
| `run-quality-gates` | Run the gates; report each one with its real output               |
| `self-review`       | A reviewer that reads the diff cold + a complexity pass           |
| `record-decision`   | Write the ADR and update the affected doc in the same PR          |
| `commit-and-pr`     | Commit/PR format: English conventional title, Turkish body        |
| `verify-ui`         | (frontend) Prove a change in a real browser                       |
| `impeccable`        | (frontend) Design quality, audited against `DESIGN.md`            |
| `new-component` · `new-endpoint` · `db-migration` | Stack-specific recipes          |

Analyst side: `db-research`, `create-task`, `refine-task`, `update-db-catalog`.

## Browser verification

`verify-ui` uses whichever browser the runtime has, in this order:

1. **VS Code's built-in browser tools** — Copilot agent mode, GA since VS Code
   1.127. Opens the page, reads the console, screenshots, clicks. No MCP needed.
2. **Claude in Chrome** — Claude Code with the Chrome extension: a real browser
   with the real session (best for screens behind a login).
3. **Playwright MCP** — clean and scriptable; the right one when the flow will
   become an e2e test.

With none of them the skill says it could not verify and falls back to component
tests — it never claims proof it does not have.

## docs/ taxonomy

- `docs/engineering/` — **how** we build: architecture, stack, conventions,
  testing, workflow.
- `docs/domain/` — **what** we build: glossary, business rules. Stable reference.
- `docs/decisions/` — **why**: numbered, immutable ADRs, shipped with the change.

## Token and cost

1. **Short docs first.** `AGENTS.md` is paid for on every request — ≤ ~130
   lines, each skill ≤ ~60; detail goes into linked docs.
2. **Skills load on demand.** A precise "when to use" sentence is the cheapest
   optimization available.
3. **Built-in code index.** GitHub-hosted repos get a remote semantic index
   automatically. Local indexing works well up to ~2,500 files.
4. **MCP code index for large repos.** If needed,
   [claude-context](https://github.com/zilliztech/claude-context) or
   [codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp);
   record the adoption as an ADR.
5. **Model mix.** Draft with a cheap model, run `self-review` with the strongest.

## Deliberately out of scope

- **Template synchronization.** The version stamp and the `standard-check` CI
  gate that measured drift across repos are gone; not a priority right now. It
  is the first thing to bring back once the repo count grows.
- **Analyst coupling.** The developer templates no longer require an
  analyst-authored `task.md`; work is picked up from wherever it comes as long
  as "done" can be stated as something observable. The analyst template still
  stands on its own.

Evaluation and rationale: `ai-coding-standardi.docx`.
