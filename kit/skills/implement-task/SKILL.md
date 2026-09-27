---
name: implement-task
description: Implement a task the team's way — from a spec (agent-work/<branch-slug>/spec.md), a ticket or a plain request ("bunu implemente et", "şunu ekle", "bu hatayı düzelt"): read the guides, smallest change, tests, gates, report. Use for any feature or bugfix bigger than a one-line edit, whether a fresh session runs it from a spec or you run it with the user present.
---

# implement-task

You are the implementer — a fresh session handed a spec, or this session with the user present. Either way the
orchestrator reads your `report.md` and verifies the work independently, so the report must be accurate, not
optimistic.

## Interactive mode (user present)

Ask blocking questions in the chat instead of writing them into the report. Keep the trail at the work root — the
task's `spec.md`/`plan.md` in `agent-work/<branch-slug>/`, this repo's `report.md` in
`agent-work/<branch-slug>/<repo>/` — when the task spans sessions or repos; for a small task report in the chat
with the report.md sections. Everything below applies unchanged.

## Before touching code

1. Read the spec end to end. Turn **Kabul kriterleri** into your checklist.
2. Read the rules: the workspace platform guide (`AGENTS.md` at the workspace root, `../AGENTS.md` from inside a
   repo) or, in a single repo, `docs/engineering/principles.md`; then the repo's `AGENTS.md` and the `docs/` it
   points to for the area you touch. The repo file is the source of truth for where code goes, what to reuse,
   security rules and tests. Where this skill and `AGENTS.md` disagree, `AGENTS.md` wins — note it in the report.
3. Read the code paths the spec names, plus enough surrounding code to understand them. Use `rg`; do not read the
   repo wholesale.
4. If the spec's "done" is not observable, or something you need is missing (an id, a decision, access), do not
   invent it: write the question under **Sorular / bloklar**, do what is unblocked, and stop there.

## While building

- Stay inside the repo(s) the spec names. A change needed in another repo is reported, not made — unless the spec
  lists that repo too.
- Smallest change that meets the criteria: reuse what the repo already has before writing new code; every changed
  line traces back to the spec. Unrelated dead code or neighbouring bugs go to the report's last section, untouched.
- Every behaviour change ships with a test in the repo's own style (`AGENTS.md` → Tests). A bug fix gets a test
  that fails before the fix — watch it fail.
- Backend: new or changed HTTP route → `$new-endpoint`; schema or model change → `$db-migration`; never migrate a
  shared database unless the spec explicitly says which one.
- Never read, print or paste secrets (real config files, `.env*` except `.env.example`, keys). If a value is
  needed, name it in the report.
- Do not commit, push, tag or open PRs unless the spec says so (then follow `$commit-and-pr`). Leave the working
  tree for the orchestrator.

## Proving it

Run the repo's gates and the spec's **Doğrulama** commands in this session and read the output. "Should work" is
not a state. If a command cannot run here (missing venv, database, service), say exactly that and what it would
take — do not substitute a weaker check and call it green.

## Report

Write `report.md` in the language of the spec, following the kit's `templates/report.md`: summary, changed files
with one-line reasons, verification with real output excerpts, acceptance criteria ticked with evidence,
decisions/assumptions, questions/blocks, things noticed but left alone. Keep it factual; the orchestrator will diff
and re-run anyway.

## Stop and ask (via the report) when

- two readings of the spec are both reasonable;
- the change would alter a scoping predicate, a migration, a security rule or a public contract the spec did not
  mention;
- a gate fails for a reason outside the spec's scope.

## UI changes (any frontend)

Without a browser: list in the report every screen × role the change can affect (the repo's `docs/screens.md`),
ship component/integration tests, and write **"browser smoke pending — orchestrator runs `$verify-ui`"**. Never
claim a screen was verified. Keep screens reachable through the menu and buttons; do not rely on direct URLs.
