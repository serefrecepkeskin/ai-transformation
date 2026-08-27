# ADR 0001 — Adopt AI-driven workflow

- **Status:** Accepted
- **Date:** TODO
- **Deciders:** TODO

## Context

The company is standardizing AI-assisted development on GitHub Copilot. Agents
need a stable, cheap-to-load context: rules, knowledge and task recipes that
don't live in individual heads or chat history.

## Decision

Adopt the company template: canonical `AGENTS.md` + `docs/` knowledge base
(engineering / domain / decisions) + skills in `.github/skills/` + the
`code-reviewer` custom agent. Docs are kept deliberately short (token cost);
placeholders are filled from the real codebase via the `bootstrap-research`
skill; every settled decision becomes an ADR in the same PR.

## Alternatives

- Free-form prompting per developer — rejected: inconsistent output, no memory.
- One giant instruction file — rejected: expensive on every request, hard to
  maintain; skills load on demand instead.

## Consequences

- New work must arrive as a `task.md` with acceptance criteria, DoD and
  how-to-test (analyst workspace template).
- Docs and code must not drift: doc updates ship in the same PR.
