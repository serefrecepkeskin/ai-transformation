---
name: new-endpoint
description: Adds a new API endpoint following this repo's conventions — controller/minimal-API placement, DTOs, boundary validation, error contract, tests. Use when a task asks for a new or changed HTTP endpoint.
---

# New endpoint

Read [conventions.md](../../../docs/engineering/conventions.md) and
[architecture.md](../../../docs/engineering/architecture.md) first.
PLACEHOLDER: after bootstrap-research, this skill should name the repo's real
endpoint style (controllers vs minimal APIs) and DTO conventions.

## Rules

- **Placement** — follow the existing controller/endpoint structure; check a
  neighboring endpoint before creating files.
- **Contract first** — dedicated request/response DTOs; never expose EF
  entities directly. Validate all external input at the boundary (rule #8).
- **Errors** — use the project's error contract (e.g. ProblemDetails); never
  leak stack traces or internal messages to clients.
- **Data access** — through the existing service/repository layer; parameterized
  queries only; schema changes via the `ef-migration` skill.
- **Auth** — apply the same authorization policy the neighboring endpoints use;
  TODO(confirm) the scheme.
- **Async all the way** — no `.Result`/`.Wait()`; `CancellationToken` passed
  through.
- **Tests** — at least one test per acceptance criterion, including a failure
  case (bad input → expected error shape).
- **Verify** — call the endpoint locally and check the real response before
  declaring done.
