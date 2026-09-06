# AI Transformation — Company Agent Kit

> Türkçe sürüm: [README.md](README.md)
>
> **The standard itself and its rationale:** [`ai-coding-standardi.docx`](ai-coding-standardi.docx)
> (Turkish) — what we use, which open-source projects we adopted and why, what
> we left out and the risks. This README says how to install and how to work;
> the document says why.

The shared structure for AI-assisted development. **One copy, two harnesses:**
the same skill and agent definitions are read by GitHub Copilot (VS Code agent
mode / coding agent) and Claude Code. No Codex. The kit is installed into every
company repo **by copy, inside the repo**; backend and frontend are separate
repos and each gets its own profile. There are three folders — `backend/`, `frontend/`, `analyst/` — and each is
ready **as it will sit inside a repo of that type**: the `AGENTS.md` skeleton,
the `docs/` knowledge base, skills, reviewer agents (Copilot twins included),
hooks, permission files, the commit gate. Per-repo rules always live in that
repo's `AGENTS.md`; the kit defines roles, workflow and guardrails.

## Roles

| Role | Who | What |
|---|---|---|
| **Orchestrator** | The developer's Claude Code / Copilot session | Breaks the work down, writes `agent-work/<id>/spec.md` with `write-spec` when delegating, implements or delegates, **verifies independently** (reads the diff, runs the tests itself), runs the review round (agents), reports. Never commits or pushes unless asked. |
| **Implementer** | The same session (`implement-task`) **or** a session with no chat history: a Claude subagent / worktree, the Copilot coding agent (issue → PR), another developer | Implements `spec.md`, writes `report.md`. When blocked it does not guess; it writes the question into the report. |
| **Reviewer** | The `code-reviewer` (stack lens) + `security-reviewer` agents — Claude subagents or Copilot custom agents | Reads the diff **cold** (the goal, not the author's narration), returns a severity-ordered list of findings, never modifies files. |
| **UI verifier** | `verify-ui` (after every UI change) · `ui-check` (before a release) | Produces evidence in a real browser: reaching the screen through the UI, overlap/overflow/scroll/modal-residue probes, console, accessibility, the added function end to end; `ui-check` is the screen × role × viewport matrix. |

## Harness map — who reads what

| Content | Canonical source | Claude Code | Copilot |
|---|---|---|---|
| Repo guide | `AGENTS.md` | `CLAUDE.md` (`@AGENTS.md`) | natively; `.github/copilot-instructions.md` is only a pointer |
| Knowledge base | `docs/` | short references the guide links to | same |
| Skills | `.claude/skills/*/SKILL.md` | native | native ([VS Code docs](https://code.visualstudio.com/docs/agent-customization/agent-skills)) |
| Reviewer agents | `.claude/agents/*.md` | native | `.github/agents/*.agent.md` — **generated** by `sync-copilot-agents.py`, shipped in the folder |
| Hook scripts | `.claude/hooks/*.sh` | manifest `.claude/settings.json` | manifest `.github/hooks/*.json` |
| MCP servers | `.mcp.json` | native | `.vscode/mcp.json` |
| Permissions / privacy | policy | `.claude/settings.json` | `.vscode/settings.json` |
| Work trail | `agent-work/<id>/` (committed with the branch, deleted at merge; `shots/` ignored) | reads/writes | reads/writes |
| Commit gate | `.pre-commit-config.yaml` (pip) · `.husky/pre-commit` (npm) | git, at commit time — independent of the agent | same |

## Workflow (one task)

```
1. Orchestrator → write-spec: agent-work/<id>/spec.md   (goal, acceptance criteria, constraints, verification commands)
                  small task: skip the spec, implement-task directly
2. Implementer  → implement-task: reads AGENTS.md, builds, runs the gates, writes report.md
3. Orchestrator → does NOT stop at reading the report: inspects the diff, runs the tests itself ("green" is not evidence)
4. Orchestrator → code-reviewer (+ security-reviewer) agents read the diff cold → review.md; fix round for critical/medium (back to 2)
5. Orchestrator → UI touched: verify-ui (browser); before a release: ui-check
6. Orchestrator → commit-and-pr (only when the user asks); the PR description is derived from report.md
```

`agent-work/<id>/` is the whole trail of one task: `spec.md`, `plan.md`
(`write-spec`), `report.md`, `review.md`, `ui-smoke.md`, `ui-bugs.md`. It is
committed with the branch (reviewers read the spec and the report there) and
deleted in the last commit before merge; only `shots/` is gitignored. Anything
that must outlive the branch moves to an ADR or `docs/`.
The templates live in the skills' `references/` folders and travel with the kit.

## Install

The kit is its own repository; a profile folder is **copied** into the target
repo (no symlinks, no submodule). Every file in the folder lands at the same
relative path in the target.

| Folder | For | What it adds |
|---|---|---|
| `backend/` | Python services and APIs | pre-commit gate, `new-endpoint`, `db-migration` |
| `frontend/` | React / Next.js etc. | husky + lint-staged gate, `verify-ui`, `ui-check`, `new-component`, `impeccable`, `docs/DESIGN.md`, `docs/screens.md`, Playwright e2e scaffold + MCP |
| `analyst/` | Business analysts: read-only DB research + task authoring | DB MCP connections, read-only SQL guard; **no** code skills, format hooks or reviewer agents |

```bash
git clone <kit-url> ~/code/ai-transformation
~/code/ai-transformation/install.sh backend  ~/code/service-repo                   # asks: claude / copilot / both
~/code/ai-transformation/install.sh frontend ~/code/new-repo --new --tool copilot   # empty repo, no question
```

The script first asks which AI tool the repo uses — `claude`, `copilot` or
`both` (also `--tool`; `both` when there is no terminal) — and copies only that
runtime's files: `claude` leaves out the Copilot side
(`.github/copilot-instructions.md`, `.github/agents/`, `.github/hooks/`,
`copilot-setup-steps.yml`, `.vscode/`); `copilot` leaves out the Claude side
(`CLAUDE.md`, `.claude/settings.json`, `.mcp.json`). `.claude/skills`,
`.claude/hooks` and `.claude/agents` always come along: Copilot reads the
skills natively, its manifests call the same scripts, and the twins are
generated from those agents. It then copies the folder (it **never touches**
an existing file — `--force` overwrites — and lists what it skipped), adds
`agent-work/**/shots/` to `.gitignore`, and prints the **bootstrap prompt**. Paste that
text into Copilot or Claude Code. It also works without the script:
`cp -R backend/. <repo>/` plus `agent-work/**/shots/` in `.gitignore`. It warns in a
directory that is not a git repo, because the hooks resolve their paths through
git. On Windows use Git Bash or WSL.

**Existing repo** (`bootstrap-prompt.md`) — the agent surveys the repo:
manifest, lockfile, CI, tests, git history. It fills every `PLACEHOLDER` in
`AGENTS.md` and `docs/` from files it actually read, marks what it cannot
verify as `TODO(confirm)`, rewrites the stack-specific skills with real paths,
derives `docs/screens.md` from the router on the frontend, and reports the
missing prerequisites.

**If the repo already has an `AGENTS.md`**, the kit's is skipped and the repo's
is kept. The prompt knows this case: it does not rewrite the rules, it only adds
the *Capabilities*, *Guardrails* and *Work trail* sections from the kit template.

**Empty repo** (`--new` → `bootstrap-prompt-greenfield.md`) — there is no code
to read, so the arrow points the other way: docs come before code. The agent
first asks every `TODO` row of `tech-stack.md` as a **question** (recommendation
+ reason, one round trip), then scaffolds the minimum that makes the gates real
— lockfile, lint/format/type config, one vertical slice, one test — and fills
the docs only from *what it built*. Decisions become ADRs in the same session.

> The iron rule hardens here: only **a decision the human made** and **the
> output of a command that was run** may be written as fact. In an existing
> repo a wrong line contradicts the code and gets caught; in a new one it
> silently becomes the spec.

Afterwards: review the `TODO(confirm)` items with the team, sign ADR 0001, edit
a file and watch the hooks actually fire.

### When the kit changes

The price of installing by copy is drift. When a skill, agent or hook changes
in the kit:

```bash
./diff-repo.sh backend ~/code/service-repo          # drift <path> / missing <path> / clean; exit 1 on drift; detects the tool
./install.sh   backend ~/code/service-repo --force  # or copy the single file by hand
```

`diff-repo.sh` compares kit-owned files byte for byte (hooks, shared skills,
agents and their twins) and reports repo-owned files (`AGENTS.md`, `docs/`,
stack skills carrying PLACEHOLDERs, settings and gate files) only when
missing. Once the repo count grows, this belongs in CI as a bot that opens a
PR, not as a gate.

**Copies inside the kit:** `backend/` and `frontend/` carry the same shared
files (`CLAUDE.md`, `copilot-instructions.md`, hooks, `security-reviewer`,
three shared skills); `analyst/` shares only `CLAUDE.md`,
`copilot-instructions.md` and `commit-and-pr`. Change one, copy to the other;
`diff -rq backend/.claude/skills frontend/.claude/skills` shows the
difference. After editing an agent, `python3 sync-copilot-agents.py backend`
(or `frontend`) refreshes its twin; twins are never written by hand.

**Updating Impeccable:** run `npx impeccable update` in a frontend repo, then
copy `.claude/skills/impeccable/` and `.github/agents/impeccable-*.agent.md`
back under `frontend/` (ADR 0002).

## The lint gate — how it arrives in a repo that has none

Each profile brings **its own ecosystem's runner**; no second toolchain is
installed:

| Profile | Commit-time runner | Files it ships | Wired by |
| --- | --- | --- | --- |
| `backend` | `pre-commit` (pip) | `.pre-commit-config.yaml`, `requirements-dev.txt` | `pre-commit install` |
| `frontend` | `husky` + `lint-staged` (npm) | `.husky/pre-commit`, `.lintstagedrc.json`, `eslint.config.js` | `npm install`, via the `prepare` script |

> `husky` is the small npm package that makes git's hook mechanism shareable:
> `.git/` is not cloned, so a hook cannot live in the repo; husky keeps the
> scripts in the versioned `.husky/` folder and points `core.hooksPath` there
> from the `prepare` script that `npm install` runs. `lint-staged` runs the
> command on staged files only. Python's `pre-commit` has no official npm
> distribution; that is why pip stays out of the frontend.

Three moments: **the script places the file** (only if absent; otherwise the
repo's own wins and shows up as "left untouched"), **the bootstrap prompt fits
it to the stack** (no lint in the repo → the shipped config is the setup,
`[tool.ruff]` goes into the existing `pyproject.toml`, husky gets wired, the
whole-tree sweep runs **once** and is reported as counts; lint already there →
theirs stays and the gate calls their commands; a commit hook already there →
two gates are worse than one, pick one), **then the gate stays up**
(`AGENTS.md → Commands` holds the command and the gate discipline; no
`--no-verify`). Details: `bootstrap-prompt.md` §4–5.

Once per clone: `pip install pre-commit && pre-commit install` on the backend,
just `npm install` on the frontend. Writing that into the README and
`manual-actions.md` is the bootstrap step's job.

## Privacy and permissions

Three layers, and each guarantees something different — trusting one without
knowing what it does is the real risk:

| Layer | Where | What it does |
| --- | --- | --- |
| **Discovery** | `search.exclude`, `files.associations`, `github.copilot.enable`, `.gitignore` | Keeps secret files out of search, the workspace index and inline completion. Does **not** stop a targeted read |
| **Action** | `chat.tools.terminal.autoApprove`, `chat.tools.edits.autoApprove`, `chat.agent.sandbox.enabled`, `permissions.deny` | Approval gate on commands and edits. In **Claude Code** a `Read()`/`Edit()` deny is a real block — it covers the file tools *and* `cat`/`head`/`tail`/`sed`. The sandbox is the only OS-level block on either side. The agent cannot widen its own guardrails: `.claude/hooks/**` and `.github/hooks/**` are edit-locked, and the format hook never writes those paths |
| **Prompt** | Golden rule: "secrets are never read, printed or pasted" | Closes what the other two cannot |

**The secrets layout is a contract, not a list.** Real values live under
`config/` and in `.env*` files; both are never read and never edited (denied
in both runtimes). The only config files the agent touches are the templates
at the repo root, `default.ini` and `env.example` — a new setting goes there
with a placeholder, its name goes on `manual-actions.md`, a human fills the
value. The rest of the deny list is surgical: keys/certificates, `secrets/**`,
`~/.ssh`, `~/.aws`, credential files.

Two limits, because **deny rules accept no exceptions**: the template is named
`env.example` (with a leading dot it would match the `.env.*` rule and could
not be reopened); and in some repos `config/` is source code
(`config/settings.py`) — the bootstrap prompt then narrows the rule to the
credential-bearing files.

**Honest limit:** GitHub's content exclusion does not apply in Copilot's agent
and edit modes and needs Business/Enterprise. On the Copilot side there is no
hard block on reading a file; the layer there is approval + discovery + prompt.
A secret that must never be read belongs in a vault, not in the workspace.

## Skills and agents

| Folder | Skill | What it does |
| --- | --- | --- |
| all | `commit-and-pr` | Commit/PR format: English conventional title, Turkish body |
| backend · frontend | `implement-task` | A request or a `spec.md` end to end: understand → build → prove → gates → cold review (agents) → `report.md` → PR; from a spec, questions go to the report and nothing is committed |
| backend · frontend | `write-spec` | A spec a session with no chat history can execute without guessing; for work bigger than one spec, the `plan.md` that splits it into spec-sized, self-verifying tasks |
| backend | `new-endpoint` · `db-migration` | Stack-specific recipes; `db-migration` states the deploy order |
| frontend | `verify-ui` | Browser smoke after every UI change: reached through the UI, layout probes, console, a11y, the function end to end → `ui-smoke.md` |
| frontend | `ui-check` | Screen × role × viewport matrix before a release (`docs/screens.md`) → `ui-check.md` + `ui-bugs.md` |
| frontend | `new-component` · `impeccable` | Component recipe; design quality audited against `DESIGN.md` (vendored) |
| analyst | `db-research` · `create-task` · `refine-task` · `update-db-catalog` | Read-only DB research, task authoring and the catalog |

Discipline (gates, root cause, ADRs, cold review) is not a skill but an
`AGENTS.md` rule: loaded on every request, never waiting to be triggered.
Agents (`.claude/agents/`, Claude format canonical; the `.github/agents/` twin
is generated by `sync-copilot-agents.py` and shipped in the folder):
`code-reviewer` with a backend lens (correctness → typing → boundaries →
contract → migrations → tests → complexity) and a frontend lens (correctness →
a11y → i18n → conventions → TypeScript → tests → complexity);
`security-reviewer` (isolation → authorization → credentials/PII → abuse
limits → cache revocation → browser surface → dependencies). All read-only,
all read cold, findings as `file:line · severity · issue · fix` ordered by
severity, "possible" for uncertain ones, `No findings.` allowed, residual risk
named.

## Browser verification

`verify-ui` and `ui-check` use whichever browser the runtime has, in order:

1. **VS Code's built-in browser tools** — Copilot agent mode, VS Code 1.127+.
   No external MCP needed.
2. **Claude in Chrome** — Claude Code + the Chrome extension; the real browser
   with the real session (best for logged-in screens). Pitfalls in
   `verify-ui/references/chrome-notes.md`.
3. **Playwright MCP** — clean and scriptable; preferred when the flow should
   become an e2e test.

With none of them the skill says "could not verify", falls back to component
tests and writes "browser smoke pending" — it never says "verified".

The agent-independent floor is **Playwright**: the frontend profile ships
`playwright.config.ts` + `e2e/` — `auth.setup.ts` (session from env),
`screens.ts` (reads `docs/screens.md`; the inventory stays the single source),
`probes.ts` (the same checks as `probes.md`), `smoke.spec.ts` (every route ×
desktop/mobile: load, expected text, console, network, overlap, overflow,
scroll, screenshot). `npm run test:e2e` runs in CI too; `verify-ui` and
`ui-check` start with it and the agent adds what a script cannot judge:
interactions, modals, gating per role, both languages. Screens are
reached **through the UI**; a screen reachable by URL but not from the menu is a bug.

## docs/ taxonomy

- `docs/engineering/` — **how** we build: architecture, stack, conventions,
  testing, workflow, what is on the humans.
- `docs/domain/` — **what** we build: glossary, business rules. Stable reference.
- `docs/decisions/` — **why**: numbered, immutable ADRs. Same PR as the decision.
- frontend also has `docs/DESIGN.md` (design system) and `docs/screens.md`
  (screen inventory).

## Tokens and cost

1. **Short docs first.** `AGENTS.md` is paid for on every request — ≤ ~150
   lines, every skill ≤ ~80 lines; detail goes to `references/` or a linked doc.
2. **Skills load on demand.** A precise "when to use" sentence is the cheapest
   optimisation available.
3. **Built-in code index.** Repos hosted on GitHub get an automatic remote
   semantic index. Local indexing works well up to ~2,500 files.
4. **MCP code index for large repos.** If needed,
   [claude-context](https://github.com/zilliztech/claude-context) or
   [codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp);
   record the adoption as an ADR.
5. **Model mix.** Draft with a cheap model, run the review pass with the
   strongest one; the model picker in Copilot, `/model` in Claude Code.

## What we use, and what we don't

Open-source agent projects were reviewed. The result is not "install all of
them": **only one was installed**; from the others we took ideas, not code.

| Project | Decision | Why |
| --- | --- | --- |
| **Impeccable** | installed | The only candidate that fills the design-quality gap; deterministic rules run without an LLM, so they hook into hooks and CI. `frontend/.claude/skills/impeccable/`, ADR 0002 |
| **Karpathy skills** ([multica-ai](https://github.com/multica-ai/andrej-karpathy-skills)) | idea taken | Three of four principles were already covered by the Golden Rules; the real gap was two items, now in: offering alternatives/pushing back in rule #1, the **surgical-change test** in rule #4 |
| **Ponytail** | idea taken | The ladder went into golden rule #4, root cause into rule #5; `copilot-instructions.md` stays deliberately a pointer |
| **Superpowers** | writing pattern taken, plugin not installed | Iron law + red flags + the table that refutes the agent's excuses in advance — the gate discipline and the root-cause rule are written in that mould |
| **GSD Core** | mechanism taken, framework not installed | 70+ skills and its own `.planning/` tree would be a second source of truth beside `AGENTS.md`; its three valuable mechanisms fit into `write-spec`'s plan section |
| **Hallmark** | not taken | Same slot as Impeccable; designed for variety, a product needs consistency |
| **Caveman** | not taken | Conflicts with the short-docs policy |
| **Graphify** | queued | No code-index need yet |

**Removed:** `start.py` (copying is now `install.sh`, the lint-readiness
check lives in bootstrap prompt §5) · `.ai/STATE.md` + `.ai/plans/` (replaced by
`agent-work/<id>/`) · per-stack *divergent* skill texts (shared skills are now identical word
for word) · hand-written Copilot agent twins (generated) · template version stamps (replaced by
`diff-repo.sh`) · TR/EN template twins · five discipline skills (`run-quality-gates`,
`self-review`, `debug-issue`, `record-decision`, `plan-feature`): by the kit's own
principle a skill carries only project-specific knowledge; the gate discipline
moved to `AGENTS.md → Commands`, root cause to rule #5, the ADR template to
`docs/decisions/README.md`, review dispatch to `implement-task`, the plan to
`write-spec` — the complexity pass already lived in `code-reviewer`.

## Principles (followed when writing skills)

- **Assume the agent is capable.** A skill carries only the project-specific
  knowledge that would change its decision; no generic advice.
- **Describe the outcome, not the path.** Decision criteria instead of fixed
  step lists; rigid steps only where deviation causes concrete harm
  (migrations, scoping predicates, commit policy, secrets).
- **Evidence, not claims.** To say "it works" the command must have run in this
  session and its output been read.
- **Do not guess when blocked.** A session with no history cannot ask: the
  question goes into the report, that part is left undone.
- **One source of truth.** The same rule is never written twice: repo rules in
  `AGENTS.md`, workflow here, generated files never edited by hand.

## Layout

```
ai-transformation/
  README.md · README_en.md · ai-coding-standardi.docx
  install.sh · diff-repo.sh · sync-copilot-agents.py
  bootstrap-prompt.md · bootstrap-prompt-greenfield.md
  backend/    ┐
  frontend/   ├ each one the complete tree that goes into a repo of that type (below)
  analyst/    ┘
```

**`backend/`**

```
AGENTS.md · CLAUDE.md
.claude/   settings.json · hooks/{format-changed,remind-docs}.sh
           agents/{code-reviewer,security-reviewer}.md
           skills/ commit-and-pr · implement-task (+references/report.md) · write-spec (+references/task-spec.md)
                   new-endpoint · db-migration
.github/   copilot-instructions.md · agents/{code-reviewer,security-reviewer}.agent.md (generated)
           hooks/format-and-docs.json · workflows/copilot-setup-steps.yml
.vscode/   settings.json
.pre-commit-config.yaml · requirements-dev.txt
docs/      README.md · engineering/{architecture,tech-stack,conventions,testing,development-workflow,manual-actions}.md
           domain/{glossary,business-rules}.md · decisions/{README.md,0001-adopt-ai-driven-workflow.md}
```

**`frontend/`** — same backbone as backend; the differences:

```
.claude/   skills/ … (+ verify-ui (+references/probes.md, chrome-notes.md) · ui-check · new-component · impeccable/)
           settings.json (impeccable hook wired too)
.github/   agents/ … + impeccable-*.agent.md (4, upstream) · hooks/ + impeccable.json
.vscode/   settings.json · mcp.json (Playwright)   ·   .mcp.json
.husky/pre-commit · .lintstagedrc.json · eslint.config.js · .prettierignore · .impeccable/.gitignore
playwright.config.ts · e2e/{auth.setup,screens,probes,smoke.spec}.ts
docs/      … + DESIGN.md · screens.md · decisions/0002-adopt-impeccable-design-quality.md
no skill:  new-endpoint, db-migration
```

**`analyst/`** — no code, no gate, no reviewer:

```
AGENTS.md · CLAUDE.md
.claude/   settings.json · hooks/guard-readonly-sql.sh
           skills/ commit-and-pr · db-research · create-task · refine-task · update-db-catalog
.github/   copilot-instructions.md · hooks/guard-readonly.json
.vscode/   settings.json · mcp.json (DB servers, passwords as VS Code inputs)   ·   .mcp.json
docs/      db-catalog.md · definition-of-done.md · how-analysts-work.md · task-template.md
tasks/     TASK-001-example-last-login-column.md
```
