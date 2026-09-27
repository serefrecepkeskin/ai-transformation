---
name: ui-check
description: Full browser verification of a frontend against the repo's docs/screens.md — a matrix of screen × role/persona × viewport (× language) with evidence (screenshots, console, network, accessibility text) and a bug list. Run by the orchestrator before a release and after a large UI change; the per-change check is $verify-ui. A session without a browser only prepares the screen list and component tests. "Built" and "tests green" are not evidence; this produces it. Not for a single change (that is $verify-ui).
---

# ui-check

## Who runs it, with what

- **Orchestrator** with a browser — Claude in Chrome, VS Code's browser tools, or Playwright MCP (say which). A
  run without a browser lists the screens it touched and its tests and says "not browser-verified". A UI item is not done until `ui-check.md` covers
  every screen the change touches.
- Per repo — local stack, how to log in or reach a screen, roles, viewports, e2e floor: the repo's
  `AGENTS.md › Screens & design`, summarised for the workspace in `references/repos.md`. Chrome pitfalls:
  `references/chrome-notes.md`. Probe snippets: `../verify-ui/references/probes.md`.
- **Inventory = the repo's `docs/screens.md`** (route, gate, personas, what each state must show). The e2e sweep
  parses the same file, so a screen missing there is missing twice — add the row as part of the finding.

## Start from the automated sweep

Run the repo's e2e command once (per role where the repo supports it) and copy its result into the first rows of
`ui-check.md`. The browser pass then covers what the sweep cannot: interactions, states, gating, language,
visual sanity.

## Unit of work: one screen × one role × one viewport

The axes differ per repo (`repos.md`): an admin panel is screen × role × viewport; a public app is
screen × viewport × language; a flow is state × viewport. For every affected row (when in doubt: all):

1. **Reach, layout, a11y** — exactly `$verify-ui` §0–2 (reach through the UI, BUG-P1 when unreachable, the
   layout probes, the accessibility snapshot); wait for network idle; no raw i18n keys.
2. **Scroll & overflow** — covered by those probes; add the sidebar and any container the screen scrolls.
3. **States** — loading, empty, error (force a failing request when feasible), 403/404 — each has a designed
   state, never a blank area, an endless spinner or a raw error string.
4. **Interactions** — every button/link/tab/filter/sort/pagination does something visible; forms validate and
   submit; every dialog passes the residue probe.
5. **Console & network** — zero console errors; every non-2xx explained (a 403 is correct only where the role
   lacks the permission).
6. **Every language** — switch on the same screen; no untranslated text, no keys, localised dates/numbers.
7. **Gating** — per role: menu entry, direct URL (locked notice / 404 / hidden control as the repo designs it),
   controls and data match the role's scope.
8. **Visual sanity** — alignment, truncation, contrast, brand tokens, consistency with neighbouring screens.

Run the whole matrix again after fixes — a fix on one screen breaks another more often than not.

## Evidence and output (`agent-work/<branch-slug>/<repo>/` at the work root)

- `ui-check.md`: tool, roles, the e2e result, a **matrix** `screen × role → OK / BUG-n / N/A` with screenshot
  names, console/network findings, what could not be checked and why.
- `ui-bugs.md`: id, screen, role, viewport, steps, expected, actual, severity (P1 blocks a user's job, P2 wrong
  but workable, P3 cosmetic), screenshot. It is the input of the next fix spec (`$write-spec` → `$implement-task`).
- Screenshots in `shots/` as `<screen>-<role>-<state>.jpg`.
- Do not fix in this pass; do not soften findings; an unexplained console error is a bug.
