---
name: ef-migration
description: Creates and applies an EF Core schema migration safely — generated, reviewed, reversible, tested. Use for any schema change; never edit the database or a generated migration by hand.
---

# EF Core migration

PLACEHOLDER: after bootstrap-research, name the real DbContext(s), the startup
project and the exact commands here.

## Steps

1. Change the entity model/configuration first; generate the migration:
   `dotnet ef migrations add <Summary> --project TODO --startup-project TODO`.
2. **Read the generated migration** — check renames (EF sees drop+add),
   constraints, index changes; fix in the migration code, not in the database.
3. Confirm the `Down()` path works (or record why it is irreversible in the PR).
4. Apply locally (`dotnet ef database update`), run the test suite, and
   exercise the affected endpoints.
5. Destructive operations (drop/rename column with data) → stop and get an
   explicit human go-ahead first; note it in the PR.

## Rules

- One migration per PR when possible; never mix unrelated schema changes.
- Data backfills are separate, idempotent migrations/scripts.
- Production apply strategy: TODO(confirm) (migration bundle / SQL script /
  auto-migrate — what does the pipeline actually do?).
