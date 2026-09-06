# TASK-001 — Show last login date in the admin user list

> **EXAMPLE task** — kept as a living sample of the template. Real tasks follow
> exactly this shape.

- **Author:** A. Analyst (reachable on the team channel)
- **Date:** 2026-08-26
- **Target repo:** admin-portal (frontend)
- **Priority:** medium

## Context

Support agents ask engineering weekly for "when did user X last log in" while
handling account-lockout complaints. The data already exists in the CRM
database; surfacing it in the admin user list removes those interruptions.

## Scope

- **In:** a "Last login" column in the admin user list, sortable, with a
  relative format ("3 days ago") and exact timestamp on hover.
- **Out:** login *history* view; filtering by login date; any change to how
  logins are recorded.

## Acceptance criteria

1. Given a user who has logged in, when the admin list renders, then the
   column shows the relative time and the exact timestamp on hover.
2. Given a user who has never logged in, when the list renders, then the
   column shows "Never" (translated), not a blank or an error.
3. Given the column header is clicked, when sorting applies, then never-logged-in
   users sort last regardless of direction.
4. The list with 1,000 users still renders under the current performance
   budget (no extra request per row).

## Data sources

| Source (db.schema.table.column) | Meaning                                | Verified on |
| ------------------------------- | -------------------------------------- | ----------- |
| crm.dbo.Users.LastLoginAt       | UTC timestamp of last successful login | 2026-08-25  |
| crm.dbo.Users.Id                | join key to the portal's user id       | 2026-08-25  |

Notes: `LastLoginAt` is NULL for ~8% of rows (users created before 2019 or
never logged in) — this is the "Never" case in criterion 2. Timestamps are
UTC; the UI must localize.

## UI / i18n notes

Admin user list screen only. New strings ("Last login", "Never") go through
i18n for all supported locales. Loading state: the column participates in the
existing table skeleton; no separate spinner.

## How to test

1. Open the admin user list as an admin.
2. Find a recently active user → column shows a relative time; hover shows the
   exact local timestamp.
3. Find a pre-2019 user (support can name one) → shows translated "Never".
4. Sort by the column both directions → "Never" users are last in both.
5. Check the network panel: no additional request per row.

## Definition of Done

- [ ] All acceptance criteria demonstrably met
- [ ] Quality gates green; sorting behavior covered by a component test
- [ ] Browser evidence (screenshot incl. "Never" case, clean console) in the PR
- [ ] New strings present in all locale files

## Open questions / assumptions

- Does "login" include SSO refreshes or only interactive logins? — owner:
  A. Analyst, asking the identity team, due 2026-08-28. Until answered, the
  column ships with the current `LastLoginAt` semantics.
