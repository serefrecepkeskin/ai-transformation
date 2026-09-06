# Development Workflow

> The lifecycle of a change, from task to production. Placeholder items are
> filled by the bootstrap prompt; the flow itself is the company standard.

```
request → branch → develop → verify → cold review → PR → CI gates → merge → deploy
```

1. **Pick up work** — a ticket, a task file, or a request in chat. The
   `implement-task` skill runs the whole flow; `write-spec` writes the plan first
   when the work spans more than one session. Work whose "done" cannot be stated as
   something observable goes back to its author before any code is written.
2. **Branch** — from fresh main: `<type>/<kebab-description>`.
3. **Develop** — smallest diff, conventions followed, i18n for user-facing text.
   Settled decisions are recorded immediately
   (ADR — `docs/decisions/README.md`).
4. **Verify** — UI in the browser (`verify-ui`), logic with tests; gates green
   locally (all of `AGENTS.md → Commands`).
5. **Cold review** — the `code-reviewer` (+ `security-reviewer`) agents on the
   diff and the goal; fix critical/medium findings.
6. **PR** — conventional-commit title; description carries what changed, the
   browser/test evidence and the review outcome.
7. **Merge & deploy** — TODO(confirm): squash policy, release automation,
   deploy targets and promotion flow.
8. **After merge** — pull main, start the next task from a fresh branch.
