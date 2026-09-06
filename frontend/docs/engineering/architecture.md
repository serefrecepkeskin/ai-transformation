# Architecture

> **PLACEHOLDER** — paste the bootstrap prompt to fill this from the
> real codebase. Keep it short; when an architectural decision changes, update
> this file and write an ADR in the same PR.

## Rendering strategy

TODO(confirm): SSR / CSR / hybrid per route — which pages use which and why.

## Folder structure

```
TODO: real top-level tree with one-line notes per folder
```

## Layers

- **UI components** — TODO: where primitives live, what they may/may not contain
- **Feature components** — TODO: domain compositions, data access pattern
- **State** — TODO: client-state library, what belongs in stores vs URL vs local
- **Data fetching / API layer** — TODO: how the app talks to backends, where
  validation happens, error contract

## Deployment & release

TODO(confirm): branch model, CI gates, how a merge becomes a release/deploy.
