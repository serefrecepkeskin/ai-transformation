---
name: run-quality-gates
description: Runs the repo's quality gates — typecheck, lint, format check and the test suite — and reports pass/fail per gate. Use before every commit/PR, and after fixing findings to confirm green.
---

# Run the quality gates

Run each gate from the Commands section of AGENTS.md (PLACEHOLDER — after
bootstrap-research these are the repo's real scripts):

1. Typecheck (e.g. `npm run typecheck`)
2. Lint (e.g. `npm run lint`)
3. Format check (e.g. `npm run format:check`)
4. Unit/component tests (e.g. `npm run test`)
5. E2E, when the change touches a covered flow (e.g. `npm run test:e2e`)

## Rules

- Report the result per gate; on failure quote the failing output and **fix it**,
  then re-run that gate. Never report green without having seen it pass.
- Do not weaken a gate to pass it (no skipped tests, no lint-disable comments)
  without an explicit human decision — that would need an ADR.
