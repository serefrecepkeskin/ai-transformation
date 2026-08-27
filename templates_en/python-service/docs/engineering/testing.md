# Testing

> **PLACEHOLDER** — run the `bootstrap-research` skill to fill the real runners
> and CI gates. The folder taxonomy below is the company standard; keep it.

## Test taxonomy (folders are the contract)

```
tests/
├── unit/          # pure logic (services, mappers, validators) — no I/O, ms-fast
├── integration/   # endpoint + DB — real HTTP call against the app, fixtures/test containers
├── contract/      # API schema vs consumers — response shapes stay compatible
└── smoke/         # a handful of fast end-to-end checks — health + one critical path
```

- **unit** — a function given inputs returns/raises as specified; no network,
  no database, no filesystem.
- **integration** — the endpoint wired through routing/validation/DB behaves
  as specified, including error responses.
- **contract** — the documented response/request shapes don't silently break
  consumers (schema assertions; grows into consumer-driven contracts if needed).
- **smoke** — cheap enough to run after every deploy: `/health` + one critical
  business path against the running service.

## Which change writes which test

| Change                     | Minimum required test                          |
| -------------------------- | ---------------------------------------------- |
| New service/domain logic   | unit                                           |
| New/changed endpoint       | integration (happy + at least one error case)  |
| Response shape change      | contract                                       |
| Bug fix                    | failing test first, in the lowest layer that reproduces it |
| New critical flow          | add to smoke                                   |

## Rules

- **Every task ships at least one test**; the PR maps acceptance criteria to
  tests ("criterion 2 → `tests/integration/test_orders_api.py`").
- Bug fix → first a failing test that reproduces it, then the fix.
- Tests run **offline** — external services are faked/fixtured; no test may
  depend on network access.
- No merge until the gates are green (see `run-quality-gates`).

## Commands & CI

TODO(confirm): real commands per layer and which workflow runs which gates on PRs.
