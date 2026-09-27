# Chrome tool notes (Claude in Chrome) — learned on the RBAC trial, 2026-09-04

- **React forms:** `form_input` sets the DOM value but does not fire React `onChange`; the app still sees an
  empty field. Click the field, then `type`. Selects (`<select>`) do accept `form_input`.
- **Login page autofill:** after `/logout` → `/login` the first typed value is overwritten by browser autofill
  when the page re-renders. Click the email field, wait ~2 s, then triple-click + type; if the screenshot still
  shows autofill, type again without navigating.
- **Ref clicks:** `left_click` by `ref` sometimes does not fire React handlers (e.g. modal openers,
  checkboxes). Prefer coordinates read from the **latest** screenshot; verify with a screenshot or
  `read_page` afterwards. Checkbox: click the label text, then confirm the "N seçili" counter.
- **Coordinates drift:** screenshots are scaled to the current window; whenever the window is resized or a
  banner appears (error alert above the form), re-take a screenshot before clicking.
- **Scroll check:** `computer.scroll` over the main content, then `javascript_tool`:
  `({y: window.scrollY, h: document.documentElement.scrollHeight, body: getComputedStyle(document.body).overflow})`;
  also scroll over the sidebar and confirm it does not move with the page.
- **Modal residue:** after closing a modal/drawer run the scroll check again and read
  `document.body.style.overflow` / leftover `.modal-backdrop` nodes.
- **Console/network:** call `read_console_messages` / `read_network_requests` once at the start of the tab so
  tracking is active; use `pattern`/`urlPattern` filters; clear between screens.
- **Downloads and email:** do not click CSV/download links (sandbox blocks and it needs permission); do not
  trigger real e-mail/SMS sends (use the temp-password path; invite path is covered by live e2e).
- **Evidence:** `screenshot` with `save_to_disk: true`, then copy the file into the work dir `shots/`.
- **Hidden tab freezes transitions:** when the Chrome window is behind another window, `document.visibilityState`
  is `hidden` and CSS transitions/animations do not advance — probes then report modals at `opacity 0.5` or
  offcanvas drawers with `transform: translateX(100%)` (looks like "drawer off-screen"). Always read
  `document.visibilityState` first; take a `screenshot` (it forces a paint) and wait ~1 s before probing
  transition-dependent state, or ask the user to bring the window to front. Do not file such readings as bugs
  without a second, focused measurement.

## Login typing lost to HMR / device emulation
When another session is editing the frontend, Vite HMR may reload the page mid-typing and the login fields end up
empty (`email: ""`). Also, in DevTools device emulation, `computer.type` sometimes never reaches the input.
Fallback that works with Formik/React: set the value through the native setter and fire `input`/`change`:
`const s=Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set; s.call(el,v);
el.dispatchEvent(new Event('input',{bubbles:true}));` then click `button[type=submit]`. Verify `el.value`
before submitting. Logging out in one tab logs out every tab (shared cookie) — re-navigate the others.

## Programmatic scroll freezes in hidden tabs
If the page sets `html { scroll-behavior: smooth }`, `window.scrollTo(0, y)` animates on rAF, which is paused
while `document.visibilityState === "hidden"` (DevTools device mode tabs often report hidden). The probe then
reads a half-way `scrollY`. Use `window.scrollTo({top, behavior: "instant"})` or set
`document.scrollingElement.scrollTop` directly before measuring.
