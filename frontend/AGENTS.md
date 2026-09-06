# PROJECT_NAME — Agent Guide

> **TEMPLATE.** Installed by the company kit (`install.sh frontend <repo>`).
> Paste the kit's `bootstrap-prompt.md` into the agent to fill every PLACEHOLDER
> from the real codebase.

PLACEHOLDER: one paragraph — what this app is, who uses it, rendering strategy
(SSR/CSR), markets/languages.

This file is the canonical guide for every AI agent working in this repo, on
either runtime (GitHub Copilot and Claude Code both read it). Details live in
`docs/` and are linked below; treat the linked doc as the source of truth. Keep
this file and every doc **short** — everything loaded into context costs tokens
on each request.

## Golden Rules

1. **Think before coding.** No silent assumptions. If the task, design intent
   or a business rule is unclear, stop and ask; state every assumption. If two
   readings of the task are both reasonable, put both on the table instead of
   silently picking one. If you see a simpler route, say so — pushing back on
   a solution you think is wrong is part of the job, not a detour.
2. **Evidence before claims.** Never say done, fixed, passing or working
   without having run the command or looked at the page *in this session*. UI
   changes are proven in a browser via the `verify-ui` skill (screenshot,
   console, a11y); logic changes are proven with tests. No "should work".
3. **Not done until the gates are green.** Every command in Commands
   (typecheck, lint, format, tests) runs before any commit/PR — all of them, full output, reported
   per gate; the discipline is written under Commands.
4. **Simplicity first, surgical changes.** Implement exactly what the task
   asks, in the smallest reasonable diff — no tangential refactors, no extra
   features. Before writing anything new, climb this ladder and stop at the
   first rung that answers: (1) does it need to exist at all? no → skip
   (YAGNI); (2) does this codebase already do it? → reuse, don't rewrite;
   (3) does the stdlib do it? → use it; (4) native platform feature (CSS over
   JS, `<input type="date">` over a picker lib)? → use it; (5) does an
   installed dependency do it? → use it; (6) fits in one line? → one line;
   (7) only then write the minimum that works. The ladder starts *after* the
   problem is understood — be lazy about the solution, never about reading.
   Laziness never applies to validation, error handling, security or
   accessibility. **The surgical test: every changed line traces back to the
   request.** Don't "improve" neighbouring code, comments or formatting; don't
   refactor what isn't broken. Spot unrelated dead code? Say so, don't delete
   it. Clean up only the imports, variables and components *your own* change
   orphaned.
5. **No fix without a root cause.** A bug report names a symptom. Find where
   the bad value is born before editing anything, and fix it there. State the cause as one sentence ("X happens
   because Y produces Z when W") before the first edit; when the flow crosses
   layers, add temporary logging at each boundary, run once, and let the
   evidence say which hop breaks. A bug fix gets a test that fails first.
6. **Every behavior change ships with a test.** New behavior gets a test; a bug
   fix gets a test that fails before the fix and passes after — watch it fail,
   or you have not proven it tests anything. See
   [testing.md](docs/engineering/testing.md).
7. **Follow the conventions and the design system.** See
   [conventions.md](docs/engineering/conventions.md) and
   [DESIGN.md](docs/DESIGN.md); match the existing code. No hardcoded colors or
   magic pixel values where a token exists.
8. **Record decisions proactively.** The moment a library/pattern/domain-rule
   interpretation settles, write the ADR — steps and template in
   [docs/decisions/README.md](docs/decisions/README.md) — and update the
   affected doc, in the same PR. When unsure, lean toward recording.
9. **User-facing text goes through i18n**, never hardcoded.
10. **Secrets are never read, printed or pasted.** Real values live in
    `config/` and `.env*` — never read, never edited; the deny rules in
    `.claude/settings.json` / `.vscode/settings.json` enforce it and are a
    backstop, not a substitute for this rule. The only config files you touch
    are the templates at the repo root, `default.ini` and `env.example`: a new
    setting goes there with a placeholder value, and its *name* goes on
    [manual-actions.md](docs/engineering/manual-actions.md) for a human to
    fill. Keys, certificates and cloud credential stores are not yours either.
    If a secret does surface: don't use it, don't echo it, put its rotation on
    that page. A key that
    reaches the browser bundle is public — treat it as one.
11. **Cold review before push/PR.** Hand the diff and the goal — not your
    narration — to the `code-reviewer` agent, plus `security-reviewer` when
    auth, scoping, sessions, secrets, PII or a migration is touched; fix
    critical/medium findings first, then re-run the gates.
12. **Track what's on the humans.** Anything only a human can do (secret,
    access, external artifact) goes on
    [manual-actions.md](docs/engineering/manual-actions.md).
13. **Keep docs short and current.** Update the relevant doc with the change
    that affects it; never paste long content where a link suffices.

## Commands

PLACEHOLDER — filled from package.json scripts.

- `npm run dev` — dev server (TODO(confirm) port)
- `npm run typecheck` · `npm run lint` · `npm run format:check` · `npm run test`
- `npm run test:e2e` — Playwright sweep of every screen in `docs/screens.md` (TODO(confirm) script)
- `npm run build`
- `npm install` — also wires the commit-time gate (husky, via `prepare`)
- `npx lint-staged` — the gate over staged files; `npm run lint` over the tree

Gate discipline, every commit/PR: run **all** of them, read the whole output,
check the exit code, report each as pass/fail with the number that proves it
("42 passed", "0 errors"). A fixer that rewrites files and then fails
(`ruff --fix`, `eslint --fix`) is a pass in two steps: read what changed, run it
again. Never weaken a gate (`# noqa`/`eslint-disable` sprinkled, a skipped test,
`--no-verify`) — a gate that is wrong is an ADR, not a config edit. "Lint
passed", "only touched one file" and "failure looks unrelated" are not reasons
to skip one.

## Knowledge Base

### Engineering (how we build)

- [architecture.md](docs/engineering/architecture.md)
- [DESIGN.md](docs/DESIGN.md) — design system: tokens, components, do's/don'ts
- [screens.md](docs/screens.md) — screen inventory: route, gate, roles, expected states
- [tech-stack.md](docs/engineering/tech-stack.md)
- [conventions.md](docs/engineering/conventions.md)
- [testing.md](docs/engineering/testing.md)
- [development-workflow.md](docs/engineering/development-workflow.md)
- [manual-actions.md](docs/engineering/manual-actions.md)

### Domain (what we build)

Stable reference — read these; update only when a concept genuinely changes.

- [glossary.md](docs/domain/glossary.md)
- [business-rules.md](docs/domain/business-rules.md)

### Decisions

Numbered, immutable ADRs: `docs/decisions/` (see its README + index).

## Capabilities (skills & agents)

Skills live in `.claude/skills/`, agents in `.claude/agents/` (Copilot twins
generated into `.github/agents/`) — both runtimes read them natively. Invoke a
skill by name (`/verify-ui`) or let the agent pick it. Discipline (gates, root
cause, ADRs, cold review) lives in the rules above, not in skills.

- **`implement-task`** — a request or a `spec.md` end to end: understand →
  build → verify in the browser → gates → cold review → report → PR.
- **`write-spec`** — a spec a session with no chat history can execute
  (`agent-work/<id>/spec.md`), and the plan (`plan.md`) when the work is bigger
  than one spec. Use before delegating or for multi-session work.
- **`verify-ui`** — prove a UI change works in a real browser: reached through
  the UI, layout probes, console, a11y, the function end to end.
- **`ui-check`** — the full screen × role × viewport matrix against
  [screens.md](docs/screens.md), before a release or after a large UI change.
- **`new-component`** — create a component that follows the conventions.
- **`impeccable`** — design quality: checks UI against [DESIGN.md](docs/DESIGN.md);
  `/impeccable document` (re)generates it. Vendored upstream, updated with
  `npx impeccable update` (ADR 0002).
- **`commit-and-pr`** — commit/PR format: English conventional-commit title,
  Turkish body carrying the evidence.
- **agent `code-reviewer`** — priority-ordered diff audit
  (correctness → a11y → i18n → conventions → tests → complexity).
- **agent `security-reviewer`** — browser surface (URLs from user data, keys
  in the bundle, sessions) → authorization → PII → dependencies.

Guardrails: hooks auto-format changed files, run the design detector on edited
UI files, and remind on docs drift (`.claude/hooks/`, wired up in
`.claude/settings.json` for Claude Code and `.github/hooks/` for Copilot);
`.husky/pre-commit` runs the same gate at commit time; safe commands are
pre-approved and secret files denied in both settings files — see
[conventions.md](docs/engineering/conventions.md#automated-guardrails-copilot-hooks--approvals)
for what each layer really enforces.

## Work trail

Every task bigger than a one-line edit leaves its trail in `agent-work/<id>/`
(committed with the feature branch, deleted in the last commit before merge;
only `shots/` is gitignored): `spec.md` (`write-spec`), `plan.md` (`write-spec`),
`report.md` (`implement-task`), `review.md` (the reviewer agents' findings), `ui-smoke.md` /
`ui-check.md` / `ui-bugs.md` (browser passes). The report is rewritten by every
session that touches the task and is the memory across sessions; the PR
description is derived from it. Anything that must outlive the branch moves to
an ADR or `docs/` first.
