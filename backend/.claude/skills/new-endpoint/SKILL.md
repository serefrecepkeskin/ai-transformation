---
name: new-endpoint
description: Adds a new API endpoint following this repo's conventions — router placement, request/response models, boundary validation, error contract, tests. Use when a task asks for a new or changed HTTP endpoint.
---

# New endpoint

Read `docs/engineering/conventions.md` and
`docs/engineering/architecture.md` first.
PLACEHOLDER: after the bootstrap prompt, this skill names the repo's real
router/view layout and model conventions.

## Rules

- **Placement** — follow the existing router/module structure; check a
  neighboring endpoint before creating files.
- **Contract first** — define typed request/response models; validate all
  external input at the boundary (AGENTS.md: "Validate at the boundaries"). No raw dict passthrough.
- **Errors** — use the project's error contract; never leak stack traces or
  internal messages to clients.
- **Data access** — through the existing repository/service layer; no SQL by
  string concatenation; schema changes via the `db-migration` skill.
- **Auth** — apply the same auth/permission dependency the neighboring
  endpoints use; TODO(confirm) the scheme.
- **Tests** — at least one test per acceptance criterion, including a failure
  case (bad input → expected error shape).
- **Verify** — call the endpoint locally and check the real response before
  declaring done.
