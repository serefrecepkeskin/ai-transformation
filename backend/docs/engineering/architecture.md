# Architecture

> **PLACEHOLDER** — paste the bootstrap prompt to fill this from the
> real codebase. Keep it short; when an architectural decision changes, update
> this file and write an ADR in the same PR.

## Service shape

TODO(confirm): API service / worker / batch — framework, entrypoints, how it
is deployed and scaled.

## Package structure

```
TODO: real package tree with one-line notes per module
```

## Layers

- **API / routers** — TODO: where endpoints live, request/response models
- **Services / domain logic** — TODO
- **Data access** — TODO: ORM, session management, repository pattern or not
- **Config & secrets** — TODO: settings layer, env handling
- **Background work** — TODO: queue/scheduler, if any

## External integrations

TODO: upstream/downstream systems, contracts, failure behavior.

## Deployment & release

TODO(confirm): branch model, CI gates, how a merge becomes a release/deploy.
