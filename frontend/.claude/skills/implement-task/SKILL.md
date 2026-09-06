---
name: implement-task
description: Implements a request end to end — understand, build, verify, gates, cold review, report, PR — from a plain request, a ticket, or a spec file (agent-work/<id>/spec.md). Use for any feature or bugfix bigger than a one-line edit. Stops and asks when the goal cannot be made verifiable; when working from a spec, questions go into the report, never into guesses.
---

# Implement a task

## 1. Make the goal verifiable

Restate in one or two lines: what changes, and **what command or observation
proves it works**. Cannot name that proof? The task is not ready — ask (from a
spec: write the question in the report and stop there). Work needing more than
one session or more than one reviewable diff gets a plan first (`write-spec`).

## 2. Gather context

Read `AGENTS.md`, the docs the task touches (`docs/engineering/conventions.md`,
`docs/engineering/architecture.md`, relevant ADRs), then the code around the
change — trace the real flow end to end. Use `rg`; do not read the repo wholesale.

## 3. Build

On a fresh branch `<type>/<kebab-description>`, the smallest diff that satisfies
the goal — every changed line traces back to the request (rule #4). Stack
recipes: `new-endpoint`, `db-migration`, `new-component`. A bug fix gets a test
that **fails first** — run it, see it fail, then fix. A decision that settles on
the way gets its ADR now (`docs/decisions/README.md`), in the same PR.

## 4. Verify — evidence, not assertion

Run the proof from step 1 and read its output. UI change: `verify-ui`. Endpoint
change: call it locally, paste status + body. Logic change: the test output.
Quote what you actually saw; a command that cannot run here (no DB, no service)
is reported as exactly that, never replaced by a weaker check called green.

## 5. Gates, then a cold review

Run every gate in `AGENTS.md → Commands` the way that section says: all of
them, full output, reported per gate. Then hand the diff and the task's goal —
**not this session's history** — to the `code-reviewer` agent, and to
`security-reviewer` as well when the diff touches authentication, authorization,
tenant/user scoping, sessions, secrets, PII in logs/prompts/audit, rate limits,
URLs built from user data, or a migration. Prefer the strongest model for the
review pass. Save the findings plus what you fixed or deliberately left (and
why) as `agent-work/<id>/review.md`; fix every critical/medium finding, then
re-run the gates — a fix is a change like any other.

## 6. Report, then PR

`agent-work/<id>/report.md` in the shape of `references/report.md` (~60 lines;
if it does not fit, the task was too big): what was done, changed files with
reasons, verification with real output, acceptance criteria ticked with
evidence, decisions, open questions, things noticed but left alone. Then
`commit-and-pr` — the PR description is derived from the report.
`agent-work/<id>/` is committed with the branch and deleted in the last commit
before merge; anything permanent moves to an ADR or `docs/` first.

## Working from a spec (`agent-work/<id>/spec.md`)

You may be a session with no chat history — a subagent, a worktree, the Copilot
coding agent. The spec is the whole conversation you get; the orchestrator reads
your report **and verifies the work independently**, so it must be accurate,
not optimistic.

- The spec's acceptance criteria are your checklist. `AGENTS.md` wins over the
  spec on conflict — note the conflict in the report.
- Stay inside the scope and files the spec names; a change needed elsewhere is
  reported, not made.
- Something missing, or two readings both reasonable? Do not invent it: write
  the question under **Sorular / bloklar**, do what is unblocked, stop there.
- Do not commit, push or open a PR unless the spec says so.
- UI touched and no browser: list every screen × role the change can affect,
  ship component tests, write "browser smoke pending — orchestrator runs
  `verify-ui`". Never claim a screen was verified.

## Stop and ask when

- The acceptance target is unclear, or two readings give different code.
- The change needs a gate, a shared contract, a migration, a security rule or
  another service changed that the request did not mention.
