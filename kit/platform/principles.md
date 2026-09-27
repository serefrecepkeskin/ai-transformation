## Engineering principles

Every change follows these. Rules 1–5 carry Andrej Karpathy's four principles for LLM coding (think before coding,
simplicity first, surgical changes, goal-driven execution); the rest is what teams learned running agents on real
code.

1. **Think before coding.** No silent assumptions: if the task or a business rule is unclear, stop and ask; state
   every assumption. Two reasonable readings → put both on the table instead of picking one. A simpler route, or a
   request you think is wrong → say so; pushing back is part of the job.
2. **Define done, then prove it.** Before the first edit, name the command or screen that will show the task is
   done. Never say done, fixed or passing without running it in this session and reading the output — no "should
   work". Not run → say so.
3. **Not done until the gates are green.** Run every gate in the repo's Workflow before a commit/PR — all of them,
   read the whole output, report each with the number that proves it ("42 passed", "0 errors"). A fixer that
   rewrites files then fails is a pass in two steps: read what changed, rerun. Never weaken a gate (`# noqa`,
   `eslint-disable`, a skipped test, `--no-verify`); a wrong gate is an ADR, not a config edit. "Unrelated failure"
   and "only touched one file" are not reasons to skip one.
4. **Simplicity first.** Once the problem is understood, stop at the first rung that answers: needed at all
   (YAGNI)? → does the repo already do it? → the stdlib? → a platform/DB/browser feature? → an installed
   dependency? → one line? → only then the minimum that works. Be lazy about the solution, never about reading;
   laziness never applies to validation, error handling, security or accessibility.
5. **Surgical changes.** Every changed line traces back to the request. Don't "improve" neighbouring code, comments
   or formatting; don't refactor what isn't broken. Unrelated dead code or a neighbouring bug → report it, don't
   touch it. Match the local style and the repo's conventions. Remove only what your own change orphaned (after a
   search).
6. **No fix without a root cause.** Find where the bad value is born and fix it there — one guard in the shared
   function beats one in every caller. Write the cause as one sentence ("X happens because Y produces Z when W")
   before the first edit; when the flow crosses layers (browser → API → DB → worker), log each boundary once and
   let the evidence name the hop.
7. **Every behaviour change ships with a test.** New logic → a unit test; a new or changed endpoint → the happy
   path plus at least one error case; a bug fix → a test in the lowest layer that reproduces it, failing before
   the fix — watch it fail. Tests run offline: mock external I/O (LLM APIs, caches, object storage, SMS/e-mail)
   unless the repo says a real database is required (its Tests section says which tests need one). Never skip or
   loosen a test to get green.
8. **Validate at the boundaries.** Request bodies, query params, WebSocket messages, queue payloads and third-party
   responses are untrusted: parse them at the edge into typed models in new code; where a repo's AGENTS.md says
   to leave existing schema-less routes alone, it wins.
9. **Secrets are never read or printed**: real config files (`config/*.ini` except the committed `default.ini`,
   `.env*` except `.env.example`), keys, credential stores. New config key → the committed template too; its value
   is a human's job. A secret that surfaces is not used or echoed — its rotation goes in the report.
10. **Name what is left for humans.** A secret to set, an access grant, a server change, a manual migration or
    deploy step goes into the report and the PR's "Notlar", and into `docs/engineering/manual-actions.md` where the
    repo has one — never done silently (server changes: ask first).
11. **Record decisions.** A settled library, pattern or domain-rule reading → an ADR in the repo's
    `docs/decisions/` in the same PR (create the folder with the first one). A change updates the doc it makes
    wrong in the same PR. Keep docs short; link instead of paste.
12. **Some files are not yours.** Texts owned outside engineering (legal, compliance, contracts — the repo's
    AGENTS.md names them) are never edited, simplified or "fixed". Configured API/model rates and limits are used
    as given, not second-guessed.
