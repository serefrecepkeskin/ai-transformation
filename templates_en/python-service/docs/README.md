# docs/ — the knowledge base

Why this folder exists: `AGENTS.md` is loaded into the agent's context on
every request, so it must stay short. Everything that doesn't need to be paid
for every time lives here and is read only when a task needs it. Humans and
agents share the same source of truth.

| Folder         | Question it answers | Update rule                                     |
| -------------- | ------------------- | ----------------------------------------------- |
| `engineering/` | **How** do we build | with the change that affects it, in the same PR |
| `domain/`      | **What** do we build | only when a concept is first defined or changes |
| `decisions/`   | **Why** is it this way | append-only numbered ADRs; never edit old ones |

Ground rules: keep every file short; a doc update ships in the same PR as the
code it describes; unresolved facts are marked `TODO(confirm)`, never guessed.
