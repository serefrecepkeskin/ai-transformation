---
name: implement-task
description: Implements a task.md end to end — read the task, build, verify in the browser, test, self-review, open a PR. Use when given a task file or ticket (e.g. "implement TASK-123"). If required task fields (acceptance criteria, DoD, how-to-test) are missing, it stops and asks; it never fabricates requirements.
---

# Implement a task

> Golden rule: no silent assumptions. Anything unclear in the task gets asked,
> not invented (AGENTS.md rule #1).

## 1. Read the task

Read the `task.md`. Verify it has: context, scope (in/out), measurable
acceptance criteria, DoD, how-to-test, and data sources if data is involved.
**Missing any of these → stop and ask the task author.**

## 2. Gather context

Read the docs the task touches: [conventions.md](../../../docs/engineering/conventions.md),
[architecture.md](../../../docs/engineering/architecture.md), relevant ADRs and
domain docs. Look for existing components/utilities to reuse before writing new ones.

## 3. Branch

From fresh main: `<type>/<kebab-description>` (conventional-commit type), e.g.
`feat/TASK-123-availability-page`.

## 4. Build

Smallest diff that satisfies the acceptance criteria. Follow the conventions;
new UI via the `new-component` skill; user-facing text through i18n. If a
decision settles along the way, run `record-decision` before moving on.

## 5. Verify

- UI changes → `verify-ui` skill (browser evidence: screenshot, console, a11y).
- Logic changes → tests (new behavior gets at least one test; a bug fix gets a
  failing test first).
- Walk the task's own "how to test" steps.

## 6. Gates + self-review

Run `run-quality-gates`, then `self-review`. Fix critical/medium findings.
Simplification is not a cleanup pass here — it happened while writing, via the
ladder in AGENTS.md rule #4.

## 7. PR

Conventional-commit PR title. Description: what changed, how it was verified
(browser evidence + tests), what self-review found, which acceptance criteria
are covered. Check off the task's DoD list.

## 8. Update the feature state

Final step: update [.ai/STATE.md](../../../.ai/STATE.md) — what is done (with
its evidence), what is next, decisions still waiting on an ADR, and any
`TODO(confirm)` handed to a human. Create the file from its own section
skeleton if it is missing. It is deleted when the branch merges, so anything
permanent goes to an ADR or `docs/` first.
