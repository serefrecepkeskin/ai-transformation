---
name: run-quality-gates
description: Runs the repo's quality gates — lint, type check and the test suite — and reports pass/fail per gate with the real output. Use before every commit/PR, and again after fixing findings to confirm green.
---

# Run the quality gates

> **Iron law: no green claim without fresh output.** If you did not run the
> command in this session and read what it printed, you cannot say it passes.

Run each gate from the Commands section of AGENTS.md (PLACEHOLDER — after the
bootstrap prompt these are the repo's real commands):

1. Lint (e.g. `ruff check .`)
2. Format check (e.g. `ruff format --check .`)
3. Type check, if the repo has one (e.g. `mypy .`)
4. Tests (e.g. `pytest`)

## The gate function

For each gate: run the **full** command → read the whole output → check the
exit code → report `gate: pass/fail` with the number that proves it
("42 passed", "0 errors"). On failure, quote the failing lines, fix the cause,
and re-run **that gate** before moving on.

## Rules

- Never report green without having seen it pass in this session.
- Never weaken a gate to make it pass — no blanket `# noqa`, no skipped test,
  no loosened config. A gate that is wrong is a decision
  (`record-decision`), not a config edit.
- A partial run proves nothing: no `-x`, no single-file lint standing in for
  the suite, unless you say explicitly that is what you ran.
- Report per gate, not one summary line.

## Rationalizations

| Excuse | Reality |
|---|---|
| "Lint passed, so it runs" | Different tool, different failure. Run both. |
| "Only touched one file" | Tests catch what the diff does not show. |
| "It passed before my last edit" | The last edit is exactly what is unverified. |
| "Failure looks unrelated" | Then say so with the output — do not skip it. |
