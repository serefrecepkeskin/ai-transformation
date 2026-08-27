---
name: run-quality-gates
description: Runs the repo's quality gates — build (warnings as errors), format check and the test suite — and reports pass/fail per gate. Use before every commit/PR, and after fixing findings to confirm green.
---

# Run the quality gates

Run each gate from the Commands section of AGENTS.md (PLACEHOLDER — after
bootstrap-research these are the repo's real commands):

1. Build (e.g. `dotnet build -warnaserror`)
2. Format check (e.g. `dotnet format --verify-no-changes`)
3. Tests (e.g. `dotnet test`)
4. Analyzers, if configured separately (TODO(confirm))

## Rules

- Report the result per gate; on failure quote the failing output and **fix it**,
  then re-run that gate. Never report green without having seen it pass.
- Do not weaken a gate to pass it (no skipped tests, no `#pragma warning
  disable`, no `!` to silence nullability) without an explicit human decision —
  that would need an ADR.
