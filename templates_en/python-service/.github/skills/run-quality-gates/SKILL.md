---
name: run-quality-gates
description: Runs the repo's quality gates — lint, type check and the test suite — and reports pass/fail per gate. Use before every commit/PR, and after fixing findings to confirm green.
---

# Run the quality gates

Run each gate from the Commands section of AGENTS.md (PLACEHOLDER — after
bootstrap-research these are the repo's real commands):

1. Lint (e.g. `ruff check .`)
2. Format check (e.g. `ruff format --check .`)
3. Type check (e.g. `mypy .`)
4. Tests (e.g. `pytest`)

## Rules

- Report the result per gate; on failure quote the failing output and **fix it**,
  then re-run that gate. Never report green without having seen it pass.
- Do not weaken a gate to pass it (no skipped tests, no `# type: ignore` /
  `# noqa` sprinkling) without an explicit human decision — that would need an ADR.
