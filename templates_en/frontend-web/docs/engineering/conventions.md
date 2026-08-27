# Conventions

> **PLACEHOLDER** — run the `bootstrap-research` skill to replace the TODOs with
> the conventions actually observed in this codebase. Only rules the tools
> (linter/formatter) don't already enforce belong here.

## General

- TypeScript strict everywhere; `any` only with a written justification.
- Formatting via TODO(confirm) (tool + config).
- Commits & PRs: English conventional-commit title, Turkish body/description —
  see the `commit-and-pr` skill. TODO(confirm): how it is enforced (commitlint?).

## Components

- Location & naming: TODO (directory scheme, PascalCase/kebab, co-location rules).
- Props typing and composition patterns: TODO.
- Styling: TODO (utility classes / CSS modules / tokens — and what is forbidden,
  e.g. hardcoded hex values).

## State & data

- What belongs in global state vs component state vs URL: TODO.
- Data fetching pattern and error handling contract: TODO.

## i18n

- User-visible text is **never** hardcoded — always through the i18n mechanism:
  TODO(confirm) (library, key naming, locale files, supported locales).

## Accessibility

- Interactive elements: semantic HTML first; TODO (component library a11y rules).

## Testability

- Add `data-testid` to elements that are E2E/integration targets.

## Branching & PRs

- Branch names: `<type>/<kebab-description>` with a conventional-commit type.
- PR title: valid conventional commit (it becomes the squash commit).
- TODO(confirm): release automation reading those commits, if any.

## Automated guardrails (Copilot hooks & approvals)

- `.github/hooks/format-and-docs.json` — **postToolUse** auto-formats changed
  files (prettier + eslint --fix); **agentStop** reminds when code changed but
  `docs/` didn't (drift), or dependencies changed without an ADR. Non-blocking.
- `.github/workflows/copilot-setup-steps.yml` — preinstalls dependencies in the
  Copilot coding agent's environment.
- `.vscode/settings.json` — terminal command allowlist/denylist for agent mode
  (`chat.tools.terminal.autoApprove`). Never set the global
  `chat.tools.autoApprove` — it disables approval entirely.
- The guardrail chain is: hooks → local quality gates → CI → review. Hooks are
  a convenience layer; gates and CI remain the enforcement.
