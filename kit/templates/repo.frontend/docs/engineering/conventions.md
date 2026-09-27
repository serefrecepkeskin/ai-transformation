# Conventions

> **PLACEHOLDER** — paste the bootstrap prompt to replace the TODOs with
> the conventions actually observed in this codebase. Only rules the tools
> (linter/formatter) don't already enforce belong here.

## General

- TypeScript strict everywhere; `any` only with a written justification.
- Formatting/lint: ESLint, configured in `eslint.config.js` (flat config);
  the same command runs from `.lintstagedrc.json` at commit time. TODO(confirm):
  prettier, and whether TypeScript rules are on. A rule the linter enforces
  does not belong in this file.
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

- `.claude/hooks/*.sh` — the hook scripts themselves, shared by both runtimes.
  Wired up in `.claude/settings.json` (Claude Code) and
  `.github/hooks/format-and-docs.json` (Copilot) — **postToolUse** auto-formats changed
  files (prettier + eslint --fix); **agentStop** reminds when code changed but
  `docs/` didn't (drift), or dependencies changed without an ADR. Non-blocking.
- `.github/workflows/copilot-setup-steps.yml` — preinstalls dependencies in the
  Copilot coding agent's environment.
- `.husky/pre-commit` + `.lintstagedrc.json` — the commit-time gate: the same
  lint and test commands, enforced by git instead of by the agent remembering.
  `npm install` wires it (husky's `prepare` script points `core.hooksPath` at
  `.husky/`), so there is no second toolchain to install. The private-key and
  large-file guards at the top of the hook are the mechanical half of the
  secrets rule.
- `.vscode/settings.json` (Copilot) and `.claude/settings.json` (Claude Code) —
  what the agent may run and touch. Both files carry a comment on every block;
  read them before changing one. Never set `chat.tools.global.autoApprove`
  (older VS Code: `chat.tools.autoApprove`) — it approves every tool and turns
  the whole mechanism off.

### The three privacy layers, and what each one actually enforces

| Layer | Where | What it really does |
| --- | --- | --- |
| Discovery | `search.exclude`, `files.associations`, `github.copilot.enable`, `.gitignore` | Keeps secret files out of search, the workspace index and inline completions. Does **not** stop a targeted read |
| Action | `chat.tools.terminal.autoApprove`, `chat.tools.edits.autoApprove`, `chat.agent.sandbox.enabled`, `permissions.deny` | Approval gates on commands and edits. On the **Claude Code** side `Read()`/`Edit()` deny rules are a real block, covering the file tools and the `cat`/`head`/`tail`/`sed` commands Claude Code recognises; the sandbox is the only OS-level block on either side |
| Prompt | Golden rule "secrets are never read, printed or pasted" | The layer that covers what the other two cannot |

Why the deny list is surgical rather than "block every `.ini`": a deny rule
cannot carry an exception. `Read(**/*.ini)` would also close `alembic.ini`,
`pytest.ini` and `setup.cfg`, and nothing could reopen them.

**Known limit, stated plainly:** GitHub's content exclusion is not applied in
Copilot's agent or edit modes and needs Business/Enterprise, so on the Copilot
side there is no hard block on reading a file. A secret that must never be
readable belongs in a vault, not in the workspace.

- The guardrail chain is: agent hooks → the commit hook → local quality gates →
  CI → review. The first two are convenience and early warning; gates, CI and
  review remain the enforcement.
