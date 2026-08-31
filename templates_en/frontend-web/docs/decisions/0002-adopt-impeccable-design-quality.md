# ADR 0002 — Adopt Impeccable for design quality

- **Status:** Accepted
- **Date:** TODO
- **Deciders:** TODO

## Context

A UI change can pass typecheck, lint and tests and still be wrong: hardcoded
colors instead of tokens, ad-hoc spacing, a reinvented button, low contrast, or
the visual tells of AI-generated UI (gradient text, glow shadows, accent side
borders). The `verify-ui` skill proves an interface *works*; nothing proved it
*looks right*. Review caught this late, inconsistently, and only when a
reviewer happened to care.

## Decision

Vendor [impeccable](https://github.com/pbakaus/impeccable) into this template
(GitHub Copilot flavor, `npx impeccable install`):

- `.github/skills/impeccable/` — the skill and its deterministic detector.
- `.github/hooks/impeccable.json` — a `postToolUse` hook that checks edited
  UI files right after the edit.
- `.github/agents/impeccable-*.agent.md` — its four helper agents.
- `.impeccable/` — shared config and the design sidecar; per-developer files
  stay gitignored.
- [DESIGN.md](../DESIGN.md) — the design source of truth, generated and
  refreshed by `/impeccable document`.

The detector is deterministic Node — no LLM, no API key — so it also runs in CI.
In `standard-check.yml` it runs in **report-only** mode (`continue-on-error`)
during the pilot; making it a blocking gate is a separate, later decision, taken
once the finding rate on this repo is known.

**DESIGN.md lives at `docs/DESIGN.md`**, not the repo root. Impeccable's own
default is the project root, but its context loader resolves `docs/` natively
(`FALLBACK_DIRS`), so this needs no configuration and keeps the knowledge base
in one place. `docs/engineering/` would have required the
`IMPECCABLE_CONTEXT_DIR` escape hatch — an env var that silently degrades to
"no design context" when unset — so `docs/` is the honest location.

## Alternatives

- **Manual design review only** — rejected: late, inconsistent, expensive, and
  it does not survive reviewer turnover.
- **Custom eslint/stylelint token rules** — rejected for now: they can catch
  raw hex values, but not layout rhythm, component reuse or the AI tells.
  Revisit if impeccable underperforms on this codebase.
- **Root DESIGN.md (the upstream default)** — rejected: it splits the knowledge
  base, and `AGENTS.md` already sends agents to `docs/`.

## Consequences

- `docs/DESIGN.md` is the design source of truth. Refresh it with
  `/impeccable document` whenever the design system changes; it is generated,
  so do not hand-edit the token frontmatter.
- Two hook manifests now coexist (`format-and-docs.json`, `impeccable.json`).
  They are separate files and separate events, but verify both actually fire
  after adopting the template — see [manual-actions.md](../engineering/manual-actions.md).
- On GitHub Copilot the hook runs the **full** detector on every edit (Copilot's
  stop-style events cannot feed context back to the model, so there is no
  cheaper per-edit tier). Expect it to be slower than the format hook.
- The hook resolves its script through `git rev-parse --show-toplevel`, so it
  only works once this template sits at a repository root. Inside the template
  repository itself it is inert — that is expected, not a defect.
- **The vendored copy can run degraded.** The payload ships no `node_modules`,
  and the HTML engine imports `htmlparser2`, `css-select`, `css-tree` and
  `domutils` at runtime. When the adopting repo does not provide them, the
  detector falls back to regex matching and reports *fewer* findings — an
  undercount, not a clean result. It says so on stderr; do not read a quiet run
  as a pass. CI therefore runs the CLI (`npx impeccable@3 detect`), which brings
  its own parsers. Verify the hook's fidelity once after adopting — see
  [manual-actions.md](../engineering/manual-actions.md).
- The CLI and the vendored skill are versioned separately (CLI 3.x, skill
  payload 4.1.1 at the time of vendoring). Bump them deliberately, and expect
  their version numbers not to match.
- Vendored upstream files are kept **verbatim** and are exempt from the
  template's line and description budgets in `standard-check.yml`. Update them
  with `npx impeccable update`, never by hand.
- The vendored payload is large (~150 files). That is the cost of a detector
  that runs without an LLM; it is read on demand, not loaded into context.
