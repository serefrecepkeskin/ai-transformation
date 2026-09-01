# Development Workflow

> The lifecycle of a change, from task to production. Placeholder items are
> filled by the bootstrap prompt; the flow itself is the company standard.

```
request → branch → develop → verify → self-review → PR → CI gates → merge → deploy
```

1. **Pick up work** — a ticket, a task file, or a request in chat. The
   `implement-task` skill runs the whole flow; `plan-feature` comes first when
   the work spans more than one session. Work whose "done" cannot be stated as
   something observable goes back to its author before any code is written.
2. **Branch** — from fresh main: `<type>/<kebab-description>`.
3. **Develop** — smallest diff, conventions followed, boundaries validated,
   schema changes via migrations. Settled decisions are recorded immediately
   (`record-decision`).
4. **Verify** — tests for behavior, local endpoint calls for API changes; gates
   green locally (`run-quality-gates`).
5. **Self-review** — `self-review` skill; fix critical/medium findings.
6. **PR** — conventional-commit title; description carries what changed, the
   test evidence and the self-review outcome.
7. **Merge & deploy** — TODO(confirm): squash policy, release automation,
   deploy targets and promotion flow.
8. **After merge** — pull main, start the next task from a fresh branch.
