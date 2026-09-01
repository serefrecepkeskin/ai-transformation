---
name: implement-task
description: Implements a request end to end — understand, build, verify in the browser, test, self-review, open a PR. Use when given a task file, a ticket, or a plain feature/bugfix request that is bigger than a one-line edit. Stops and asks when the goal cannot be made verifiable.
---

# Implement a task

> Rule #1: no silent assumptions. Anything unclear gets asked, not invented.

## 1. Make the goal verifiable

Restate in one or two lines: what changes, and **what command or observation
proves it works**. Cannot name that proof? The task is not ready — ask.

Work needing more than one session, or touching more than a handful of files:
stop here and use `plan-feature` instead.

## 2. Gather context

Read the docs the task touches ([conventions.md](../../../docs/engineering/conventions.md),
[architecture.md](../../../docs/engineering/architecture.md), relevant ADRs),
then the code around the change — trace the real flow end to end before picking
a rung on the ladder (rule #4). Look for something to reuse.

## 3. Branch

From fresh main: `<type>/<kebab-description>` (conventional-commit type).

## 4. Build

Smallest diff that satisfies the goal. Follow the conventions and the design
tokens; new UI goes through `new-component`; user-facing text through i18n. New behavior
gets a test; a bug fix gets a test that **fails first** — run it, see it fail,
then fix. If a decision settles along the way, run `record-decision` before
moving on.

## 5. Verify — evidence, not assertion

Run the proof from step 1 and read its output. UI changes: run `verify-ui`
and report what the browser showed (screenshot, console, a11y). Logic changes:
the test output. Quote what you actually saw; "should work" is not a result.

## 6. Gates + self-review + PR

Run `run-quality-gates`, then `self-review`; fix critical/medium findings.
Simplification is not a cleanup pass here — it happened while writing, via the
ladder in rule #4. Then `commit-and-pr`: the description carries what changed,
the evidence from step 5, what self-review found, and anything left open.

## 7. Update the feature state

Final step: rewrite [.ai/STATE.md](../../../.ai/STATE.md) — what is done (with
its evidence), what is next, decisions still waiting on an ADR, and any
`TODO(confirm)` handed to a human. Create it from its own skeleton if missing;
delete it when the branch merges.

## Stop and ask when

- The acceptance target is unclear, or two readings give different code.
- The change needs a gate, a shared contract or another service changed.
