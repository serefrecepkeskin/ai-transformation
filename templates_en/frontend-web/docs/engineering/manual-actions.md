# Manual Actions — Human Checklist

> Single source of truth for **things that require a human**: secrets,
> credentials, access grants, plan upgrades, externally provided artifacts
> (e.g. an API spec), team-provided content.
>
> **Maintenance rule:** when such a need arises, the agent adds it here. When
> done, check it off (`- [ ]` → `- [x]`) and move it to _Done_ with a short note.

## Pending — action needed

- [ ] TODO: added by bootstrap-research / during development
- [ ] After adopting this template: make one test edit to a UI file and confirm
      **both** hook manifests fire — `format-and-docs.json` (formatting) and
      `impeccable.json` (design check). They are separate files and separate
      events, but a silent failure looks exactly like "no findings".
      TODO(confirm)
- [ ] Run `/impeccable document` once the design system is real, so
      [DESIGN.md](../DESIGN.md) stops being a placeholder, and confirm
      impeccable picks it up from `docs/`. TODO(confirm)
- [ ] Check whether the design hook runs at full fidelity in this repo: run
      `node .github/skills/impeccable/scripts/detect.mjs <a UI file>` and look
      for a `DEGRADED` line on stderr. If it appears, the per-edit check is
      undercounting because the HTML parsers are missing — add `htmlparser2`,
      `css-select`, `css-tree` and `domutils` as devDependencies, or accept
      that only CI catches the full rule set. TODO(confirm)

## Done

_(empty)_
