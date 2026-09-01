---
name: db-research
description: Read-only schema and data-shape exploration over the MCP database connections — produces citable evidence (db.schema.table.column + verified date) for tasks and the catalog. Use when a task needs data references verified, or to answer "where does X live?".
---

# Database research (read-only)

> Hard rules first: SELECT-only, no PII values into any artifact, prefer
> replicas, always LIMIT/TOP samples (AGENTS.md rules #1-2).

## Steps

1. **Catalog first.** Check [db-catalog.md](../../../docs/db-catalog.md) —
   the answer may already be verified. Only hit the database for what the
   catalog doesn't know or what looks stale.
2. **Schema before data.** Locate candidates via metadata
   (`INFORMATION_SCHEMA.TABLES/COLUMNS` or the engine's equivalent), not by
   sampling blindly. Note types and nullability.
3. **Sample the shape, not the people.** Small samples (`TOP 10`/`LIMIT 10`)
   to understand formats, enums, null-ness, date conventions. Record the
   *pattern* ("status ∈ {A,P,C}; ~12% NULL"), never actual identifying values.
4. **Verify the join path.** If the task spans tables, confirm the join keys
   actually match (types and values) with a bounded query.
5. **Cite.** Every finding becomes: `db.schema.table.column — meaning —
   verified on YYYY-MM-DD`. That is the only form a task may reference.
6. **Fold back.** Run `update-db-catalog` so the next research starts warmer.

## Notes

- An expensive query on a production primary is an incident, not research:
  bound every query, avoid full scans, and stop if a query runs long.
- If access to a needed database is missing, report it as a blocker for the
  platform team — do not work around it.
