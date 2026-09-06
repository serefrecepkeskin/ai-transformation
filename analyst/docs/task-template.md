# Task Template

Every task delivered to a developer repo follows this format. The developer
side's `implement-task` skill **rejects** a task missing any required section.
File name: `tasks/<ID>-<kebab-title>.md` (e.g. `TASK-101-user-export.md`).

```markdown
# <ID> — <Short imperative title>

- **Author:** <name> (stays reachable for questions)
- **Date:** YYYY-MM-DD
- **Target repo:** <repo name> (<frontend | python | dotnet>)
- **Priority:** <high | medium | low>

## Context (required)

Why this is needed, in 3-6 sentences. The user/business problem, not the
solution. Link related tasks/ADRs if any.

## Scope (required)

- **In:** what this task delivers.
- **Out:** what it explicitly does NOT deliver (prevents scope creep).

## Acceptance criteria (required, measurable)

Each criterion must be checkable by a test or by observation — no "should
work properly". Prefer given/when/then.

1. Given …, when …, then …
2. …

## Data sources (required when data is involved)

Verified against the live schema via db-research — never from memory.

| Source (db.schema.table.column) | Meaning | Verified on |
| ------------------------------- | ------- | ----------- |
| crm.dbo.Customers.LastLoginAt   | …       | YYYY-MM-DD  |

Notes: joins/filters that matter, data quirks found during research
(nullability, formats, gotchas). Column names and shapes only — no real
customer values.

## UI / i18n notes (required for UI tasks)

Screens/components affected, states (loading/empty/error), and the reminder
that all user-facing text is translatable. Reference designs if any.

## How to test (required)

Concrete steps a developer (or their agent) can execute: where to click /
what to call, with what input, and what must be observed. Include edge cases.

## Definition of Done (required)

The baseline from definition-of-done.md, plus task-specific items:

- [ ] All acceptance criteria demonstrably met
- [ ] Quality gates green; new behavior covered by tests
- [ ] <task-specific item>

## Open questions / assumptions

Anything unconfirmed, clearly owned: who will answer it, by when. An empty
section means "nothing is assumed".
```
