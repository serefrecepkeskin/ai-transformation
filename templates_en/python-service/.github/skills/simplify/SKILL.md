---
name: simplify
description: Reviews the changed code for reuse, simplification and dead weight, then applies the safe cleanups — quality only, it does not hunt for bugs (self-review does that). Use after the task works but before self-review/PR.
---

# Simplify the change

Scope: the current diff only (uncommitted changes, or `main..HEAD`). Never
"improve" code the task didn't touch (AGENTS.md: surgical changes).

## What to look for

- **Reinvention** — new code that an existing utility/component/helper in this
  repo already provides. Replace with the existing one.
- **Needless abstraction** — a layer/interface/option added for a future that
  isn't in the task. Inline it.
- **Dead weight** — unused imports/props/branches, commented-out code, debug
  leftovers, copy-paste blocks that should be one function.
- **Simpler equivalent** — the same behavior in fewer moving parts (early
  return over nesting, built-in over hand-rolled).

## Rules

1. Behavior must not change — this is a refactor pass, not a redesign. If a
   simplification would change behavior, skip it and note it instead.
2. Apply the safe fixes directly; list anything skipped and why.
3. Re-run `run-quality-gates` after applying — a simplification that breaks a
   test gets reverted, not patched around.
4. Then proceed to `self-review`. Mention notable simplifications in the PR
   description.
