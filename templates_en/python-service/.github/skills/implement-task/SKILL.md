---
name: implement-task
description: Implements a task.md end to end — read the task, build, test, self-review, open a PR. Use when given a task file or ticket (e.g. "implement TASK-123"). If required task fields (acceptance criteria, DoD, how-to-test, data sources) are missing, it stops and asks; it never fabricates requirements.
---

# Implement a task

> Golden rule: no silent assumptions. Anything unclear in the task gets asked,
> not invented (AGENTS.md rule #1).

## 1. Read the task

Read the `task.md`. Verify it has: context, scope (in/out), measurable
acceptance criteria, DoD, how-to-test, and data sources (DB/table/column) if
data is involved. **Missing any of these → stop and ask the task author.**

## 2. Gather context

Read the docs the task touches: [conventions.md](../../../docs/engineering/conventions.md),
[architecture.md](../../../docs/engineering/architecture.md), relevant ADRs and
domain docs. Look for existing modules/helpers to reuse before writing new ones.

## 3. Branch

From fresh main: `<type>/<kebab-description>` (conventional-commit type), e.g.
`feat/TASK-123-export-endpoint`.

## 4. Build

Smallest diff that satisfies the acceptance criteria. New endpoints via the
`new-endpoint` skill; schema changes via `db-migration`; validate external
input at the boundary. If a decision settles along the way, run
`record-decision` before moving on.

## 5. Verify

- New behavior → at least one test; bug fix → failing test first, then the fix.
- Endpoint changes → call the endpoint locally and check the real response.
- Walk the task's own "how to test" steps.

## 6. Gates + self-review

Run `run-quality-gates`; optionally run `simplify` on the working diff (reuse/dead-weight cleanup), then `self-review`. Fix critical/medium findings.

## 7. PR

Conventional-commit PR title. Description: what changed, how it was verified,
what self-review found, which acceptance criteria are covered. Check off the
task's DoD list.
