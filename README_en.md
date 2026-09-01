# AI Transformation — Agent Project Templates

> Türkçe sürüm: [README.md](README.md)
>
> **The standard itself, and the reasoning behind it:**
> [`ai-coding-standardi.docx`](ai-coding-standardi.docx) (Turkish) — what we
> use, which open-source project we adopted and why, what we left out and why,
> and the risks. This README covers how to install it; the document covers why
> it looks like this.

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
| Quality gate     | `.pre-commit-config.yaml` (pip) · `.husky/pre-commit` (npm) | git, at commit time — independent of the agent |
| Permissions / privacy | `.vscode/settings.json` · `.claude/settings.json` | Same policy, each runtime in its own file |

## Templates

- `templates_en/python-service/` — Python services and APIs
- `templates_en/frontend-web/` — UI / frontend projects (React, Next.js, …)
- `templates_en/analyst-workspace/` — business analysts: DB research + task authoring

## Install

```bash
python3 templates_en/start.py                          # interactive
python3 templates_en/start.py frontend-web ~/code/app  # existing repo
python3 templates_en/start.py --new python-service .   # new project
```

The script copies the template into the target repo (it never overwrites an
existing file; `--force` does), then prints the **bootstrap prompt** to paste
into Copilot or Claude Code. Which prompt depends on the state of the repo; the
script guesses which one fits and warns you when the flag disagrees.

**Existing repo** (`bootstrap-prompt.md`) — the agent surveys what is there:
manifest, lockfile, CI, tests, git history. It fills every `PLACEHOLDER` in
`AGENTS.md` and `docs/` from files it actually read, marks what it cannot verify
as `TODO(confirm)`, rewrites the stack-specific skills with real paths, and
reports missing prerequisites.

**New project** (`--new` → `bootstrap-prompt-greenfield.md`) — there is no code
to read, so the arrow runs the other way: the docs come before the code. The
agent turns every `TODO` row of `tech-stack.md` into a **question** for you
(recommendation plus reason, in one round trip), then scaffolds the minimum that
makes the gates real — lockfile, lint/format/type config, one vertical slice,
one test — and only then fills the docs from what it just built. The decisions
are written up as ADRs in the same session.

> The iron law gets stricter here: only a **decision the human made** and the
> **output of a command that was run** may be written as fact. In an existing
> repo a wrong line contradicts the code and gets caught; in a new one it
> silently becomes the spec.

Then: review the `TODO(confirm)` items with the team, sign ADR 0001, and make
one edit to confirm the hooks actually fire.

## The lint gate — how it arrives in a repo that has none

Three moments, three different questions. The one that usually gets confused is
1 versus 3: **the script puts the file there, the agent makes it fit the stack.**

Each template brings **its own ecosystem's runner**, so there is never a second
toolchain to install:

| Template | Commit-time runner | Files it ships | Wired by |
| --- | --- | --- | --- |
| `python-service` | `pre-commit` (pip) | `.pre-commit-config.yaml`, `requirements-dev.txt` | `pre-commit install` |
| `frontend-web` | `husky` + `lint-staged` (npm) | `.husky/pre-commit`, `.lintstagedrc.json`, `eslint.config.js` | `npm install`, via the `prepare` script |

> `husky` is the ~2KB npm package that makes git hooks shareable: `.git/` is not
> cloned, so a hook cannot live in the repo on its own. husky keeps the scripts
> in a versioned `.husky/` directory and points git's `core.hooksPath` at it,
> from the `prepare` script that `npm install` runs — so a new teammate does
> nothing extra. `lint-staged` runs a command over staged files only. Python's
> `pre-commit` has no official npm distribution; that is why the frontend
> template does not borrow it.

1. **`start.py` copies.** The template's own gate files are written into the repo
   **only if they aren't already there**. If they are, the repo's own version
   wins and shows up under "left untouched". So "add it if missing" is the copy
   step itself, not extra logic.
2. **`start.py` reports.** After copying it prints a `lint readiness` block and
   asks the right questions for whichever runner landed: on python, is
   `pre-commit` on PATH and is `.git/hooks/pre-commit` wired; on frontend, is
   `lint-staged` installed, does `package.json` have the `prepare` script, has
   `core.hooksPath` moved to `.husky/`. **It installs nothing.** Only on the
   pre-commit side, and only in interactive mode, it asks one question and acts
   solely on an explicit `y` — writing into `.git/hooks/` unasked is the opposite
   of what we demand from the agent. There is no such question on the husky side,
   because `npm install` already wires it.
3. **The bootstrap prompt adapts.** This is where the real decision lives,
   because it takes *reading* the stack. The prompt splits it into three cases:
   - **(a) the repo had no lint setup** → the shipped config becomes the setup:
     `[tool.ruff]`/`[tool.pylint]` goes into the **existing** `pyproject.toml`
     (the template deliberately ships none, so it can't overwrite theirs),
     every `rev:` is pinned to the installed version. On the frontend,
     `npm i -D husky lint-staged` + `npm pkg set scripts.prepare=husky` +
     `npm install` actually wires the hook, and `eslint.config.js` is adapted to
     TypeScript/Next.js. Then the whole-tree sweep (`pre-commit run --all-files`
     or `npm run lint`) runs **once**:
     legacy code failing is expected, so it is *reported* as counts — no silent
     mass reformat, no loosened rule. A rule that genuinely doesn't fit is an
     ADR, not a config edit.
   - **(b) the repo already had lint config** → theirs wins. The shipped gate is
     rewritten to call their commands and the duplicate checks are deleted. One
     definition of the gate.
   - **(c) the repo already had a commit hook** — its own husky setup,
     lint-staged in `package.json`, simple-git-hooks, a hand-written
     `.git/hooks/pre-commit` → two gates are worse than one. The shipped checks
     are merged into theirs and the template's copy goes, or the other way round.
     The agent says which, and exactly one hook ends up running.
4. **Then it stays up.** The gate's command is in the `AGENTS.md` Commands
   section and its whole-tree equivalent is in the `run-quality-gates` skill. No
   `--no-verify`.

Once per clone: `pip install pre-commit && pre-commit install` on python, just
`npm install` on the frontend. Writing that into the README and
`manual-actions.md` is the bootstrap step's job.

## Privacy and permissions

Three layers, each guaranteeing something different — trusting one without
knowing what it does is the actual risk:

| Layer | Where | What it really does |
| --- | --- | --- |
| **Discovery** | `search.exclude`, `files.associations`, `github.copilot.enable`, `.gitignore` | Keeps secret files out of search, the workspace index and inline completions. Does **not** stop a targeted read |
| **Action** | `chat.tools.terminal.autoApprove`, `chat.tools.edits.autoApprove`, `chat.agent.sandbox.enabled`, `permissions.deny` | Approval gates on commands and edits. On the **Claude Code** side `Read()`/`Edit()` deny rules are a real block — they cover the file tools *and* the `cat`/`head`/`tail`/`sed` commands Claude Code recognises. The sandbox is the only OS-level block on either side |
| **Prompt** | Golden rule: "secrets are never read, printed or pasted" | Covers what the other two cannot |

Why the list is surgical instead of "block every `.ini`": **a deny rule cannot
carry an exception.** `Read(**/*.ini)` would also close `alembic.ini`,
`pytest.ini` and `setup.cfg` with no way to reopen them — the `db-migration`
skill would stop working that day. So the list names what it means: `.env*`,
keys and certificates, `secrets/**`, `~/.ssh`, `~/.aws`, `default.ini`,
`config/*.ini`.

**The honest limit:** GitHub's content exclusion is **not applied in Copilot's
agent and edit modes** and requires Business/Enterprise. There is no hard read
block on the Copilot side; what you get there is approval + discovery + the
prompt rule. A secret that must never be readable belongs in a vault, not in the
workspace.

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

## What we use, and what we don't

Six open-source agent projects were reviewed. The answer was not "install them
all": **exactly one was installed**, and from the rest we took ideas, not code.

| Project | Decision | Why |
| --- | --- | --- |
| **Impeccable** | installed | The only candidate that fills the design-quality gap; 59 deterministic rules run without an LLM, so they attach to a hook and to CI. `.claude/skills/impeccable/`, ADR 0002 |
| **Karpathy skills** ([multica-ai](https://github.com/multica-ai/andrej-karpathy-skills)) | idea taken | Three of its four principles were already covered in more detail by the Golden Rules: *Simplicity First* → the ladder in rule #4, *Goal-Driven Execution* → rules #2/#3 plus `implement-task`'s "if you can't name the proof, the task isn't ready". The real gap was two items, now folded in: presenting alternatives / pushing back into rule #1, and the **surgical test** (every changed line traces to the request, don't touch neighbouring code, clean up only your own orphans) into rule #4. Not installed as a skill or plugin — it would be a second source of truth next to `AGENTS.md` (same reason as GSD Core) |
| **Ponytail** | idea taken | Its plugin writes rules into `copilot-instructions.md`, which is deliberately just a pointer here. The ladder became golden rule #4, root-cause became rule #5 |
| **Superpowers** | writing pattern taken, **plugin not installed** | Its value is not in its skills but in how they are written: an iron law, red flags, and a table that pre-empts the agent's own rationalizations — `run-quality-gates`, `debug-issue` and `self-review` follow it. The plugin itself fills the same slot as GSD, mandates TDD as a culture (delete code written before its test) and puts a skill call in front of every request |
| **GSD Core** | mechanism taken, framework not installed | It brings 70+ skills, its own installer and its own `.planning/` tree — a second source of truth beside `AGENTS.md`. Its three load-bearing mechanisms fit in the `plan-feature` skill |
| **Hallmark** | not taken | Same slot as Impeccable; built to produce variety, while a product needs consistency |
| **Caveman** | not taken | Conflicts with the short-docs policy and shows no measurable saving in an agentic loop |
| **Graphify** | next in line | No need for a code index yet; the built-in one holds up to ~2,500 files |

**What we removed:** template synchronization (version stamp + the
`standard-check` CI gate — maintaining a half-built mechanism cost more than it
returned; when the repo count grows it should come back as a PR-opening bot, not
a gate) · the `bootstrap-research` skill (a one-time job, moved into the install
prompt) · the `simplify` skill (simplification moved to writing time, rule #4) ·
the analyst `task.md` requirement (work is picked up when "done" is observable,
whatever form it arrived in) · the TR/EN template twin.

The long reasoning and the risks:
[`ai-coding-standardi.docx`](ai-coding-standardi.docx).
