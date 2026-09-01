---
name: self-review
description: Reviews the diff before commit/push/PR — dispatches the code-reviewer agent for correctness and a second pass for unnecessary complexity, then returns findings by severity. Always run before sending a change upstream.
---

# Self-review the diff

## 1. Scope the diff

Uncommitted changes, or `main..HEAD` when the branch already has commits.

## 2. Correctness pass

Run the **`code-reviewer`** agent (`.claude/agents/code-reviewer.md`, or
`.github/agents/code-reviewer.agent.md` on Copilot) on that diff.

Hand it the diff and the task's goal — **not this session's history**. The
reviewer's value comes from reading the change cold; your narration of why the
code is right is exactly the bias to keep out. For the review pass prefer the
strongest available model even if the change was drafted with a cheaper one.

## 3. Complexity pass

Then read the diff once more, hunting only for what can be deleted. One line
per finding: location, what to cut, what replaces it.

- `delete:` dead code, unused flexibility, speculative feature.
- `stdlib:` hand-rolled thing the standard library ships — name the function.
- `reuse:` something this repo already has — name the file.
- `yagni:` abstraction with one implementation, config nobody sets.
- `shrink:` same logic, fewer lines — show the shorter form.

End with `net: -N lines possible`, or `Lean already.` if there is nothing.

## 4. Act

Fix every **critical** and **medium** finding. Note the rest in the PR
description if left unfixed. Then re-run `run-quality-gates` — a fix is a
change like any other.

## Rules

- Disagreeing with a finding is allowed; ignoring it silently is not. Say why,
  with the code or test that proves it.
- Never skip because "it's a small change" — small diffs carry most regressions.
