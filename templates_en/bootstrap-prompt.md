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

## 4. Wire up the quality gate

Each template brings its own ecosystem's runner, so there is no second
toolchain to install:

| Template | Commit-time runner | Files it shipped | Wired by |
| --- | --- | --- | --- |
| `python-service` | `pre-commit` (pip) | `.pre-commit-config.yaml`, `requirements-dev.txt` | `pre-commit install` |
| `frontend-web` | `husky` + `lint-staged` (npm) | `.husky/pre-commit`, `.lintstagedrc.json`, `eslint.config.js` | `npm install`, via the `prepare` script |

`start.py` copied those files **only where the repo did not already have them**.
So first find out which case you are in, then do that case's work. There must
end up being exactly one definition of the gate.

**(a) The repo had no lint setup.** The shipped config is now the setup; make
it true for this repo.

- Python: add `[tool.ruff]` (and `[tool.pylint]` if you keep that hook) to the
  **existing** `pyproject.toml` — the template deliberately ships no
  `pyproject.toml`, so never replace theirs. Take `line-length` and
  `target-version` from what the code already does, not from your taste. Pin
  each `rev:` in `.pre-commit-config.yaml` to the version in
  `requirements-dev.txt`.
- Frontend: `npm i -D husky lint-staged`, then
  `npm pkg set scripts.prepare=husky` and `npm install` so the hook is actually
  wired (check that `.husky/_` appeared). Adapt `eslint.config.js` to the real
  stack — TypeScript needs `typescript-eslint`, Next.js needs
  `eslint-config-next`; set `settings.react.version` from the lockfile; add a
  `"lint"` script to `package.json` if there is none; widen the
  `.lintstagedrc.json` glob if the repo is `.ts`/`.tsx`. If the test command is
  not `vitest run`, fix the last line of `.husky/pre-commit`.
- Then run the whole-tree sweep **once** — `pre-commit run --all-files`, or
  `npm run lint` — and read all of it. Existing
  code will fail; that is a finding to report, not something to fix in this
  pass. Report the counts per hook. Do **not** mass-reformat the repo, and do
  **not** loosen a rule to get the count to zero — a rule that genuinely does
  not fit is a `record-decision`, not a config edit.

**(b) The repo already had lint config** (eslint, ruff, flake8, prettier…).
Theirs wins and is untouched. Rewrite the shipped gate to call their existing
commands, and delete what duplicates it. Say what you kept and what you dropped.

**(c) The repo already had a commit hook** — its own husky setup, lint-staged
config in `package.json`, simple-git-hooks, or a hand-written
`.git/hooks/pre-commit`. Two gates is worse than one. Merge the shipped checks
into theirs and delete the template's copy, or replace theirs — pick one, say
why, and make sure only one hook ends up running.

## 5. Check the prerequisites, do not assume them

Run the checks, read the output, and write what is actually missing into
`docs/engineering/manual-actions.md`:

- Is the hook actually wired? Python: `pre-commit --version` and
  `ls .git/hooks/pre-commit`; frontend: `ls .husky/_` and
  `git config core.hooksPath`. A config file on disk proves nothing on its own.
  The fix is `pip install pre-commit && pre-commit install` or `npm install`
  with the `prepare` script set — and it goes in the README so the next person
  gets it too.
- Node major version (`node -v`) — the design hook needs 22+.
- Are `prettier` / `eslint` (frontend) or `ruff` (python) actually installed?
  The hooks call them and exit silently when they are absent.
- CI: does a workflow already run these gates? The template ships no CI file.
  If nothing runs them on a PR, that is a `TODO(confirm)` for a human — do not
  add a workflow on your own.

## 6. Report back

Finish with a short report, in this order:

1. **Filled from evidence** — one line per file, naming the source you used.
2. **Quality gate** — which case (a/b/c) applied, what you changed, and the
   first whole-tree sweep's output, per check. Prove the hook fires: make a
   throwaway staged change and let it run.
3. **`TODO(confirm)`** — every open question, and who should answer it.
4. **Deleted / not applicable** — what you removed and why.
5. **Prerequisites missing** — what a human has to install or decide.

Do not touch application code. Do not commit. Do not open a PR.
