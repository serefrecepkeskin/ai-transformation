# Bootstrap prompt — paste this into the agent after installing the template

You are setting up the AI-agent scaffolding that was just copied into this
repository (template: `{{TEMPLATE}}`). The scaffolding is generic; your job is
to make it true for **this** codebase, from evidence only.

If the repo turns out to be empty — no manifest, no source to read — this is the
wrong prompt: use `bootstrap-prompt-greenfield.md` (`start.py --new`), which
decides the stack with the human and scaffolds it, instead of surveying code
that is not there yet.

## Iron law

Everything you write must come from a file you actually read in this repo.
Nothing you cannot verify gets written as fact — it gets marked
`TODO(confirm): <the question>` for a human. A plausible guess is worse than a
visible gap, because a gap gets fixed and a guess gets trusted.

## 1. Survey (read before writing anything)

- **Manifests:** `package.json` / `pyproject.toml` / lockfile — real scripts,
  real dependencies, real versions, the package manager actually in use.
- **Layout:** top-level folders; where routes/components/services/models/tests
  live. Open two or three real files per layer — the conventions are in the
  code, not in your expectations.
- **CI:** `.github/workflows/*` — which gates actually run on a PR.
- **Tests:** the runner, the directory, the naming pattern, how they are run.
- **Existing docs and README:** harvest them, do not duplicate them.
- **Git history:** `git log --oneline -30` for the commit message convention.

## 2. Fill the knowledge base

Replace every `PLACEHOLDER` in `AGENTS.md` and under `docs/` with what you
found. Specifically:

- `AGENTS.md` — the opening paragraph (what this service/app is) and the
  **Commands** section (the repo's real scripts, verbatim).
- `docs/engineering/tech-stack.md` — versions from the lockfile.
- `docs/engineering/architecture.md` — the real layers and where code goes.
- `docs/engineering/conventions.md` — naming, file placement, error handling,
  styling; quote what the existing code already does.
- `docs/engineering/testing.md` — the real runner, layers and commands.
- `docs/domain/glossary.md` and `business-rules.md` — only terms you can point
  at in the code or existing docs; leave the rest empty rather than inventing a
  domain.

## 3. Tailor the skills

The stack-specific skills (`new-endpoint`, `db-migration`, `new-component`,
`verify-ui`) ship with a PLACEHOLDER line. Rewrite each with this repo's real
paths, real commands and real conventions. A skill that names a directory that
does not exist here is worse than no skill.

Delete any skill that does not apply to this repo, and say which and why.

## 4. Check the prerequisites, do not assume them

Run the checks, read the output, and write what is actually missing into
`docs/engineering/manual-actions.md`:

- Node major version (`node -v`) — the design hook needs 22+.
- Are `prettier` / `eslint` (frontend) or `ruff` (python) actually installed?
  The hooks call them and exit silently when they are absent.
- Does the repo already have hooks, a pre-commit config, or CI steps that
  overlap with what was just installed? Reconcile rather than duplicate.

## 5. Report back

Finish with a short report, in this order:

1. **Filled from evidence** — one line per file, naming the source you used.
2. **`TODO(confirm)`** — every open question, and who should answer it.
3. **Deleted / not applicable** — what you removed and why.
4. **Prerequisites missing** — what a human has to install or decide.

Do not touch application code. Do not commit. Do not open a PR.
