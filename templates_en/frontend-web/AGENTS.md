# PROJECT_NAME — Agent Guide

> **TEMPLATE.** Copy this folder into the repo root, then paste the bootstrap
> prompt (`templates_en/bootstrap-prompt.md`) into the agent to fill every
> PLACEHOLDER from the real codebase.

PLACEHOLDER: one paragraph — what this app is, who uses it, rendering strategy
(SSR/CSR), markets/languages.

This file is the canonical guide for every AI agent working in this repo, on
either runtime (GitHub Copilot and Claude Code both read it). Details live in
`docs/` and are linked below; treat the linked doc as the source of truth. Keep
this file and every doc **short** — everything loaded into context costs tokens
on each request.

## Golden Rules

1. **Think before coding.** No silent assumptions. If the task, design intent
   or a business rule is unclear, stop and ask; state every assumption.
2. **Evidence before claims.** Never say done, fixed, passing or working
   without having run the command or looked at the page *in this session*. UI
   changes are proven in a browser via the `verify-ui` skill (screenshot,
   console, a11y); logic changes are proven with tests. No "should work".
3. **Not done until the gates are green.** Run the `run-quality-gates` skill
   (typecheck, lint, format, tests) before any commit/PR.
4. **Simplicity first, surgical changes.** Implement exactly what the task
   asks, in the smallest reasonable diff — no tangential refactors, no extra
   features. Before writing anything new, climb this ladder and stop at the
   first rung that answers: (1) does it need to exist at all? no → skip
   (YAGNI); (2) does this codebase already do it? → reuse, don't rewrite;
   (3) does the stdlib do it? → use it; (4) native platform feature (CSS over
   JS, `<input type="date">` over a picker lib)? → use it; (5) does an
   installed dependency do it? → use it; (6) fits in one line? → one line;
   (7) only then write the minimum that works. The ladder starts *after* the
   problem is understood — be lazy about the solution, never about reading.
   Laziness never applies to validation, error handling, security or
   accessibility.
5. **No fix without a root cause.** A bug report names a symptom. Find where
   the bad value is born before editing anything, and fix it there. Use the
   `debug-issue` skill when the cause is not obvious in one read.
6. **Every behavior change ships with a test.** New behavior gets a test; a bug
   fix gets a test that fails before the fix and passes after — watch it fail,
   or you have not proven it tests anything. See
   [testing.md](docs/engineering/testing.md).
7. **Follow the conventions and the design system.** See
   [conventions.md](docs/engineering/conventions.md) and
   [DESIGN.md](docs/DESIGN.md); match the existing code. No hardcoded colors or
   magic pixel values where a token exists.
8. **Record decisions proactively.** The moment a framework/library/pattern or
   domain-rule interpretation settles, run the `record-decision` skill: ADR in
   `docs/decisions/` + the affected doc updated, in the same PR.
9. **User-facing text goes through i18n**, never hardcoded.
10. **Self-review before push/PR.** Run the `self-review` skill; fix
    critical/medium findings first.
11. **Track what's on the humans.** Anything only a human can do (secret,
    access, external artifact) goes on
    [manual-actions.md](docs/engineering/manual-actions.md).
12. **Keep docs short and current.** Update the relevant doc with the change
    that affects it; never paste long content where a link suffices.

## Commands

PLACEHOLDER — filled from package.json scripts.

- `npm run dev` — dev server (TODO(confirm) port)
- `npm run typecheck` · `npm run lint` · `npm run format:check` · `npm run test`
- `npm run build`

## Knowledge Base

### Engineering (how we build)

- [architecture.md](docs/engineering/architecture.md)
- [DESIGN.md](docs/DESIGN.md) — design system: tokens, components, do's/don'ts
- [tech-stack.md](docs/engineering/tech-stack.md)
- [conventions.md](docs/engineering/conventions.md)
- [testing.md](docs/engineering/testing.md)
- [development-workflow.md](docs/engineering/development-workflow.md)
- [manual-actions.md](docs/engineering/manual-actions.md)

### Domain (what we build)

Stable reference — read these; update only when a concept genuinely changes.

- [glossary.md](docs/domain/glossary.md)
- [business-rules.md](docs/domain/business-rules.md)

### Decisions

Numbered, immutable ADRs: `docs/decisions/` (see its README + index).

## Capabilities (skills & agents)

Skills live in `.claude/skills/` — read natively by both Claude Code and VS
Code Copilot. Invoke one by name (`/verify-ui`) or let the agent pick it.

- **`implement-task`** — a request end to end: understand → build → verify in
  the browser → gates → self-review → PR.
- **`plan-feature`** — for work too big for one session: write the plan first
  (`.ai/plans/`), then execute it task by task with a fresh reviewer each time.
- **`verify-ui`** — prove a UI change works in a real browser.
- **`debug-issue`** — root-cause investigation before any fix.
- **`new-component`** — create a component that follows the conventions.
- **`run-quality-gates`** — typecheck + lint + format + tests, per gate.
- **`impeccable`** — design quality: checks UI against [DESIGN.md](docs/DESIGN.md);
  `/impeccable document` (re)generates it. Vendored upstream, updated with
  `npx impeccable update` (ADR 0002).
- **`record-decision`** — write an ADR + update the affected doc (rule #8).
- **`self-review`** — the `code-reviewer` agent audits the diff before push/PR.
- **`commit-and-pr`** — commit/PR format: English conventional-commit title,
  Turkish body carrying the evidence.
- **agent `code-reviewer`** — priority-ordered diff audit
  (correctness → a11y → i18n → conventions → tests → complexity).

Guardrails: hooks auto-format changed files, run the design detector on edited
UI files, and remind on docs drift (`.claude/hooks/`, wired up in
`.claude/settings.json` for Claude Code and `.github/hooks/` for Copilot); safe
commands are pre-approved in both settings files.

## Cross-session memory

A piece of work that spans more than one session keeps its state in
[.ai/STATE.md](.ai/STATE.md) (≤60 lines): goal, what is done with its evidence,
what is next, decisions still waiting on an ADR. `implement-task` rewrites it as
its last step; it is deleted when the branch merges, so anything permanent moves
to an ADR or `docs/` first.
