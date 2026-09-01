---
name: create-task
description: Authors a development task.md from the company template — context, scope, measurable acceptance criteria, DoD, how-to-test, verified data sources. Use when the analyst wants to turn a business need into a deliverable task. Asks for what it cannot know; never invents requirements or field names.
---

# Create a task

Output: `tasks/<ID>-<kebab-title>.md` following
[task-template.md](../../../docs/task-template.md) exactly.

## Steps

1. **Understand the need.** From the analyst's description, restate the problem
   in one paragraph and confirm it. Ask for: target repo, priority, deadline
   context — never guess these.
2. **Verify the data.** For every table/column the task will touch, run the
   `db-research` skill. A data reference without a "verified on" date does not
   go into the task. Check [db-catalog.md](../../../docs/db-catalog.md) first
   to avoid re-research.
3. **Draft.** Fill every required template section:
   - Acceptance criteria: measurable, given/when/then where possible. Turn
     every vague wish ("fast", "user friendly") into a number or an observable.
   - Scope: write the **Out** list — what this task deliberately excludes.
   - How to test: steps a developer agent can execute verbatim.
   - DoD: start from [definition-of-done.md](../../../docs/definition-of-done.md),
     add task-specific items.
4. **Label the unknowns.** Anything the analyst couldn't confirm goes to
   "Open questions" with an owner — not into the body as fact.
5. **Gate.** Run the `refine-task` skill on the draft and fix its findings
   before presenting the task as ready.

## Rules

- No PII or real customer values anywhere in the task (AGENTS.md rule #2).
- One deliverable per task; propose a split when criteria overflow a screen.
