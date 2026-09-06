# Chrome tool notes (Claude in Chrome) — pitfalls learned in the field

- **React forms:** `form_input` sets the DOM value but does not fire React `onChange`; the app still sees an
  empty field. Click the field, then `type`. Native `<select>` elements do accept `form_input`.
- **Login page autofill:** after logout → login the first typed value can be overwritten by browser autofill
  when the page re-renders. Click the field, wait ~2 s, then triple-click + type; if the screenshot still
  shows autofill, type again without navigating.
- **Ref clicks:** `left_click` by `ref` sometimes does not fire React handlers (modal openers, checkboxes).
  Prefer coordinates read from the **latest** screenshot; verify with a screenshot or `read_page` afterwards.
  Checkbox: click the label text, then confirm the selection counter.
- **Coordinates drift:** screenshots are scaled to the current window; whenever the window is resized or a
  banner appears (error alert above the form), re-take a screenshot before clicking.
- **Scroll check:** `computer.scroll` over the main content, then the Scroll probe (`probes.md`); also scroll
  over the sidebar and confirm it does not move with the page.
- **Modal residue:** after closing a modal/drawer run the residue probe and the scroll check again.
- **Console/network:** call `read_console_messages` / `read_network_requests` once at the start of the tab so
  tracking is active; use `pattern`/`urlPattern` filters; clear between screens.
- **Downloads and side effects:** do not click download links (sandboxed, needs permission); do not trigger
  real e-mail/SMS/payment sends — use the test path the repo provides.
- **Evidence:** `screenshot` with `save_to_disk: true`, then copy the file into `agent-work/<id>/shots/`.
- **Hidden tab freezes transitions:** when the Chrome window is behind another window,
  `document.visibilityState` is `hidden` and CSS transitions do not advance — probes then report modals at
  `opacity 0.5` or drawers with `transform: translateX(100%)` ("drawer off-screen"). Read
  `document.visibilityState` first; take a `screenshot` (forces a paint) and wait ~1 s before probing
  transition-dependent state, or ask the user to bring the window to front. Do not file such readings as
  bugs without a second, focused measurement.

## Login typing lost to HMR / device emulation
When another session is editing the frontend, Vite HMR may reload the page mid-typing and the login fields end
up empty. In DevTools device emulation, `computer.type` sometimes never reaches the input. Fallback that works
with controlled React inputs: set the value through the native setter and fire `input`/`change`:
`const s=Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set; s.call(el,v);
el.dispatchEvent(new Event('input',{bubbles:true}));` then click `button[type=submit]`. Verify `el.value`
before submitting. Logging out in one tab logs out every tab (shared cookie) — re-navigate the others.

## Programmatic scroll freezes in hidden tabs
If the page sets `html { scroll-behavior: smooth }`, `window.scrollTo(0, y)` animates on rAF, which is paused
while `document.visibilityState === "hidden"`. The probe then reads a half-way `scrollY`. Use
`window.scrollTo({top, behavior: "instant"})` or set `document.scrollingElement.scrollTop` directly before
measuring.
