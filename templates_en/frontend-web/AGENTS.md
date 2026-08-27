# PROJECT_NAME — Agent Guide

> **TEMPLATE.** Copy this folder into the repo root, then run the
> `bootstrap-research` skill to fill every PLACEHOLDER from the real codebase.

PLACEHOLDER: one paragraph — what this app is, who uses it, rendering strategy
(SSR/CSR), markets/languages.

This file is the canonical guide for every AI agent working in this repo.
Details live in `docs/` and are linked below; treat the linked doc as the
source of truth. Keep this file and every doc **short** — everything loaded
into context costs tokens on each request.

## Golden Rules

1. **Think before coding.** No silent assumptions. If the task, design intent or
   a business rule is unclear, stop and ask; state every assumption explicitly.
2. **Prove it works.** "Built/written" is not enough. UI changes are verified in
   the browser via the `verify-ui` skill (screenshot, console, a11y); logic
   changes are verified with tests. See [testing.md](docs/engineering/testing.md).
3. **Not done until the gates are green.** Run the `run-quality-gates` skill
   (typecheck, lint, format, tests) before any commit/PR.
4. **Simplicity first, surgical changes.** Implement exactly what the task asks,
   in the smallest reasonable diff. No tangential refactors, no extra features.
5. **Work from verifiable goals.** A task without acceptance criteria and a
   "how to test" section (see the task template) is not ready — ask for it.
6. **Follow the conventions.** See [conventions.md](docs/engineering/conventions.md);
   match the style of the existing code.
7. **Record decisions proactively.** The moment a framework/library/pattern or
   domain-rule interpretation settles, run the `record-decision` skill: ADR in
   `docs/decisions/` + the affected doc updated, in the same PR. When unsure
   whether it deserves an ADR, lean toward recording it.
8. **User-facing text goes through i18n**, never hardcoded.
9. **Self-review before push/PR.** Run the `self-review` skill (the
   `code-reviewer` agent audits the diff); fix critical/medium findings first.
10. **Track what's on the humans.** Anything only a human can do (secret, access,
    external artifact) goes on [manual-actions.md](docs/engineering/manual-actions.md).
11. **Keep docs short and current.** Update the relevant doc with the change that
    affects it; never paste long content where a link suffices.

## Commands

PLACEHOLDER — bootstrap-research fills this from package.json scripts.

- `npm run dev` — dev server (TODO(confirm) port)
- `npm run typecheck` · `npm run lint` · `npm run format:check` · `npm run test`
- `npm run build`

## Knowledge Base

### Engineering (how we build)

- [architecture.md](docs/engineering/architecture.md)
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

- **skill `implement-task`** — implement a `task.md` end to end (read → build →
  verify → self-review → PR). Stops and asks if required task fields are missing.
- **skill `bootstrap-research`** — explore this codebase and fill the
  PLACEHOLDER sections in `docs/` with evidence.
- **skill `verify-ui`** — prove a UI change works in the browser (Playwright MCP).
- **skill `new-component`** — create a component that follows the conventions.
- **skill `run-quality-gates`** — typecheck + lint + format + tests, report results.
- **skill `simplify`** — quality pass on the diff (reuse, dead weight) after it
  works, before self-review.
- **skill `record-decision`** — write an ADR + update the affected doc (rule #7).
- **skill `self-review`** — `code-reviewer` agent audits the diff before push/PR.
- **skill `commit-and-pr`** — commit/PR format: English conventional-commit title,
  Turkish body/description carrying the evidence.
- **agent `code-reviewer`** — priority-ordered diff audit
  (correctness → a11y → i18n → conventions → tests).

Guardrails: Copilot hooks auto-format changed files and remind on docs drift
(`.github/hooks/`); safe commands are pre-approved in `.vscode/settings.json`.
Details in [conventions.md](docs/engineering/conventions.md).

## Task intake

Work arrives as a `task.md` written by an analyst (see the analyst workspace's
`task-template.md`): context, scope, measurable acceptance criteria, DoD,
how-to-test, and data sources. If any of those are missing, request them via
the task's author instead of guessing.
