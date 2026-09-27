---
name: write-spec
description: Write a task spec (agent-work/<branch-slug>/spec.md) that a session without this conversation — a subagent, the Copilot coding agent, a teammate — can execute without guessing: observable goal, pointers, constraints, acceptance criteria, exact verification commands. Also the plan (plan.md) for work bigger than one spec. Use when work is delegated, spans sessions or repos, or someone asks to "spec this out".
---

# write-spec

A spec is the whole conversation the implementer will get. A fresh session cannot ask back; whatever is missing
becomes either a question in the report (good) or a silent guess (bad). Write for the first outcome.

## What makes a spec executable

- **One observable "done".** Name the command, test or screen state that proves it. If you cannot, the task
  is not ready — split it or ask the user first.
- **Pointers over prose.** Link the design doc section, the files to change and the files to imitate. The
  implementer reads code well; it cannot read your head.
- **Constraints only where deviation hurts.** Scoping predicate, migration ownership, no-commit, secrets, the
  repo's `AGENTS.md`. Do not enumerate styles the repo already enforces.
- **Out of scope is a real section.** It stops the implementer from "helpfully" widening the change.
- **Verification is copy-pasteable.** Exact commands with the config they need, and what output means pass.
- **Open points are labelled.** If you are unsure, say so; the implementer records a decision instead of
  hiding it.

## Sizing

One spec = one reviewable change, one session. A feature is usually 2–4 specs. A spec that touches two repos
lists both under **Repo(lar)** and writes the contract between them first (API shape, table columns, which side
ships first); the implementer works one repo at a time, one report each.

## Bigger than one spec — write the plan first

Work that needs more than one session or more than one reviewable diff gets `agent-work/<branch-slug>/plan.md`
before any code, from the kit's `templates/plan.md`: goal, out of scope, constraints copied verbatim, files, then
tasks. A task is the smallest unit that carries its own test and could be rejected on its own — never "part 1 of
a refactor". Execute one task at a time: spec → implement → verify → gates → cold review; tick the box and
refresh the report before the next. Before shipping, walk the goal end to end as a user would. The plan and the
reports are the memory across sessions; the chat is disposable.

## Procedure

1. Pick the branch (`<type>/<kebab-slug>`) and create the task folder `agent-work/<branch-slug>/` at the work root
   (`/` → `-`, e.g. `feat-permission-gate`; the work root is the workspace folder, or the repo itself when the kit
   was copied into one repo). The task owns `spec.md` and `plan.md`; every repo it touches gets a subfolder for its
   own trail — `agent-work/<branch-slug>/<repo>/{report,review,ui-smoke,ui-check,ui-bugs}.md`. The PR gate reads
   `<repo>/review.md`, so which file belongs to which repo is never a guess. `agent-work/` is never committed.
2. Copy the kit's `templates/task-spec.md`, fill every section; delete none — an empty section is a signal.
3. Re-read as the implementer: could you start without asking anything? If not, fix the spec, not the prompt.
4. Run it per repo: `$implement-task` in this session, a subagent, or the Copilot coding agent with "work from
   `agent-work/<branch-slug>/spec.md`, report to `agent-work/<branch-slug>/<repo>/report.md`". Then read the report
   **and** the diff and run the verification yourself — a report saying green is not evidence.
