# Architecture Decision Records

ADRs are **numbered and immutable**: a changed decision gets a new ADR and the
old one is marked `Superseded by NNNN`. Filenames: `NNNN-kebab-title.md`.

## When is an ADR written?

- A framework/library/tooling choice is made or replaced.
- A folder structure or architectural pattern is settled.
- A domain-rule interpretation is embedded in code.
- Any direction that would be costly to reverse.

> The ADR ships **in the same PR** as the code and the affected
> `engineering/`/`domain/` doc update. How to write one is below the index.

## Index

| #                                              | Title                    | Status   |
| ---------------------------------------------- | ------------------------ | -------- |
| [0001](0001-adopt-ai-driven-workflow.md)       | Adopt AI-driven workflow | Accepted |

## Recording one

1. Next number: highest `NNNN` here + 1. File: `NNNN-kebab-title.md`.
2. Write it from the template below; one decision per ADR.
3. Add the row to the index; if it supersedes an older ADR, mark that one
   `Superseded by NNNN`.
4. Update the affected `engineering/` or `domain/` doc **in the same PR**.

Quick test for whether something deserves one: "would a new teammate ask *why
is it done this way*?" — if yes, record it; when unsure, lean toward recording.

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
