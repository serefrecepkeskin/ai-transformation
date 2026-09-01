---
name: debug-issue
description: Systematic root-cause investigation for a bug, test failure, crash or unexpected behavior. Use before proposing or applying any fix, especially under time pressure or when a previous fix did not hold.
---

# Debug an issue

> **Iron law: no fix without a root cause.** A fix applied to a symptom is not
> a fix; it moves the bug. If you have not completed step 2, you may not edit
> code.

## 1. Reproduce

Name the exact trigger and run it. Read the whole error and the whole stack
trace — the answer is often already in it. Not reproducible? Gather data
(logs, inputs, environment differences); do not guess.

## 2. Find where the bad value is born

- **Check recent changes** — `git log`/`git diff` on the files involved.
- **Trace backwards.** The line that raised the error usually received bad
  input. Who passed it? Keep walking up until you reach the place that created
  the value. That place is the root cause.
- **Multi-component flow?** (request → service → repository → DB, job → queue →
  worker.) Add temporary logging at each boundary — what enters, what leaves —
  run once, and let the evidence say which hop breaks. Delete the
  instrumentation afterwards.

## 3. State the cause before fixing

One sentence: "X happens because Y produces Z when W". If you cannot write
that sentence, you have not found it yet — keep going or say what is still
unknown.

## 4. Fix at the source, with a regression test

Write a test that reproduces the bug, **run it, see it fail**, then fix. Fix
where all callers route through, not in the one path the report mentioned —
grep for the other callers and confirm they were broken the same way.

## 5. Verify

Re-run the failing test, then the full gate set (`run-quality-gates`). Report
the cause, the fix and the evidence.

## Red flags — stop

- "Let me just try changing this and see."
- Adding a null check where the null is not supposed to exist.
- Two fixes attempted without an explanation of the first one's failure.
- Widening an exception handler to make an error disappear.
