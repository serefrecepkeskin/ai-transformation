---
name: bootstrap-research
description: Researches this codebase and fills the PLACEHOLDER sections in AGENTS.md and docs/ with evidence — architecture, tech stack, conventions, commands, testing setup. Use once after copying the template into an existing project, or whenever docs still contain PLACEHOLDER/TODO(confirm) markers.
---

# Bootstrap the docs from the real codebase

Fill every `PLACEHOLDER` in `AGENTS.md` and `docs/` with **evidence from this
repo** — never from assumptions. Anything you cannot verify stays marked
`TODO(confirm): <question>` for a human.

## 1. Survey

- Manifests: `package.json` (name, scripts, dependencies + versions), lockfile
  (package manager), `tsconfig`, framework config (next.config, vite.config, ...).
- Layout: top-level folders, component/page/store/api directories, test dirs.
- CI: `.github/workflows/*` — what gates actually run.
- Existing docs/README — harvest, don't duplicate.

## 2. Fill, file by file

- `AGENTS.md` — project summary paragraph + the **Commands** section (real
  script names only; delete commands that don't exist).
- `docs/engineering/tech-stack.md` — the stack table with installed versions
  (read from the lockfile/package.json, do not guess).
- `docs/engineering/architecture.md` — rendering strategy, folder structure
  (real tree), layers, state/data-fetching approach as found in code.
- `docs/engineering/conventions.md` — observed naming, styling approach, i18n
  mechanism, lint/format tools. Note contradictions between code and config.
- `docs/engineering/testing.md` — actual test runners, folder layout, CI gates.
- `docs/engineering/development-workflow.md` — branch/PR/release flow from CI
  configs and repo settings you can observe.

## 3. Mark the gaps

- Unverifiable or ambiguous → `TODO(confirm): <specific question>`.
- Things only a human can provide (secrets, external specs) → add to
  [manual-actions.md](../../../docs/engineering/manual-actions.md).

## 4. Report

Summarize: which placeholders were filled, the list of `TODO(confirm)` items,
and any code-vs-config contradictions found. Do not commit — leave the diff for
the team to review.
