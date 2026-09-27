# <repo> — Agent Guide

<!-- PLACEHOLDER — the bootstrap prompt fills every section from files it actually read; what it cannot verify
     becomes TODO(confirm). One paragraph here: what this app is, who uses it, on which devices, which backend it
     talks to, stack in one line. Keep the whole file ≤ ~12 KB (it loads on every request) and REPO-SPECIFIC ONLY.
     Rules that hold in every repo (engineering principles, test discipline, language, secrets, commit format)
     live in the platform guide / principles and must not be repeated here. Point into docs/ from the section a
     pointer belongs to. The H2 headings below are fixed: same names, same order in every frontend —
     scripts/link-repo.sh --check compares them with this file. -->

{{PLATFORM_LINE}}

## Stack & run
<!-- Framework (JSX or TS), UI kit, data libraries, i18n (locale folders + key style); dev command + port; the
     backend(s) it calls; which env file is read and what must be in it (names only); README pointer. -->

## Where code goes
<!-- Directory → responsibility, one line each (long form: docs/engineering/architecture.md). End with an
     "Adding:" sub-list: new screen (file, route, menu entry, docs/screens.md row, every locale), new API call,
     new component (placement, naming, co-located test, which primitives to build it from). -->

## Reuse before writing new
<!-- The 8–10 components/helpers an agent would otherwise rebuild, and why each is the single source. -->

## Conventions
<!-- File naming; design tokens (no raw hex) and the brand source; i18n (every locale, key style, the test that
     guards runtime keys); fixed terminology; single-source lists (menu, routes, query keys) and the test pinning
     each. -->

## Security & gotchas
<!-- Rules written from real incidents in THIS repo: where the session token lives and travels, URL sanitising,
     no raw HTML injection, public build-time env vars (VITE_* / NEXT_PUBLIC_*), CSP/origin changes, cookies, PII
     masking, load-bearing code paths. ### allowed. -->

## Screens & design
<!-- docs/screens.md is the screen inventory: it drives $ui-check and the e2e sweep (e2e/screens.ts).
     docs/DESIGN.md + the brand source; viewports and breakpoints; how a tester reaches a screen (login / roles —
     where test credentials live, never in reports); the e2e sweep (command, prerequisites, what it cannot cover). -->

## Tests
<!-- Where tests live, runner + helpers, what gets a test, what to mock and what never to mock, guard tests. A repo
     with no tests says so and names what proves a change instead (gates + $verify-ui). -->

## Workflow
<!-- Exactly this shape:
- Gates (all must pass before a commit): `<one npm line>`; commit hook: `<husky + lint-staged | pre-commit>`; e2e
  per "Screens & design" before every push/PR.
- New public env variable → `<.env.example | README env table>`; anything public ships in the bundle.
- Settled library/pattern/rule → an ADR in docs/decisions/ in the same PR.
- Kit: skills `.claude/skills/` (+ `impeccable`), reviewers `.claude/agents/`, hooks `.claude/hooks` come from the
  agent kit (`link-repo.sh` wires them, `--check` / `check-drift.sh` verifies). A UI change is not done until
  `$verify-ui` ran. Before handing over: cold review with `frontend-reviewer` (+ `security-reviewer` for
  auth/session/URLs from data/PII/dependencies). Commit/PR: `$commit-and-pr`.
-->
