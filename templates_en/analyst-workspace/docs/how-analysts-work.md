# How Analysts Work Now

The old way: a paragraph of intent in a ticket, field names from memory,
requirements clarified over weeks of meetings while developers wait. That
doesn't survive AI-driven development — an agent amplifies whatever it is
given, including vagueness.

## The new contract

**An analyst delivers a ready task, not an idea.** "Ready" is defined by the
task template: measurable acceptance criteria, DoD, how-to-test, verified data
sources. The `refine-task` skill is the gate; a task that fails it doesn't ship.

## The loop

1. **Research first.** Use `db-research` to verify every table/column the task
   will reference. Evidence with dates, not recollection.
2. **Draft with the agent.** Run `create-task` — the agent drafts from the
   template and asks for what it cannot know (priorities, business intent,
   deadlines). Answer; don't let it guess.
3. **Refine.** Run `refine-task`. Fix every finding: unmeasurable criteria,
   missing test steps, unverified assumptions.
4. **Deliver.** Commit the task file; hand the ID to the developer team.
5. **Stay in the loop.** Developer questions land back with the author —
   answer them by **updating the task file**, so the answer is permanent.

## Principles

- **Measurable or it doesn't count.** "The list should be fast" → "the list
  renders under 2s with 1,000 rows".
- **Small tasks flow, big tasks stall.** One deliverable per task; split
  anything whose criteria don't fit on a screen.
- **Assumptions are labeled.** Unconfirmed rules go to "Open questions" with
  an owner and a date — never stated as fact.
- **Speed comes from completeness.** Every missing field becomes a round-trip
  to you later. The slow part was never the writing; it was the back-and-forth.
- **Protect the data.** Read-only access, no PII in any artifact (AGENTS.md
  rules #1-2).
