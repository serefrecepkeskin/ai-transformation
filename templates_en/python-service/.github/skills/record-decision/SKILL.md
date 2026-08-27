---
name: record-decision
description: Permanently records an architecture/tooling/domain decision — creates the next numbered ADR under docs/decisions/, updates the index and the affected engineering/domain doc. Use the moment a discussion settles a framework/library choice, folder/architecture pattern, domain-rule interpretation, or anything costly to reverse — even before any code changes.
---

# Record a decision (ADR)

**Trigger it proactively.** Quick test: "would a new teammate ask *why is it
done this way*?" — if yes, record it. When unsure, lean toward recording.

## Steps

1. Find the next number: highest `NNNN` in `docs/decisions/` + 1.
2. Write `docs/decisions/NNNN-kebab-title.md` using the template below.
3. Add the row to the index table in `docs/decisions/README.md`.
4. If it supersedes an older ADR, mark that one `Superseded by NNNN`.
5. Update the affected doc (`docs/engineering/` or `docs/domain/`) **in the same
   PR** — docs and code must not drift apart.

## ADR template

```markdown
# ADR NNNN — <Title>

- **Status:** Accepted
- **Date:** YYYY-MM-DD
- **Deciders:** <who>

## Context

<the problem and the forces at play — short>

## Decision

<what was decided, concretely>

## Alternatives

<what was considered and why rejected — short>

## Consequences

<what becomes easier/harder; follow-ups>
```
