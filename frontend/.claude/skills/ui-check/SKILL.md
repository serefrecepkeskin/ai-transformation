---
name: ui-check
description: Screen-by-screen, role-by-role browser verification of the whole app against the inventory in docs/screens.md — a matrix of screen × role × viewport with evidence (screenshots, console, network, accessibility) and a bug list. Run with a real browser before every release and after every large UI change; a per-change smoke is verify-ui, this is the full pass. "Built" and "tests green" are not evidence; this produces it.
---

# UI check — the full matrix

## Who runs it, with what

- A session **with a browser** (VS Code browser tools, Claude in Chrome, or
  Playwright MCP — same order and rules as `verify-ui`). A session without one
  may only prepare the screen list and component tests and must say "not
  browser-verified".
- Local stack, test users and their roles: PLACEHOLDER — after the bootstrap
  prompt, AGENTS.md → Commands names how to run the app, and
  `docs/screens.md` lists the personas. Credentials live outside the repo;
  never paste them into reports.
- Tool pitfalls: `../verify-ui/references/chrome-notes.md`. Probe snippets:
  `../verify-ui/references/probes.md`.

## Start from the automated sweep

`npm run test:e2e` covers the floor of the matrix (load, expected text,
console, network, overlap, overflow, scroll — every walkable route, two
widths) for the persona in `E2E_EMAIL`. Run it per role you can log in as;
its report and screenshots are the first rows of `ui-check.md`. The manual
pass below adds what a script cannot judge.

## Unit of work: one screen × one role × one viewport

The pass is a matrix, not a tour. For every screen in `docs/screens.md` that
the change can affect (when in doubt: all of them), for every role that can
reach it, at desktop (≥ 1440 px) and once at narrow (≤ 768 px) width:

1. **Reach & load** — through the UI from the login page (menu → page →
   tab/button/row); record the click path. A screen you cannot reach by
   clicking is a critical bug even if its URL works. Direct URL is a separate
   step used only to prove gating (locked notice / 404) for roles that must not
   reach it. Wait for network idle; read the accessibility tree. Title,
   headings, primary controls present; no raw i18n keys.
2. **Scroll & overflow** — the Scroll and Overflow probes; footer reachable;
   nothing clipped; sidebar stays put; no horizontal scrollbar; tables scroll
   inside their container.
3. **States** — loading, empty, error (force a failing request when feasible),
   403/404 — each has a designed state, never a blank area, an endless spinner
   or a raw error string.
4. **Interactions** — every button/link/tab/filter/sort/pagination does
   something visible; forms validate and submit; modals/drawers open, close by
   button, Escape and backdrop, and **after closing the page scrolls again**.
5. **Console & network** — zero console errors; warnings listed; every non-2xx
   request explained (a 403 is correct only where the role lacks the permission
   per `docs/screens.md`).
6. **Languages** — switch locales on the same screen; no untranslated text, no
   keys, dates/numbers localised; switch back.
7. **Gating** — per role: menu item present/absent, direct URL lands on the
   page or the locked notice, action controls present/absent match the
   inventory, data matches the role's scope.
8. **Visual sanity** — alignment, spacing, truncation, contrast, badge text
   fits, icons render, design tokens (`docs/DESIGN.md`); compare with
   neighbouring screens for consistency.

Run the whole matrix again after fixes — a fix on one screen breaks another
more often than not.

## Evidence and output

- `agent-work/<id>/ui-check.md`: tool used; users/roles; a **matrix table**
  `screen × role → OK / BUG-n / N/A` with screenshot filenames per cell;
  console/network findings; what could not be checked and why.
- `agent-work/<id>/ui-bugs.md`: one row per bug — id, screen, role, viewport,
  steps, expected, actual, severity (critical blocks a role's job, medium wrong
  or ugly but workable, minor cosmetic), screenshot. This file is the input of
  the next fix (`write-spec` → `implement-task`), one screen group per spec.
- Screenshots in `agent-work/<id>/shots/` named `<screen>-<role>-<state>.png`.
- Do not fix in this pass; do not soften findings; a screen with an
  unexplained console error is a bug.
