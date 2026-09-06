---
name: verify-ui
description: Proves a UI change works by looking at it in a real browser — reach the screen through the UI (no deep links), then screenshot, console, accessibility snapshot, layout probes (overlap, overflow, scroll, modal residue), and the changed function end to end. Mandatory after any component, page, layout, route, menu, i18n or style change, before claiming it works, and whenever a bug is reported against a screen. Writes agent-work/<id>/ui-smoke.md.
---

# Verify a UI change in the browser

> "Built" and "tests green" are not evidence. This skill produces the evidence.

## 0. Run the automated floor first

`npm run test:e2e` (Playwright, `e2e/smoke.spec.ts`) walks every route in
`docs/screens.md` at desktop and mobile width and runs the layout probes,
console and network checks without an agent browser. Read its output: a red
probe is a finding before you have opened anything. What it cannot do —
interactions, modals, gating per role, both languages — is yours below.

## 1. Pick the browser tool this runtime has

In order of preference — use the first one available, and **say which one you
used**:

1. **VS Code's built-in browser tools** (Copilot agent mode, VS Code 1.127+):
   opens the page, reads content and console errors, screenshots, clicks, types.
2. **Claude in Chrome** (Claude Code with the Chrome extension): the real
   browser with the real session — best when the screen needs a logged-in user.
   Pitfalls: `references/chrome-notes.md`.
3. **Playwright MCP** (`.mcp.json` / `.vscode/mcp.json`): clean and scriptable;
   also the one to use when the flow should end up as an e2e test.

None available? Say so plainly and fall back to component tests — write
"browser smoke pending" in the report; do **not** claim the UI was verified.

## 2. Reach the screen through the UI — never by typing the URL

Start the dev server (AGENTS.md → Commands), log in as the role the change
concerns, and get to the target screen the way a user would: menu → page →
tab/button/row → modal. Record the click path. A screen that cannot be reached
by clicking is a **bug (critical)** even if its URL works. Direct URLs are used
only afterwards, as a separate step, to prove gating (locked notice / 404) for
roles that must not reach it. Drive the screen to the state that matters — not
the empty page; seed data if needed.

## 3. Layout probes — desktop and ≤ 768 px

Run the snippets in `references/probes.md` with the page-script tool:

- **Overlap / clickability** — every visible interactive element is hit by
  `elementFromPoint` at its centre; then actually click the primary controls
  and confirm a visible reaction.
- **Overflow / clipping** — no horizontal scrollbar; no text clipped by an
  `overflow:hidden` ancestor unless it is a designed ellipsis; long values wrap;
  wide tables scroll inside their own container.
- **Scroll** — wheel over the main content moves the page (or the intended
  container) and the footer is reachable; sticky headers stay; the sidebar does
  not drag the page.
- **Modal / drawer residue** — open and close each one the change touches
  (button, Escape, backdrop); afterwards no body scroll lock, no leftover
  backdrop, the page scrolls again.
- **Z-order** — toasts, dropdowns, date pickers, drawers render above content.

## 4. Function, console, accessibility, language

- **The acceptance target itself**, end to end: enter data, submit, observe the
  visible result **and** the network call (method, URL, status); cover the
  negative path the task mentions (validation error, 403/404, empty result).
  "The component renders" is not a pass.
- **Console** — zero errors; every warning explained or fixed; every non-2xx
  request explained.
- **Accessibility** snapshot — names on interactive elements, labels on inputs,
  sensible heading order, visible focus.
- **Languages** — if any string changed: every locale on that screen, no raw
  keys, no truncated labels in the longer language.

## 5. Report

`agent-work/<id>/ui-smoke.md`: tool used, role, click path, viewports, probe
results per screen, screenshots (`agent-work/<id>/shots/<screen>-<state>.png`),
console + network summary, what could not be checked and why. Bugs go one row
each into `agent-work/<id>/ui-bugs.md` (screen, role, viewport, steps,
expected, actual, severity, screenshot); a critical bug sends the item back to
`implement-task`, and the smoke is repeated after the fix.

## Rules

- Console errors are failures, not noise.
- Verify the state the user reaches, not the mock you happened to render.
- Do not soften findings; a screenshot of the wrong state is not evidence.
- Design quality is a separate question — that is `impeccable`, not this skill.
- The full screen × role × viewport matrix before a release is `ui-check`.
