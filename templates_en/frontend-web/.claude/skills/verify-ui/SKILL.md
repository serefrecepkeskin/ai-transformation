---
name: verify-ui
description: Proves a UI change works by looking at it in a real browser — screenshot, console errors, accessibility snapshot, responsive check. Use after any component/page/style change, before claiming it works, and whenever a bug is reported against a screen.
---

# Verify a UI change in the browser

> "Built" is not evidence. This skill produces the evidence.

## 1. Pick the browser tool this runtime has

In order of preference — use the first one available, and **say which one you
used**:

1. **VS Code's built-in browser tools** (Copilot agent mode, VS Code 1.127+):
   opens the page, reads content and console errors, screenshots, clicks and
   types. No MCP server needed.
2. **Claude in Chrome** (Claude Code with the Chrome extension): drives the
   real browser with the real session — best when the screen needs a logged-in
   user.
3. **Playwright MCP** (`.mcp.json` / `.vscode/mcp.json`): a clean, scriptable
   browser; also the one to use when the flow should end up as an e2e test.

None of them available? Say so plainly and fall back to component tests — do
**not** claim the UI was verified.

## 2. Run the app and reach the screen

Start the dev server (see AGENTS.md Commands), open the route the change
touches, and drive it to the state that matters — not just the empty page.
Log in / seed the data if the screen needs it.

## 3. Capture the evidence

- **Screenshot** of the changed area, at desktop **and** at a narrow width.
- **Console** — zero errors. A new warning gets explained or fixed.
- **Accessibility** — the a11y snapshot/tree: names on interactive elements,
  labels on inputs, sensible heading order, visible focus.
- **The acceptance target itself** — click through what the task actually asked
  for and describe what happened.

## 4. Report

State: which tool, which route/state, what you saw, and anything still broken.
A screenshot of the wrong state is not evidence — say when you could not reach
the real one.

## Rules

- Console errors are failures, not noise.
- Verify the state the user reaches, not the mock you happened to render.
- Design quality is a separate question — that is `impeccable`, not this skill.
