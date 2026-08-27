# Analyst Workspace — Agent Guide

This repo is where business analysts research data and author development
tasks. The output of this repo is a **`task.md`** file (see
[task-template.md](docs/task-template.md)) that a developer repo's
`implement-task` skill consumes. No application code lives here.

## Golden Rules

1. **Read-only, always.** Database access from this workspace is SELECT-only.
   Never run INSERT/UPDATE/DELETE/DDL, never against any environment. If a
   task needs data changed, that goes *into the task* for developers.
2. **No sensitive data in artifacts.** Column names, types and row *shapes* are
   evidence; actual customer values (names, emails, IDs, balances) are not.
   Never paste PII or secrets into a task, the catalog, or chat.
3. **Evidence over memory.** Every table/column referenced in a task is
   verified against the live schema via the `db-research` skill, with the
   verification date noted. No field names from memory.
4. **No silent assumptions.** An unconfirmed business rule goes into the task's
   "Open questions" section, clearly marked — never written as fact.
5. **A task ships ready or not at all.** Before delivery, `refine-task` must
   pass: measurable acceptance criteria, DoD, how-to-test, data sources.
   A vague task wastes a developer-agent loop; sending it back costs more
   than finishing it here.
6. **Small tasks.** One deliverable per task. If acceptance criteria don't fit
   on one screen, split it.
7. **Keep the catalog current.** New schema knowledge learned during research
   is folded into [db-catalog.md](docs/db-catalog.md) (`update-db-catalog`).
8. **The author stays reachable.** The task lists its author; developer
   questions get answered by updating the task file, not in lost chat threads.

## Database connections (MCP)

Connections are defined in `.vscode/mcp.json` — one read-only MCP server per
engine (SQL Server, PostgreSQL, Oracle, MySQL). Credentials are prompted via
VS Code inputs or read from env vars; they are **never committed**.

> The server commands in `mcp.json` are starting examples. Confirm the
> company-approved MCP server and a read-only DB login per engine with the
> platform team before first use, and prefer a replica/reporting instance
> over production primaries.

A Copilot hook (`.github/hooks/guard-readonly.json`, preToolUse) additionally
**denies** any tool call containing write/DDL SQL — defense in depth on top of
the read-only login, not a substitute for it.

## Knowledge Base

- [task-template.md](docs/task-template.md) — the required task format
- [how-analysts-work.md](docs/how-analysts-work.md) — the working method
- [db-catalog.md](docs/db-catalog.md) — which database holds what
- [definition-of-done.md](docs/definition-of-done.md) — the company DoD baseline
- `tasks/` — authored tasks, one file each: `<ID>-<kebab-title>.md`

## Capabilities (skills)

- **skill `create-task`** — author a task.md from the template; verifies data
  references via db-research; stops and asks when required fields are unknown.
- **skill `refine-task`** — Definition-of-Ready audit of an existing task;
  returns ordered findings (missing fields, unmeasurable criteria, unverified
  assumptions).
- **skill `db-research`** — read-only schema/data exploration with the MCP
  connections; produces citable evidence (schema.table.column, verified date).
- **skill `update-db-catalog`** — fold verified findings into db-catalog.md.
- **skill `commit-and-pr`** — commit/PR format: English conventional-commit title,
  Turkish body/description.
