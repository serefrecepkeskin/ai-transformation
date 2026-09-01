---
name: update-db-catalog
description: Folds verified db-research findings into docs/db-catalog.md — updates the database table and per-database sections with fresh "verified on" dates, without duplicating entries. Use after any db-research session that learned something new.
---

# Update the database catalog

Merge new, **verified** findings into
[db-catalog.md](../../../docs/db-catalog.md).

## Steps

1. Collect the session's findings in citation form
   (`db.schema.table.column — meaning — verified on date`).
2. For each: if the catalog already covers it, refresh the meaning and the
   "verified on" date; otherwise add it to the right database's section
   (create the section if the database is new to the catalog).
3. Record quirks and join paths discovered — those save the most future
   research time.
4. Keep it schema-only: no row values, no PII, no credentials (AGENTS.md
   rule #2).
5. Show the analyst the diff before finishing.

## Rules

- Only findings verified this session get a new date — never bump a date on
  something that wasn't actually re-checked.
- The catalog is reference, not a dump: one line per table/column that
  *matters*, not every column that exists.
