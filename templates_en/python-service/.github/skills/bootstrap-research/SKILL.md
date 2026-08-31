---
name: bootstrap-research
description: Researches this codebase and fills the PLACEHOLDER sections in AGENTS.md and docs/ with evidence — architecture, tech stack, conventions, commands, testing setup. Use once after copying the template into an existing project, or whenever docs still contain PLACEHOLDER/TODO(confirm) markers.
---

# Bootstrap the docs from the real codebase

Fill every `PLACEHOLDER` in `AGENTS.md` and `docs/` with **evidence from this
repo** — never from assumptions. Anything you cannot verify stays marked
`TODO(confirm): <question>` for a human.

## 1. Survey

- Manifests: `pyproject.toml` / `requirements*.txt` / `setup.cfg` (framework,
  dependencies + pinned versions), lockfile, `Makefile`/`noxfile`/scripts.
- Layout: package structure, entrypoints, settings/config layer, models,
  routers/views, background jobs.
- Data: ORM + migration tool (alembic/Django migrations), DB engines used.
- CI: `.github/workflows/*` — what gates actually run. Containerfile/Dockerfile.
- Existing docs/README — harvest, don't duplicate.

## 2. Fill, file by file

- `AGENTS.md` — project summary paragraph + the **Commands** section (real
  commands only; delete ones that don't exist).
- `docs/engineering/tech-stack.md` — the stack table with installed versions
  (read from the lockfile, do not guess).
- `docs/engineering/architecture.md` — service shape, package layout (real
  tree), layering, how config/secrets are loaded, external integrations.
- `docs/engineering/conventions.md` — observed naming, typing discipline,
  lint/format tools, error-handling and logging patterns.
- `docs/engineering/testing.md` — actual runners, folder layout, CI gates.
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

Then hand over the two things that close the adoption:

- Delete the `> **TEMPLATE.**` blockquote at the top of `AGENTS.md` once the
  placeholders around it are real.
- Once the team has reviewed the diff, set `allowPlaceholders` to `false` in
  `.github/standard-version.json`. That arms the PLACEHOLDER gate in
  `standard-check.yml`: from then on a leftover placeholder fails the PR
  instead of warning.
