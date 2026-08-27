# Development Workflow

> The lifecycle of a change, from task to production. PLACEHOLDER items are
> filled by `bootstrap-research`; the flow itself is the company standard.

```
task.md → branch → develop → verify → self-review → PR → CI gates → merge → deploy
```

1. **Pick up work** — work arrives as a `task.md` (analyst-authored, see the
   analyst workspace's task template). The `implement-task` skill runs the whole
   flow. A task without acceptance criteria / DoD / how-to-test is sent back.
2. **Branch** — from fresh main: `<type>/<kebab-description>`.
3. **Develop** — smallest diff, conventions followed, i18n for user-facing text.
   Settled decisions are recorded immediately (`record-decision`).
4. **Verify** — UI in the browser (`verify-ui`), logic with tests; gates green
   locally (`run-quality-gates`).
5. **Self-review** — `self-review` skill; fix critical/medium findings.
6. **PR** — conventional-commit title; description carries what changed, the
   browser/test evidence and the self-review outcome.
7. **Merge & deploy** — TODO(confirm): squash policy, release automation,
   deploy targets and promotion flow.
8. **After merge** — pull main, start the next task from a fresh branch.
