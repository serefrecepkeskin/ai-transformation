# <repo> — Agent Guide

<!-- PLACEHOLDER — the bootstrap prompt fills every section from files it actually read; what it cannot verify
     becomes TODO(confirm). One paragraph here: what this service does, who calls it, stack in one line.
     Keep the whole file ≤ ~12 KB (it loads on every request) and REPO-SPECIFIC ONLY. Rules that hold in every
     repo (engineering principles, test discipline, language, secrets, commit format, shared-data mechanics) live
     in the platform guide / principles and must not be repeated here. The H2 headings below are fixed: same
     names, same order in every backend — scripts/link-repo.sh --check compares them with this file. -->

{{PLATFORM_LINE}}

## Stack & run
<!-- Frameworks and versions (from the lockfile), run command + port, where config lives (default.ini /
     .env.example — never the real values), setup pointer (README / docs/engineering/tech-stack.md). -->

## Where code goes
<!-- Directory → responsibility, one line each (long form: docs/engineering/architecture.md). End with an
     "Adding:" sub-list: new endpoint (placement, registration, then `$new-endpoint`), new model/migration
     (`$db-migration`), new job / worker step. -->

## Reuse before writing new
<!-- The helpers an agent would otherwise rewrite: file::function and why it is the single source. -->

## Conventions
<!-- Naming, layering, validation, error types — only what the linter does not already enforce and what
     differs from the framework's plain habits. -->

## Security & gotchas
<!-- Rules written from real incidents in THIS repo, each with the test that pins it: how a request is scoped
     to its caller (tenant/org/user predicate), the auth layer, rate limits, PII handling, middleware order,
     "never do X". Sub-headings (###) allowed. -->

## Shared data
<!-- This repo's role in data shared with other repos of the workspace: owner or reader of which tables /
     queues / buckets, what it writes, invariants it shares with a twin implementation elsewhere. Single repo
     with its own database: say so in one line. Do not restate the platform guide. -->

## Tests
<!-- Test dir, the exact run command and the config it needs, what to mock (external I/O), which tests need a
     real database, guard tests to keep green. -->

## Workflow
<!-- Exactly this shape:
- Gates (all must pass before a commit): `<one line: ruff check . && ruff format --check . && … && pytest>`
- New config key → `<default.ini | .env.example>` too; its value goes on docs/engineering/manual-actions.md.
- Settled library/pattern/rule → an ADR in docs/decisions/ in the same PR.
- Kit: skills `.claude/skills/`, reviewers `.claude/agents/`, hooks `.claude/hooks` come from the agent kit
  (`link-repo.sh` wires them, `--check` / `check-drift.sh` verifies). Before handing over: cold review with
  `backend-reviewer` (+ `security-reviewer` for auth/scoping/PII/migrations). Commit/PR: `$commit-and-pr`.
-->
