# Conventions

> **PLACEHOLDER** — paste the bootstrap prompt to replace the TODOs with
> the conventions actually observed in this codebase. Only rules the tools
> (linter/formatter) don't already enforce belong here.

## General

- Full type hints on public functions; `Any` only with a written justification.
- Formatting/lint via TODO(confirm) (tool + config).
- Commits & PRs: English conventional-commit title, Turkish body/description —
  see the `commit-and-pr` skill. TODO(confirm): how it is enforced (commitlint?).

## Structure & naming

- Module/package layout rules: TODO (where routers, services, models live).
- Naming: TODO (snake_case modules, model suffixes, etc. as observed).

## Boundaries & errors

- External input is validated at the edge (typed request models); internals
  work with typed objects, not raw dicts.
- Error contract: TODO (exception hierarchy, error response shape, logging).
- Secrets/config only through the settings layer — never `os.environ` inline,
  never committed.

## Data access

- TODO: session/transaction management pattern; no SQL string concatenation;
  schema changes only via migrations (`db-migration` skill).

## Logging & observability

- TODO(confirm): logger usage, correlation ids, what must never be logged (PII).

## Branching & PRs

- Branch names: `<type>/<kebab-description>` with a conventional-commit type.
- PR title: valid conventional commit (it becomes the squash commit).
- TODO(confirm): release automation reading those commits, if any.

## Automated guardrails (Copilot hooks & approvals)

- `.claude/hooks/*.sh` — the hook scripts themselves, shared by both runtimes.
  Wired up in `.claude/settings.json` (Claude Code) and
  `.github/hooks/format-and-docs.json` (Copilot) — **postToolUse** auto-formats changed
  Python files (ruff format + ruff check --fix); **agentStop** reminds when code
  changed but `docs/` didn't (drift), or dependencies changed without an ADR.
  Non-blocking.
- `.github/workflows/copilot-setup-steps.yml` — preinstalls dependencies in the
  Copilot coding agent's environment.
- `.vscode/settings.json` (Copilot) and `.claude/settings.json` (Claude Code)
  — the command allowlist/denylist for agent mode. Never set the global
  `chat.tools.autoApprove` — it disables approval entirely.
- The guardrail chain is: hooks → local quality gates → CI → review. Hooks are
  a convenience layer; gates and CI remain the enforcement.
