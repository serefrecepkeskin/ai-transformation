# PROJECT_NAME — Agent Guide

> **TEMPLATE.** Copy this folder into the repo root, then paste the bootstrap
> prompt (`templates_en/bootstrap-prompt.md`) into the agent to fill every
> PLACEHOLDER from the real codebase.

PLACEHOLDER: one paragraph — what this service does, its consumers, the
framework (FastAPI/Django/Flask/...), and how it is deployed.

This file is the canonical guide for every AI agent working in this repo, on
either runtime (GitHub Copilot and Claude Code both read it). Details live in
`docs/` and are linked below; treat the linked doc as the source of truth. Keep
this file and every doc **short** — everything loaded into context costs tokens
on each request.

## Golden Rules

1. **Think before coding.** No silent assumptions. If the task or a business
   rule is unclear, stop and ask; state every assumption explicitly.
2. **Evidence before claims.** Never say done, fixed, passing or working
   without having run the command *in this session* and read its output. No
   "should work", no "looks correct". If you did not run it, say that instead.
3. **Not done until the gates are green.** Run the `run-quality-gates` skill
   (lint, types, tests) before any commit/PR.
4. **Simplicity first, surgical changes.** Implement exactly what the task
   asks, in the smallest reasonable diff — no tangential refactors, no extra
   features. Before writing anything new, climb this ladder and stop at the
   first rung that answers: (1) does it need to exist at all? no → skip
   (YAGNI); (2) does this codebase already do it? → reuse, don't rewrite;
   (3) does the stdlib do it? → use it; (4) native platform/DB feature? → use
   it; (5) does an installed dependency do it? → use it; (6) fits in one line?
   → one line; (7) only then write the minimum that works. The ladder starts
   *after* the problem is understood — be lazy about the solution, never about
   reading. Laziness never applies to validation, error handling or security.
5. **No fix without a root cause.** A bug report names a symptom. Find where
   the bad value is born before editing anything, and fix it there — one guard
   in the shared function beats a guard in every caller. Use the `debug-issue`
   skill when the cause is not obvious in one read.
6. **Every behavior change ships with a test.** New behavior gets a test; a bug
   fix gets a test that fails before the fix and passes after — watch it fail,
   or you have not proven it tests anything. See
   [testing.md](docs/engineering/testing.md).
7. **Follow the conventions.** See [conventions.md](docs/engineering/conventions.md);
   match the style of the existing code.
8. **Record decisions proactively.** The moment a library/pattern/domain-rule
   interpretation settles, run the `record-decision` skill: ADR + affected doc
   updated, in the same PR. When unsure, lean toward recording.
9. **Validate at the boundaries.** External input (HTTP, queue, third-party
   API) is untrusted: parse/validate it at the edge; typed models inside.
10. **Self-review before push/PR.** Run the `self-review` skill; fix
    critical/medium findings first.
11. **Track what's on the humans.** Secrets, access, external artifacts go on
    [manual-actions.md](docs/engineering/manual-actions.md).
12. **Schema changes only via migrations** — never edit the database or a
    generated migration by hand; use the `db-migration` skill.
13. **Keep docs short and current.** Update the relevant doc with the change
    that affects it; never paste long content where a link suffices.

## Commands

PLACEHOLDER — filled from pyproject/Makefile/scripts.

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

Skills live in `.claude/skills/` — read natively by both Claude Code and VS
Code Copilot. Invoke one by name (`/implement-task`) or let the agent pick it.

- **`implement-task`** — a request end to end: understand → build → verify →
  gates → self-review → PR. Stops and asks when the goal is not verifiable.
- **`plan-feature`** — for work too big for one session: write the plan first
  (`.ai/plans/`), then execute it task by task with a fresh reviewer each time.
- **`debug-issue`** — root-cause investigation before any fix.
- **`run-quality-gates`** — lint + types + tests, reported per gate.
- **`new-endpoint`** — add an API endpoint following the conventions.
- **`db-migration`** — create/apply a schema migration safely.
- **`record-decision`** — write an ADR + update the affected doc (rule #8).
- **`self-review`** — the `code-reviewer` agent audits the diff before push/PR.
- **`commit-and-pr`** — commit/PR format: English conventional-commit title,
  Turkish body carrying the evidence.
- **agent `code-reviewer`** — priority-ordered diff audit
  (correctness → typing → boundaries → tests → complexity).

Guardrails: hooks auto-format changed files and remind on docs drift
(`.claude/hooks/`, wired up in `.claude/settings.json` for Claude Code and
`.github/hooks/` for Copilot); safe commands are pre-approved in both
`.claude/settings.json` and `.vscode/settings.json`.

## Cross-session memory

A piece of work that spans more than one session keeps its state in
[.ai/STATE.md](.ai/STATE.md) (≤60 lines): goal, what is done with its evidence,
what is next, decisions still waiting on an ADR. `implement-task` rewrites it as
its last step; it is deleted when the branch merges, so anything permanent moves
to an ADR or `docs/` first.
