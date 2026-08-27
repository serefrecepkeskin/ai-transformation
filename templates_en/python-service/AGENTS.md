# PROJECT_NAME — Agent Guide

> **TEMPLATE.** Copy this folder into the repo root, then run the
> `bootstrap-research` skill to fill every PLACEHOLDER from the real codebase.

PLACEHOLDER: one paragraph — what this service does, its consumers, the
framework (FastAPI/Django/Flask/...), and how it is deployed.

This file is the canonical guide for every AI agent working in this repo.
Details live in `docs/` and are linked below; treat the linked doc as the
source of truth. Keep this file and every doc **short** — everything loaded
into context costs tokens on each request.

## Golden Rules

1. **Think before coding.** No silent assumptions. If the task or a business
   rule is unclear, stop and ask; state every assumption explicitly.
2. **Prove it works.** "Written" is not enough: behavior changes are verified
   with tests, and endpoint changes by actually calling the endpoint locally.
   See [testing.md](docs/engineering/testing.md).
3. **Not done until the gates are green.** Run the `run-quality-gates` skill
   (lint, types, tests) before any commit/PR.
4. **Simplicity first, surgical changes.** Implement exactly what the task asks,
   in the smallest reasonable diff. No tangential refactors.
5. **Work from verifiable goals.** A task without acceptance criteria and a
   "how to test" section (see the task template) is not ready — ask for it.
6. **Follow the conventions.** See [conventions.md](docs/engineering/conventions.md);
   match the style of the existing code.
7. **Record decisions proactively.** The moment a library/pattern/domain-rule
   interpretation settles, run the `record-decision` skill: ADR + affected doc
   updated, in the same PR. When unsure, lean toward recording.
8. **Validate at the boundaries.** External input (HTTP, queue, third-party
   API) is untrusted: parse/validate it at the edge; typed models inside.
9. **Self-review before push/PR.** Run the `self-review` skill (the
   `code-reviewer` agent audits the diff); fix critical/medium findings first.
10. **Track what's on the humans.** Secrets, access, external artifacts go on
    [manual-actions.md](docs/engineering/manual-actions.md).
11. **Schema changes only via migrations** — never edit the database or a
    generated migration by hand; use the `db-migration` skill.

## Commands

PLACEHOLDER — bootstrap-research fills this from pyproject/Makefile/scripts.

- `TODO` — run locally
- `TODO` — lint (e.g. ruff) · type check (e.g. mypy) · tests (e.g. pytest)

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

- **skill `implement-task`** — implement a `task.md` end to end. Stops and asks
  if required task fields are missing.
- **skill `bootstrap-research`** — explore this codebase and fill the
  PLACEHOLDER sections in `docs/` with evidence.
- **skill `run-quality-gates`** — lint + types + tests, report results.
- **skill `simplify`** — quality pass on the diff (reuse, dead weight) after it
  works, before self-review.
- **skill `new-endpoint`** — add an API endpoint following the conventions.
- **skill `db-migration`** — create/apply a schema migration safely.
- **skill `record-decision`** — write an ADR + update the affected doc (rule #7).
- **skill `self-review`** — `code-reviewer` agent audits the diff before push/PR.
- **skill `commit-and-pr`** — commit/PR format: English conventional-commit title,
  Turkish body/description carrying the evidence.
- **agent `code-reviewer`** — priority-ordered diff audit
  (correctness → typing → boundaries → tests).

Guardrails: Copilot hooks auto-format changed files and remind on docs drift
(`.github/hooks/`); safe commands are pre-approved in `.vscode/settings.json`.
Details in [conventions.md](docs/engineering/conventions.md).

## Task intake

Work arrives as a `task.md` written by an analyst (see the analyst workspace's
`task-template.md`): context, scope, measurable acceptance criteria, DoD,
how-to-test, and data sources (which DB/table/column). If any of those are
missing, request them via the task's author instead of guessing.
