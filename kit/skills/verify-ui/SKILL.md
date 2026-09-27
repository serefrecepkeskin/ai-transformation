---
name: verify-ui
description: Mandatory browser smoke after ANY UI component, page, layout, route, menu, i18n or style change in a frontend — reach the screen through the UI (no deep links), then prove no overlap, no overflow/clipping, everything clickable, page and containers scroll, dialogs leave no residue, the accessibility tree is sane, and the added/changed function works end to end. Run by the orchestrator with a browser before the item is called done; produces ui-smoke.md and bug rows. The answer to "ekranı kontrol et" after a change.
---

# verify-ui

A session without a browser cannot run this: its report says "browser smoke pending" and the orchestrator runs
the smoke on the local stack before marking the item done. How to reach each app, its viewports and its e2e floor:
the repo's `AGENTS.md › Screens & design` (and `../ui-check/references/repos.md` in a workspace). Tool pitfalls:
`../ui-check/references/chrome-notes.md`.

## 0. Tool, floor, reach

- **Tool:** Claude in Chrome first (VS Code's built-in browser tools under Copilot); Playwright MCP (`.mcp.json`)
  when neither is available. Write which one you
  used. No browser at all → write "browser smoke pending" and stop; never claim a screen was verified.
- **Floor:** when the repo has an e2e sweep, run it first (command and prerequisites in `AGENTS.md › Screens & design`) and read the
  output — a red probe there is a finding here too.
- **Reach through the UI, never by typing the URL.** Start where a user starts (the login page as the role the change
  concerns, or the public entry link) and click to the target: menu → page → tab/button/row → dialog. Record the
  click path (`Dashboard → Orders → #1042 → Refund`). A screen that cannot be reached by clicking is **BUG-P1 (unreachable)** even if its URL works.
  Direct URLs come afterwards, only to prove gating for roles that must not reach the screen.
- Drive the screen into the state the change is about — seed or create the data if needed (a table with rows, a
  long name, an empty result). An empty screen proves nothing about a row renderer.

## 1. Layout probes — every touched screen, at the repo's viewports (`AGENTS.md › Screens & design`)

Narrow widths are measured in a **same-origin iframe** (snippet in `references/probes.md`), not with
`resize_window`. Run the snippets in `references/probes.md`:

- **Overlap / clickability** — every visible interactive element is the `elementFromPoint` of its own centre.
  Then click the primary controls and confirm a visible reaction.
- **Overflow / clipping** — no horizontal page scroll; no text clipped by an `overflow:hidden` ancestor unless it
  is a designed ellipsis; long values wrap; wide tables scroll inside their own container.
- **Scroll** — wheel over the main content moves the page (or the scroll container) and the end is reachable;
  the sidebar does not drag the page; sticky headers stay.
- **Dialog / drawer residue** — open and close every dialog the change touches (button, Escape, backdrop where
  the repo allows it); afterwards body scroll is unlocked and no overlay node remains.
- **Z-order** — toasts, dropdowns, pickers and drawers render above content and are not cut off.

## 2. Accessibility snapshot

`read_page` on the touched screen: every interactive element has a name; inputs have labels; headings go in
order; focus is visible when tabbing; a dialog traps focus and returns it on close. Icon-only buttons need a
translated label.

## 3. Function — the reason for the change

Do what the user would do: enter data, submit, observe the visible result **and** the request (method, URL,
status). Cover the negative path the spec names (validation error, 403/404/409, empty result). "It renders" is
not a pass; the outcome must be on screen and agree with the backend (reload or read the response).

## 4. Language

If any string changed: every language on that screen, no raw keys, no labels truncated in the longer language.

## Output

- `agent-work/<branch-slug>/<repo>/ui-smoke.md` at the work root: tool, role/persona, click path, viewports, per screen the results of
  overlap / overflow / scroll / residue / z-order / a11y / function, console + network summary, screenshots in
  `shots/`, and what could not be checked and why.
- Bugs appended to `ui-bugs.md` (columns as in `$ui-check`). A BUG-P1 sends the item back to
  `$implement-task`; repeat the smoke after the fix.
