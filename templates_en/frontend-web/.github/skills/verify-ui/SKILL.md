---
name: verify-ui
description: Verifies a UI change in a real browser via the dev server and the Playwright MCP server — screenshot, console errors, accessibility snapshot, computed styles. Use after any component/page/style change to prove it works instead of saying "built/written".
---

# Verify a UI change in the browser

> Requires the Playwright MCP server (`.vscode/mcp.json`). If it is not
> available, say so and fall back to component tests — do not claim the UI
> was verified.

## Steps

1. Start the dev server (see the Commands section of AGENTS.md) if not running.
2. Navigate to the changed page/state with the Playwright MCP browser tools.
3. Collect evidence:
   - **Screenshot** of the changed UI (and its loading/error states if relevant).
   - **Console** — zero new errors/warnings caused by the change.
   - **Accessibility snapshot** — the changed elements expose sensible
     roles/names; interactive elements are reachable.
   - For visual/style tasks: check the computed style of the key element(s)
     against the task's expectation.
4. Exercise the interaction the task is about (click, type, submit) and confirm
   the acceptance criteria visibly hold.

## Notes

- Verify every locale/theme variant the change touches.
- Paste the evidence summary (what was checked, what was seen) into the PR
  description — that is the reviewer's proof.
