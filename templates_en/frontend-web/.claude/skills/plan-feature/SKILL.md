---
name: plan-feature
description: Plans work that is too big for one session — writes a plan file with bite-sized, independently testable tasks, then drives the execute-verify loop task by task. Use before touching code when a feature spans several sessions, several subsystems, or more than a handful of files, or whenever the user asks for a plan.
---

# Plan a feature

Heavy work is planned once, in writing, then executed in small pieces with a
fresh review after each. The plan is the memory; the session is disposable.

## 1. Understand before planning

Ask what is genuinely unclear — the goal, the constraints, what is explicitly
out of scope. Do not plan around a guess. Read the code the feature touches
and note the real files it will need.

## 2. Write the plan

`.ai/plans/YYYY-MM-DD-<kebab-slug>.md`:

```markdown
# <Feature> — plan

**Goal:** one sentence; what "done" means, measurably.
**Out of scope:** what this explicitly does not do.
**Constraints:** versions, contracts, rules copied verbatim from the source.
**Files:** each file to create or change, one line on its responsibility.

## Task 1 — <deliverable>
- [ ] steps, 2-5 minutes each, in order
- [ ] the test that proves it, written first
- [ ] verification: the exact command to run, and what output means pass
```

Task sizing: a task is the smallest unit that carries its own test and could be
rejected on its own. Fold setup and docs into the task that needs them. Every
task ends with something runnable — never "part 1 of a refactor".

## 3. Execute, one task at a time

For each task: implement → run its verification → run `run-quality-gates` →
`self-review` → commit. Then tick the boxes in the plan and update
[.ai/STATE.md](../../../.ai/STATE.md) before starting the next one.

Hand heavy, self-contained work (a broad audit, a large mechanical change) to a
subagent with the task text and the plan's constraints — not your session
history. Then check its diff yourself; an agent reporting success is not
evidence.

## 4. Verify the feature, not just the tasks

Before shipping, walk the goal from step 2 end to end as a user would, and
report what you observed. Green tasks with a broken feature is the failure this
step exists to catch.

## Stop and ask when

- A task turns out to need a decision nobody made (record it as an ADR).
- The plan no longer matches reality — update the plan first, then continue.
