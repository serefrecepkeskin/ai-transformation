---
name: new-endpoint
description: Add or change an HTTP endpoint the way the repo expects — thin route, service, repository, caller-scoped queries, declared auth/permission, rate limit, audit, guard tests. Use for any new or changed route; the repo's AGENTS.md says where the files go and which helpers to use.
---

# new-endpoint

Most security bugs ship in a route that is correct in isolation and wrong for its codebase: a scope checked after
the write, a permission never declared, a cost-bearing call without a limit. This skill is the checklist; **where**
files go and **which** helpers exist is in the repo's `AGENTS.md › Where code goes (Adding:)` and `Security &
gotchas` — read those first.

## Shape

- **Route thin → service → repository.** The route parses, authorizes and delegates. Business logic lives in the
  service; every query/write lives in the repository (or the repo's data layer). No DB session in a route, no raw
  SQL in a service, no SQL built by string concatenation.
- **Typed request/response models** in the repo's schema module; validate at the boundary, never pass raw dicts
  through.
- **Errors**: the repo's domain exceptions and error contract, not an ad-hoc HTTP error for a domain outcome;
  never leak stack traces. Keep error strings a client matches on unchanged.
- **Response models only when the service really returns that shape** — an unchecked annotation is documentation
  that lies.

## The five questions (answer each in the code, not in a comment)

1. **Is it closed to other callers' data?** Every query that reaches a row by id carries the caller's scope
   (tenant / organisation / owner) **inside the WHERE**, taken from the session, never from body/query/path. Ids
   that arrive in the body are validated the same way. Ownership check **before** any write. Scoped-out rows are
   404, not 403.
2. **Who may call it?** Declare the gate the neighbouring routes use (the repo's auth dependency / permission
   decorator). An intentionally open route goes on the repo's exemption list with a reason.
3. **Does it cost money?** LLM, SMS/e-mail, file upload, geocoding, bulk work → an explicit rate limit with the
   repo's named limit.
4. **Where does user input go?** Into an LLM prompt → the repo's redaction step; into logs → masking helpers; back
   to the browser as a URL → sanitised.
5. **Does it mutate?** Record it the way the repo audits mutations (audit row in the same transaction), if it does.

## Prove it

- A test per acceptance criterion, including the failure cases (another caller's id → 404, missing permission →
  403, bad input → the error shape).
- The repo's **guard tests** (auth enforced, permission declared, rate limits) still pass with the new file — they
  scan routes, so run them, don't assume.
- Call the endpoint locally once and read the real response.

Review lens for the finished diff: `references/backend.md` (+ `security.md`) next to the `review` skill.
