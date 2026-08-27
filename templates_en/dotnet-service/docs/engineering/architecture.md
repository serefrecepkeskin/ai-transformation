# Architecture

> **PLACEHOLDER** — run the `bootstrap-research` skill to fill this from the
> real codebase. Keep it short; when an architectural decision changes, update
> this file and write an ADR in the same PR.

## Service shape

TODO(confirm): API service / worker / batch — .NET version, hosting model,
how it is deployed and scaled.

## Solution structure

```
TODO: real project tree (API / Domain / Infrastructure / Tests) with
one-line notes and the allowed dependency directions
```

## Layers

- **API** — TODO: controllers or minimal APIs, DTO mapping, middleware pipeline
- **Domain / services** — TODO
- **Data access** — TODO: EF Core DbContexts, lifetime, repository pattern or not
- **Config & secrets** — TODO: options pattern, environment/secret sources
- **Background work** — TODO: hosted services/queues, if any

## External integrations

TODO: upstream/downstream systems, contracts, failure behavior.

## Deployment & release

TODO(confirm): branch model, CI gates, how a merge becomes a release/deploy.
