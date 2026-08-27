# Testing

> **PLACEHOLDER** — run the `bootstrap-research` skill to fill the real runners
> and CI gates. The folder taxonomy below is the company standard; keep it.

## Test taxonomy (folders are the contract)

```
test/
├── unit/          # pure logic (utils, stores, composables) — no DOM, ms-fast
└── component/     # one component's behavior — render, interact, assert
e2e/               # Playwright — critical user flows in a real browser
├── *.spec.ts      #   flow tests; tag the fastest critical ones @smoke
├── *-snapshots/   #   visual regression baselines (committed)
└── a11y.spec.ts   #   axe accessibility gate per route
```

- **unit** — a function/store given inputs returns/mutates as specified.
- **component** — a component given props/interaction shows the right thing
  (loading/empty/error states included).
- **e2e** — a user completes a critical flow; `@smoke` subset runs post-deploy.
- **visual** — Playwright snapshots catch unintended UI regressions.
- **a11y** — axe must pass per route; any new color/control clears it.

## Which change writes which test

| Change                        | Minimum required test               |
| ----------------------------- | ----------------------------------- |
| New util/store logic          | unit                                |
| New/changed component         | component (+ visual if look-critical) |
| New page or flow step         | e2e (+ add to @smoke if critical)   |
| Bug fix                       | failing test first, in the lowest layer that reproduces it |
| New route                     | a11y gate covers it                 |

## Rules

- **Every task ships at least one test**; the PR maps acceptance criteria to
  tests ("criterion 2 → `test/component/UserList.spec.ts`").
- Bug fix → first a failing test that reproduces it, then the fix.
- Tests run **offline** — external calls are mocked/fixtured.
- UI changes additionally carry browser evidence (`verify-ui` skill) in the PR.
- No merge until the gates are green (see `run-quality-gates`).

## Commands & CI

TODO(confirm): real commands per layer and which workflow runs which gates on PRs.
