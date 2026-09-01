---
name: run-quality-gates
description: Runs the repo's quality gates — typecheck, lint, format check and the test suite — and reports pass/fail per gate with the real output. Use before every commit/PR, and again after fixing findings to confirm green.
---

# Run the quality gates

> **Iron law: no green claim without fresh output.** If you did not run the
> command in this session and read what it printed, you cannot say it passes.

Gate 0 is `pre-commit run --all-files` when the repo has a
`.pre-commit-config.yaml`. It is the cheapest gate and the one CI will run
anyway. Some of its hooks fix files in place (`ruff --fix`, `eslint --fix`) and
then report failure — that is a pass in two steps: read what changed, keep the
fix if it is right, and run the hook again until it is clean. Never `--no-verify`
a commit; a hook that is wrong is a decision (`record-decision`), not a flag.

Run each gate from the Commands section of AGENTS.md (PLACEHOLDER — after the
bootstrap prompt these are the repo's real scripts):

1. Typecheck (e.g. `npm run typecheck`)
2. Lint (e.g. `npm run lint`)
3. Format check (e.g. `npm run format:check`)
4. Unit/component tests (e.g. `npm run test`)
5. E2E, when the change touches a covered flow (e.g. `npm run test:e2e`)

## The gate function

For each gate: run the **full** command → read the whole output → check the
exit code → report `gate: pass/fail` with the number that proves it
("42 passed", "0 errors"). On failure, quote the failing lines, fix the cause,
and re-run **that gate** before moving on.

## Rules

- Never report green without having seen it pass in this session.
- Never weaken a gate to make it pass — no `eslint-disable` sprinkled to get
  through, no `any` to silence the typechecker, no skipped test. A gate that is
  wrong is a decision (`record-decision`), not a config edit.
- A partial run proves nothing: no single-file lint standing in for the suite,
  unless you say explicitly that is what you ran.
- Report per gate, not one summary line.

## Rationalizations

| Excuse | Reality |
|---|---|
| "Lint passed, so it compiles" | Lint is not the typechecker. Run both. |
| "Only touched one component" | Tests catch what the diff does not show. |
| "It passed before my last edit" | The last edit is exactly what is unverified. |
| "Failure looks unrelated" | Then say so with the output — do not skip it. |
