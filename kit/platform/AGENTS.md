# <workspace> — Platform Guide

<!-- PLACEHOLDER — the workspace bootstrap fills the three workspace sections (Repo map, Shared data, Branches &
     deploy) from the repos it read; what it cannot verify becomes TODO(confirm). Everything from "Engineering
     principles" on is kit text: edit it in the template, not here. Keep this file short — it loads on every request. -->

Rules that hold in **every** repo of this workspace. Each repo's own `AGENTS.md` adds what is specific to it and
wins on conflict. Claude Code loads this file when started at the workspace root (and in every repo under it,
through the parent-directory `CLAUDE.md`); Copilot reads it through each repo's `.github/copilot-instructions.md`
pointer and the workspace file. Canonical copy: `agent-kit/platform/AGENTS.md`.

Platform-wide docs live next to this guide: `SECURITY.md` (trust boundaries, shared secrets, tokens, open
risks), `DEPLOYMENT.md` (environments, CI/CD, local setup), `SCHEMA.md` (the shared data model — delete it when
nothing is shared). Everything repo-specific is in that repo's `docs/`: `engineering/` (how), `domain/` (what),
`decisions/` (why, numbered ADRs) — the same layout in every repo.

## Repo map

<!-- One row per repo in agent-kit/root/workspace.conf. -->

| Repo | Role | Local port · run |
|---|---|---|
| TODO | TODO | TODO |

## Shared data

<!-- What the repos share and who owns it: databases (which repo owns the schema and the migrations, who only
     reads or mirrors a table), queues, buckets, caches, secrets that must be identical across services, and the
     cross-repo invariants (a rule implemented twice that must stay identical). Deploy order for a schema change.
     "Nothing is shared" is a valid answer — say it. -->

TODO(confirm)

## Branches & deploy

<!-- The branch model (main / develop / release / deploy branches), what a push to each one does, which CI runs
     on a PR. Merging is always a human's decision. -->

TODO(confirm). Agents may commit/push/open PRs only when asked; **merging is always the user's call**.

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

## Language

Code, comments, docstrings, test names and `AGENTS.md`: English. Commit/PR **title English** (conventional),
**body Turkish**. **No `Co-Authored-By` or other AI trailers.** User-facing Turkish copy uses real diacritics
(ğ ü ş ı ö ç). Specs and reports under `agent-work/` may be Turkish.

## Agent setup & workflow

- **Start Claude at the workspace root** (`cd <workspace> && claude`): this guide loads first, a repo's `AGENTS.md`
  loads when you touch its files, and the root `.claude/settings.json` (deny rules, hooks, the PR gate) applies to
  all repos. Started inside a repo, that repo's own settings apply instead. Skills, agents, hooks and settings come
  from `agent-kit` (`agent-kit/scripts/link-repo.sh`); `agent-kit/scripts/check-drift.sh` proves the wiring.
- **One task, six steps** — trail at the root, never committed: the task folder `agent-work/<branch-slug>/`
  (`/` → `-`) holds spec.md/plan.md, and each repo the task touches has its own subfolder
  `agent-work/<branch-slug>/<repo>/` for report.md, review.md and the ui-*.md passes:
  1. `$write-spec` → spec.md (+ plan.md when it spans sessions). 2. `$implement-task` — in this session, or a fresh
  one (a subagent, the Copilot coding agent) working from the spec. 3. Verify yourself — diff and tests; a report
  saying green is not evidence. 4. **The gate** — `/simplify`, `/code-review`, the repo's
  `backend-reviewer | frontend-reviewer`, a security pass (`/security-review` or `security-reviewer`; the agent when
  auth/PII/migrations change); findings in `<repo>/review.md`. 5. UI change → `$verify-ui`. 6. Commit/PR via
  `$commit-and-pr`, only when asked. A hook blocks `git push`/`gh pr create` until step 4 is done (Claude Code; for
  Copilot and people the CI check `pr-evidence.yml` holds the same line).
- **Which check:** one screen after a change = `$verify-ui`; the full matrix before a release = `$ui-check`; design
  critique or polish = `impeccable`; code and security review = the `*-reviewer` agents plus `/code-review` and
  `/security-review`.
- `agent-kit/humans/` is for people (reports, presentations, the AI-standards guide) — do not read it unless asked.
