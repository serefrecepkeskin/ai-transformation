# ADR 0001 — Adopt AI-driven workflow

- **Status:** Accepted
- **Date:** TODO
- **Deciders:** TODO

## Context

The company is standardizing AI-assisted development. Agents need a stable,
cheap-to-load context — rules, knowledge and task recipes that do not live in
individual heads or chat history — and it has to work on more than one runtime:
GitHub Copilot in VS Code and Claude Code both operate in these repos.

## Decision

Adopt the company template: canonical `AGENTS.md` (imported by `CLAUDE.md`)
+ `docs/` knowledge base (engineering / domain / decisions) + skills in
`.claude/skills/`, which both Claude Code and VS Code Copilot read natively +
the `code-reviewer` agent in each runtime's own format. Docs are kept
deliberately short (token cost); placeholders are filled from the real codebase
by the bootstrap prompt; every settled decision becomes an ADR in the same PR.

## Alternatives

- Free-form prompting per developer — rejected: inconsistent output, no memory.
- One giant instruction file — rejected: expensive on every request, hard to
  maintain; skills load on demand instead.

## Consequences

- Work is only picked up when "done" can be stated as something observable;
  otherwise it goes back to its author.
- Skills and hook scripts have one home each; only the thin manifests are
  duplicated per runtime.
- Docs and code must not drift: doc updates ship in the same PR.
