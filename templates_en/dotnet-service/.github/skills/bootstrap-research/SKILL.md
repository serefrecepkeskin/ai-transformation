---
name: bootstrap-research
description: Researches this codebase and fills the PLACEHOLDER sections in AGENTS.md and docs/ with evidence — architecture, tech stack, conventions, commands, testing setup. Use once after copying the template into an existing project, or whenever docs still contain PLACEHOLDER/TODO(confirm) markers.
---

# Bootstrap the docs from the real codebase

Fill every `PLACEHOLDER` in `AGENTS.md` and `docs/` with **evidence from this
repo** — never from assumptions. Anything you cannot verify stays marked
`TODO(confirm): <question>` for a human.

## 1. Survey

- Solution/projects: `*.sln`, `*.csproj` (TargetFramework, package references +
  versions), `Directory.Build.props`, `.editorconfig`, `global.json`.
- Layout: project boundaries (API/Domain/Infrastructure/Tests), entrypoints,
  DI registrations, options/config classes, middleware pipeline.
- Data: EF Core DbContexts, migration folders, DB engines used.
- CI: `.github/workflows/*` (or pipeline files) — what gates actually run.
  Dockerfile, if any.
- Existing docs/README — harvest, don't duplicate.

## 2. Fill, file by file

- `AGENTS.md` — project summary paragraph + the **Commands** section (real
  commands only; delete ones that don't exist).
- `docs/engineering/tech-stack.md` — the stack table with installed versions
  (read from the csproj/lock files, do not guess).
- `docs/engineering/architecture.md` — solution shape, project dependency
  directions, layering, how config/secrets are loaded, external integrations.
- `docs/engineering/conventions.md` — observed naming, nullable setting, async
  patterns, error-handling and logging conventions.
- `docs/engineering/testing.md` — actual frameworks, folder layout, CI gates.
- `docs/engineering/development-workflow.md` — branch/PR/release flow from CI
  configs you can observe.

## 3. Mark the gaps

- Unverifiable or ambiguous → `TODO(confirm): <specific question>`.
- Things only a human can provide (credentials, external specs) → add to
  [manual-actions.md](../../../docs/engineering/manual-actions.md).

## 4. Report

Summarize: which placeholders were filled, the list of `TODO(confirm)` items,
and any code-vs-config contradictions found. Do not commit — leave the diff for
the team to review.
