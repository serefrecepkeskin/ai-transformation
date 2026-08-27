---
name: new-component
description: Creates a new UI component that follows this repo's conventions — TypeScript, project naming, styling approach, i18n for all user-facing text, test id hooks. Use when adding a component such as a button/card/dialog/form section.
---

# New component

Read [conventions.md](../../../docs/engineering/conventions.md) first — it is
the source of truth. PLACEHOLDER: after bootstrap-research, this skill should
name the repo's real component location, naming style and styling system.

## Rules

- **Location & naming** — follow the existing component directory and naming
  scheme exactly (check neighbors before creating the file).
- **TypeScript strict** — typed props, no `any`.
- **Reuse first** — search for an existing component/variant that already does
  this before adding a new one.
- **Styling** — use the project's design tokens/variant system; no hardcoded
  colors or magic pixel values.
- **Content** — user-facing text through i18n; components receive content via
  props/children, not hardcoded strings.
- **Accessibility** — semantic elements, keyboard reachability, labels for
  interactive controls.
- **Testability** — add `data-testid` to elements that are E2E targets.
- **Verify** — render it in the app and run the `verify-ui` skill; add a
  component test for behavior.
