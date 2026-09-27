# Frontend lens (UI code)

The repo's `AGENTS.md` (Security & gotchas, Conventions, Screens & design) names the files and rules that are
load-bearing there — read it first; this list says what to look for everywhere. Order of importance:

1. **Correctness.** Broken loading/error states, stale closures, effects without cleanup, fetch/WebSocket/timer
   races, optimistic updates that never reconcile, storage treated as truth, a `null` rendered as `0`.
2. **Authorization is cosmetic — but must not lie.** Menu, route and controls are gated from the same session
   state; a control that would 403 is hidden (or explained); nothing security-relevant is decided client-side.
3. **Single-source lists.** Menu, routes, pipeline stages, permission codes, query keys — a consumer changed without
   its list (or without its `docs/screens.md` row) is a finding.
4. **i18n.** Every user-facing string through the i18n layer; keys in every locale; real diacritics; runtime-built
   keys covered by the repo's key test. The fallback hides a missing key.
5. **Design system.** Tokens not raw hex, the repo's UI kit and primitives, no second UI kit, no re-theming a
   primitive at the call site (`docs/DESIGN.md`).
6. **Security surface.** URLs from user/API data sanitised, no raw HTML injection, one HTTP client, the session
   token only where the repo says it lives, public env vars hold nothing secret, CSP changes through the repo's
   mechanism, PII never cached or logged.
7. **Accessibility.** Names on interactive elements, labels on inputs, keyboard reachability, focus trapped and
   restored in dialogs, icon-only buttons with a translated label, touch targets ≥ 44 px on phone-first apps.
8. **TypeScript strictness.** `any`, non-null `!`, unsafe casts, widened types, a disabled check.
9. **Reuse.** A rebuilt copy of something the repo's "Reuse before writing new" lists.
10. **Tests.** Extracted logic has a test beside it; single-source lists keep their invariant tests; changed
    behaviour with an unchanged test; device behaviour that cannot be unit-tested has its manual step.
11. **Unnecessary complexity.** An abstraction with one caller, a hand-rolled helper the platform or repo already
    has, config nobody sets, dead code the change orphaned — tag `delete:` / `reuse:` / `stdlib:` / `yagni:` and
    name the replacement.

Back a finding with the repo's own read-only tools where they apply (lint, typecheck, unused-code checks).
