---
name: self-review
description: Local AI self-review before commit/push/PR — the code-reviewer agent audits the diff and returns findings ordered by severity. Always run before sending a change upstream.
---

# Self-review the diff

## Steps

1. Determine the diff to audit: uncommitted changes, or `main..HEAD` when the
   branch already has commits.
2. Run the **`code-reviewer`** custom agent (`.github/agents/code-reviewer.agent.md`)
   on that diff. For the review pass, prefer the strongest available model even
   if the change was drafted with a cheaper one.
3. Fix every **critical** and **medium** finding; note the rest in the PR
   description if left unfixed.
4. Re-run `run-quality-gates` after fixes.

## Note

- Findings the reviewer marks "possible" are verified before acting on —
  don't churn the diff on speculation.
