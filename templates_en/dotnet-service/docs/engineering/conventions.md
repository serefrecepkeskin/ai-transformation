# Conventions

> **PLACEHOLDER** — run the `bootstrap-research` skill to replace the TODOs with
> the conventions actually observed in this codebase. Only rules the tools
> (analyzers/formatter) don't already enforce belong here.

## General

- Nullable reference types enabled; no `!` to silence warnings without a
  written justification.
- Formatting via `.editorconfig` + `dotnet format`; TODO(confirm) analyzer set.
- Commits & PRs: English conventional-commit title, Turkish body/description —
  see the `commit-and-pr` skill. TODO(confirm): how it is enforced (commitlint?).

## Structure & naming

- Project boundaries and allowed dependency directions: TODO.
- Naming: TODO (async suffix, DTO suffix, folder-per-feature vs layer, as observed).

## Boundaries & errors

- External input is validated at the edge (typed DTOs + validation); EF
  entities never cross the API boundary.
- Error contract: TODO (ProblemDetails? exception middleware? logging).
- Secrets/config only through the options pattern and the configured secret
  sources — never hardcoded, never committed.

## Async & data access

- Async end to end: no `.Result`/`.Wait()`/`async void`; `CancellationToken`
  passed through public async APIs.
- TODO: DbContext lifetime pattern; parameterized queries only; schema changes
  only via migrations (`ef-migration` skill).

## Logging & observability

- TODO(confirm): logger usage, correlation ids, what must never be logged (PII).

## Branching & PRs

- Branch names: `<type>/<kebab-description>` with a conventional-commit type.
- PR title: valid conventional commit (it becomes the squash commit).
- TODO(confirm): release automation reading those commits, if any.

## Automated guardrails (Copilot hooks & approvals)

- `.github/hooks/verify-and-docs.json` — **agentStop** checks
  `dotnet format --verify-no-changes` and reminds when code changed but `docs/`
  didn't (drift), or project files changed without an ADR. Formatting runs at
  session end, not per edit — a whole-solution scan per tool call is too slow.
  Non-blocking.
- `.github/workflows/copilot-setup-steps.yml` — preinstalls dependencies in the
  Copilot coding agent's environment.
- `.vscode/settings.json` — terminal command allowlist/denylist for agent mode
  (`chat.tools.terminal.autoApprove`); `dotnet ef database update` deliberately
  requires approval. Never set the global `chat.tools.autoApprove`.
- The guardrail chain is: hooks → local quality gates → CI → review. Hooks are
  a convenience layer; gates and CI remain the enforcement.
