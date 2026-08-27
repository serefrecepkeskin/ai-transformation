# Testing

> **PLACEHOLDER** — run the `bootstrap-research` skill to fill the real
> frameworks and CI gates. The folder taxonomy below is the company standard.

## Test taxonomy (folders are the contract)

```
tests/
├── Unit/           # pure logic (services, mappers, validators) — no I/O, ms-fast
├── Integration/    # WebApplicationFactory + real DB container — endpoint through the pipeline
├── Architecture/   # dependency rules — e.g. Domain must not reference Infrastructure
└── Smoke/          # a handful of fast end-to-end checks — health + one critical path
```

- **Unit** — a class/method given inputs returns/throws as specified; no
  network, no database.
- **Integration** — the endpoint wired through routing/validation/EF behaves
  as specified (Testcontainers or equivalent for a real DB), including error
  responses (ProblemDetails shape).
- **Architecture** — project-boundary rules asserted as tests (NetArchTest or
  similar), so a forbidden reference fails the build, not a review.
- **Smoke** — cheap enough to run after every deploy: `/health` + one critical
  business path against the running service.

## Which change writes which test

| Change                     | Minimum required test                          |
| -------------------------- | ---------------------------------------------- |
| New service/domain logic   | Unit                                           |
| New/changed endpoint       | Integration (happy + at least one error case)  |
| New project/layer boundary | Architecture rule                              |
| Bug fix                    | failing test first, in the lowest layer that reproduces it |
| New critical flow          | add to Smoke                                   |

## Rules

- **Every task ships at least one test**; the PR maps acceptance criteria to
  tests ("criterion 2 → `tests/Integration/OrdersApiTests.cs`").
- Bug fix → first a failing test that reproduces it, then the fix.
- Tests run **offline** — external services are faked; containers are local.
- No merge until the gates are green (see `run-quality-gates`).

## Commands & CI

TODO(confirm): real commands per layer and which workflow runs which gates on PRs.
