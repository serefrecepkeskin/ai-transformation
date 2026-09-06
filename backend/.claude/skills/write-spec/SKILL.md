---
name: write-spec
description: Writes a task spec (agent-work/<id>/spec.md) that a session with no chat history can execute without guessing — observable goal, pointers, constraints, acceptance criteria, exact verification commands — and, for work too big for one session, the plan (agent-work/<id>/plan.md) that splits it into spec-sized tasks. Use before delegating to a subagent, a worktree, the Copilot coding agent or a colleague, whenever a feature spans several sessions or subsystems, or when someone asks to "spec this out" / "plan this".
---

# Write a spec

A spec is the whole conversation the implementer will get. A delegated session
cannot ask back; whatever is missing becomes either a question in the report
(good) or a silent guess (bad). Write for the first outcome.

## What makes a spec executable

- **One observable "done".** Name the command, test or screen state that
  proves it. If you cannot, the task is not ready — split it or ask the user.
- **Pointers over prose.** Link the design doc section, the files to change
  and the files to imitate. The implementer reads code well; it cannot read
  your head.
- **Constraints only where deviation hurts.** Scoping predicate, migration
  ownership, no-commit, secrets, the repo's `AGENTS.md`. Do not enumerate
  styles the repo already enforces.
- **Out of scope is a real section.** It stops the implementer from
  "helpfully" widening the change.
- **Verification is copy-pasteable.** Exact commands with the config they
  need, and what output means pass.
- **Open points are labelled.** If you are unsure, say so; the implementer
  records a decision instead of hiding it.

## Sizing

One spec = one repo, one reviewable diff, one session. A larger item is
usually 2–4 specs. A change that spans backend and frontend is two specs with
the contract written down first.

## Bigger than one spec — write the plan first

Work that needs more than one session or more than one reviewable diff gets
`agent-work/<id>/plan.md` before any code:

```markdown
# <Feature> — plan
**Goal:** one sentence; what "done" means, measurably.
**Out of scope:** … **Constraints:** rules copied verbatim from the source.
**Files:** each file to create or change, one line on its responsibility.

## Task 1 — <deliverable>
- [ ] steps, in order · the test that proves it, written first
- [ ] verification: the exact command, and what output means pass
```

A task is the smallest unit that carries its own test and could be rejected on
its own — never "part 1 of a refactor". Execute one task at a time: implement →
its verification → gates → cold review → commit; tick the box and refresh
`report.md` before the next. Heavy self-contained tasks go to a subagent with
the task text and the plan's constraints, not your session history — then
check its diff yourself. Before shipping, walk the goal end to end as a user
would: green tasks with a broken feature is the failure this step catches. The
plan and the report are the memory across sessions; the chat is disposable.

## Procedure

1. Create `agent-work/<id>/` (id: `<ticket>-<slug>`, e.g. `PROJ-142-cancel-endpoint`).
2. Copy `references/task-spec.md`, fill every section; delete none — an empty
   section is a signal.
3. Re-read as the implementer: could you start without asking anything? If
   not, fix the spec, not the prompt.
4. Hand it over — a fresh session or subagent running `implement-task` with
   "work from `agent-work/<id>/spec.md`", the Copilot coding agent via an issue
   carrying the spec, or a colleague. Then read `report.md` **and** the diff,
   and run the verification yourself; a report saying green is not evidence.
