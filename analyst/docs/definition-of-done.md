# Definition of Done — company baseline

> **PLACEHOLDER** — confirm with engineering leadership, then remove this note.
> Every task's DoD section starts from this list; tasks add specifics, they
> don't subtract.

A change is done when:

- [ ] All acceptance criteria in the task are demonstrably met
- [ ] Quality gates are green (typecheck/build, lint, format, tests)
- [ ] New behavior is covered by at least one automated test; a bug fix by a
      test that reproduced it
- [ ] UI changes carry browser evidence (screenshot, clean console) in the PR
- [ ] User-facing text goes through i18n (no hardcoded strings)
- [ ] Docs/ADRs affected by the change are updated in the same PR
- [ ] Self-review findings (critical/medium) are fixed
- [ ] PR is merged and deployed to the test environment
- [ ] TODO(confirm): company-specific items (security review? monitoring?
      release notes?)
