# AI Transformation — Copilot Project Templates

> Türkçe sürüm: [README.md](README.md)

Standard, copy-and-use structures for AI-driven development with GitHub Copilot.
Everything an agent needs lives in three places Copilot reads **natively**:

| Piece                  | Location                     | What it is                                            |
| ---------------------- | ---------------------------- | ----------------------------------------------------- |
| Agent guide            | `AGENTS.md` (repo root)      | Golden rules, commands, links to the knowledge base   |
| Knowledge base         | `docs/`                      | Short reference docs the guide links to               |
| Skills                 | `.github/skills/*/SKILL.md`  | Task recipes, loaded on demand (progressive disclosure) |
| Custom agents          | `.github/agents/*.agent.md`  | Specialized personas (e.g. the code reviewer)         |

## Templates

Three templates, one language: **`templates_en/`**. A parallel Turkish edition
existed and was removed — twin copies of the same templates doubled what had to
be kept in sync and produced drift, not clarity.

- `templates_en/frontend-web/` — UI / frontend projects (Next.js, React and similar)
- `templates_en/python-service/` — Python services and APIs
- `templates_en/analyst-workspace/` — business analysts: DB research + task authoring

## Working principles

1. **No task without a Definition of Ready.** Work enters a developer repo as
   a `task.md` with measurable acceptance criteria, DoD, how-to-test and
   verified data sources. The analyst's `refine-task` gate enforces it; a task
   missing any of these is sent back, not guessed at.
2. **Evidence over assumption.** Analysts verify field names against live
   schemas (read-only); developers prove changes in the browser or with tests.
   Unverified claims are labeled `TODO(confirm)`, never stated as fact.
3. **Every task ships tests.** The matching layer comes from the template's
   testing taxonomy (unit / integration / e2e / smoke and tech-specific
   layers); the PR maps acceptance criteria to tests.
4. **Guardrail chain: hooks → gates → CI → review.** Copilot hooks auto-format
   and remind (and deny write-SQL in the analyst workspace); local quality
   gates and CI enforce; the reviewer reads evidence, not promises.
5. **Small tasks, single point of contact.** One deliverable per task; the
   task author stays reachable and answers by updating the task file.
6. **Decisions become ADRs the moment they settle**, in the same PR as the
   code and the affected doc.
7. **Spend tokens deliberately.** Short docs, on-demand skills, the built-in
   code index, and the model mix (cheap model drafts, strongest model reviews).

The three developer templates share the same skeleton; only the tech-specific
skills, conventions and reviewer checklists differ. The analyst workspace is not
a code repo: it is where analysts research databases (read-only MCP) and produce
`task.md` files that the developer templates' `implement-task` skill consumes.

## How to adopt a template

1. Copy the contents of `templates_en/<template>/` into the target repo root.
2. Open the repo with Copilot and run the **`bootstrap-research`** skill:
   it explores the actual codebase (manifests, CI, folder layout) and fills every
   `PLACEHOLDER` section in `docs/` with evidence, marking anything uncertain as
   `TODO(confirm)`.
3. Review the `TODO(confirm)` items with the team, then delete the markers.
4. From then on, keep docs and code in sync via the `record-decision` skill (ADRs).

## The docs/ taxonomy (why three folders)

- `docs/engineering/` — **how** we build: architecture, stack, conventions, testing, workflow.
- `docs/domain/` — **what** we build: glossary, business rules. Stable reference,
  updated only when a concept genuinely changes, never per feature.
- `docs/decisions/` — **why**: numbered, immutable ADRs. A changed decision gets a
  new ADR that supersedes the old one. The ADR ships in the same PR as the code.

## Token & cost optimization

1. **Short docs first.** Everything in `AGENTS.md` + auto-loaded docs is paid for
   on every request. Keep the guide ≤ ~130 lines and each skill ≤ ~60 lines;
   details go into linked docs that are read only when needed.
2. **Skills are progressive disclosure.** Copilot loads a SKILL.md body only when
   the description matches the prompt. Precise "when to use" descriptions are the
   cheapest optimization available.
3. **Copilot's built-in code index.** Repos hosted on GitHub get a remote semantic
   index automatically (updates seconds after a push) — no setup, no cost. Local
   indexing covers up to ~2,500 files; beyond that quality degrades.
4. **MCP code index for large repos.** If a repo outgrows the built-in index or
   agents burn tokens grepping, add an index MCP server:
   [zilliztech/claude-context](https://github.com/zilliztech/claude-context)
   (vector search, ~40% token reduction) or
   [codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp)
   (tree-sitter AST knowledge graph, structural queries). Configure in
   `.vscode/mcp.json`; record the adoption as an ADR.
5. **Model mix.** Draft with a low-cost model, review with a premium one. In
   Copilot: pick a cheaper model for scaffolding/agent runs, switch to the
   strongest model for the `self-review` pass. Same idea as the
   "Codex writes, Claude reviews" pattern.

## Companion documents (Turkish)

- `sunum.pptx` — presentation of these structures for the team
- `rehber.docx` — short guide for the team and managers, with sources
- `yapi-rehberi.docx` — what each file in the structure is for; hooks and the
  docs/ folder logic explained
- `mcp-rehberi.docx` — what MCP is, how analysts work with it, and whether it
  is strictly required
- `yol-haritasi.xlsx` — adoption roadmap, metrics, risks
