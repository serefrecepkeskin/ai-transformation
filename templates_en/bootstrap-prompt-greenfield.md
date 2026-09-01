# Bootstrap prompt — new project

Paste this into the agent after installing the template into an **empty** repo.

You are setting up the AI-agent scaffolding that was just copied into this
repository (template: `{{TEMPLATE}}`). This repository is new: there is little
or no code to read yet. The scaffolding is generic; your job is to turn it into
the plan this project gets built against — and to lay the first stone, so the
plan is already true on day one.

The sibling prompt (`bootstrap-prompt.md`) fills these docs *from* an existing
codebase. Here the arrow points the other way: the docs come first and the code
follows. That makes guessing far more expensive — a wrong line in an existing
repo contradicts the code and gets caught, but here it silently becomes the
spec.

## Iron law

Only two things may be written as fact:

1. a decision **the human made in this session**, and
2. the output of a command **you actually ran in this session**.

Everything else is `TODO(confirm): <the question>` for a human. Never pick the
stack yourself — recommend, then wait. A plausible default is worse than a
visible gap, because the gap gets filled and the default gets built on for a
year.

## 0. Confirm this is the right prompt

Run `ls -a`, `git log --oneline -5`, and look for a manifest (`package.json`,
`pyproject.toml`). If you find one with real source code beside it, this is the
wrong prompt — stop and say so. `bootstrap-prompt.md` is the one that surveys an
existing repo.

## 1. Interview — ask once, ask everything

**`docs/engineering/tech-stack.md` is your question list.** Every `TODO` row in
its "Active stack" table is a decision a human has to make. Put them in a single
message, each with your recommendation and the one-line reason. One round trip,
not twenty.

Ask as well:

- What this project is, who consumes it, where it deploys — one paragraph; it
  becomes the opening of `AGENTS.md`.
- The first vertical slice: the smallest end-to-end thing that will be real (one
  endpoint, one page). You build exactly this in step 2.
- Anything they want **deferred** — it goes into the "Deferred" table with its
  trigger condition, never in as a silent default.

Template-specific:

- **frontend-web** — also settle the design direction for `docs/DESIGN.md`
  before any UI exists. The `impeccable` skill audits against that file, so an
  empty one makes it toothless.
- **analyst-workspace** — there is no stack to choose. Ask instead which DB
  engines are in scope, which environment each read-only login points at (a
  replica, not a production primary), and who owns access. That fills
  `docs/db-catalog.md` and the entries in `.mcp.json` / `.vscode/mcp.json`.
  Skip steps 2–4; step 5 onward still applies.

## 2. Scaffold the minimum that runs

Not an application — the smallest skeleton that makes every gate real:

- the dependency manager initialized, the step-1 dependencies installed, and the
  **lockfile written**;
- lint / format / type-check configured with the tools that were chosen — the
  template ships `.pre-commit-config.yaml` (and `eslint.config.js` /
  `requirements-dev.txt` where it applies) as the starting point; adapt them to
  the stack you just chose rather than writing a second gate beside them;
- the one vertical slice from step 1, actually running;
- one test over that slice — watch it fail before it passes, or you have not
  proven it tests anything.

Run each command and read its output. A gate you could not get to exit 0 does
not go into the `AGENTS.md` Commands section; it goes into
`docs/engineering/manual-actions.md` as unfinished.

## 3. Fill the knowledge base

The same targets as the survey prompt, sourced from step 1's decisions and step
2's output — never from what a project like this usually looks like.

- `AGENTS.md` — the opening paragraph, and **Commands** verbatim as you ran them.
- `docs/engineering/tech-stack.md` — versions read out of the lockfile you just
  wrote, not the versions you asked for.
- `docs/engineering/architecture.md` — the layers that exist. A directory you
  have not created is not architecture: either create it in step 2 or mark it
  `TODO(confirm)`.
- `docs/engineering/conventions.md` — the conventions the slice actually
  follows. Keep it short; it grows as the code does.
- `docs/engineering/testing.md` — the runner you ran, its layout, its command.
- `docs/domain/glossary.md` and `business-rules.md` — only terms the human gave
  you. An empty domain doc is honest; an invented one is a trap.

## 4. Record the decisions as ADRs

Every step-1 choice that had a real alternative is an ADR, written now while the
reasoning is fresh — the cheapest it will ever be, and `AGENTS.md` rule #8 will
demand it anyway.

Number from the next free slot in `docs/decisions/`: **0002** for
`python-service`, **0003** for `frontend-web` (0001 is the AI-workflow ADR, and
frontend's 0002 is the design-quality one). One decision per ADR.

## 5. Tailor the skills

The stack-specific skills (`new-endpoint`, `db-migration`, `new-component`,
`verify-ui`) ship with a PLACEHOLDER line. Rewrite each against the paths and
commands you created in step 2. A skill that names a directory which does not
exist is worse than no skill.

Delete any skill that does not apply here, and say which and why.

## 6. Prove the guardrails, do not assume them

There is no legacy code here, so the gate can be green from commit one — and it
must be, because everything written after this is measured against it.

- Finish the lint config you scaffolded in step 2: `[tool.ruff]` (and
  `[tool.pylint]`) in the `pyproject.toml` you created, or `eslint.config.js`
  adapted to the framework you chose. Pin every `rev:` in
  `.pre-commit-config.yaml` to the version you actually installed.
- `pip install pre-commit && pre-commit install`, then
  `pre-commit run --all-files` — green, on the skeleton, before you report. A
  gate that has never run is not a gate.
- `node -v` — the design hook needs 22+.
- Are `prettier` / `eslint` (frontend) or `ruff` (python) really installed? The
  hooks call them and exit silently when they are absent.
- Edit one file and confirm the format hook actually fired. An unfired hook is
  indistinguishable from no hook.
- Run the full gate set once, green, before you report.

Whatever a human still has to install, decide or grant goes into
`docs/engineering/manual-actions.md`.

## 7. Report back

1. **Decided** — the filled stack table, and who decided it.
2. **Built** — what runs now, with the command output that proves it,
   including `pre-commit run --all-files` green.
3. **`TODO(confirm)`** — every open question, and who should answer it.
4. **ADRs written** — number and title.
5. **Deleted / not applicable** — what you removed and why.
6. **Prerequisites missing** — what a human has to do next.

Leave `.ai/STATE.md` alone: `implement-task` owns it, and bootstrapping is not a
feature. Do not commit and do not open a PR — the human reviews first, then the
`commit-and-pr` skill.

## Rationalizations

| Excuse | Reality |
|---|---|
| "FastAPI / Next.js is the obvious choice here" | Obvious to you, not decided by them. Recommend it, then wait. |
| "I'll write the docs now and build the slice later" | Then the docs describe nothing, and nobody finds out until they are load-bearing. |
| "The test can come with the first real feature" | The test is what proves the gate command runs at all. |
| "Versions from the docs are close enough" | Read the lockfile. Close enough is how a stack drifts on day one. |
| "The domain docs look empty" | They are empty. That is accurate. |
