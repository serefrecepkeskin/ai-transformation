# Probe snippets for the page-script tool (Claude in Chrome `javascript_tool`, Playwright `browser_evaluate`, VS Code browser tools)

Each returns a small JSON object; paste the result into `ui-smoke.md`. Selectors cover Bootstrap-style modals/offcanvas and ARIA roles — extend them for the UI kit this repo uses.

## Overlap / clickability
```js
(() => {
  const sel = 'a[href],button,[role=button],input,select,textarea,[role=tab],[role=menuitem],[role=switch],[role=checkbox]';
  const bad = [];
  let checked = 0;
  for (const el of document.querySelectorAll(sel)) {
    const r = el.getBoundingClientRect();
    if (r.width < 4 || r.height < 4) continue;
    if (r.bottom < 0 || r.top > innerHeight || r.right < 0 || r.left > innerWidth) continue;
    const cs = getComputedStyle(el);
    if (cs.visibility === 'hidden' || cs.display === 'none' || Number(cs.opacity) === 0) continue;
    checked++;
    const hit = document.elementFromPoint(r.left + r.width / 2, r.top + r.height / 2);
    if (hit && hit !== el && !el.contains(hit) && !hit.contains(el)) {
      bad.push({ el: (el.tagName + '.' + [...el.classList].slice(0, 2).join('.')).slice(0, 60), text: (el.innerText || el.value || '').trim().slice(0, 30), coveredBy: (hit.tagName + '.' + [...hit.classList].slice(0, 2).join('.')).slice(0, 60) });
    }
  }
  return { checked, covered: bad.slice(0, 20), coveredCount: bad.length };
})()
```

## Overflow / clipping
```js
(() => {
  const de = document.documentElement;
  const horizontal = de.scrollWidth > de.clientWidth + 1;
  const clipped = [];
  for (const el of document.querySelectorAll('body *')) {
    const cs = getComputedStyle(el);
    if (!/(hidden|clip)/.test(cs.overflowX + cs.overflowY)) continue;
    if (el.scrollWidth > el.clientWidth + 2 || el.scrollHeight > el.clientHeight + 2) {
      const txt = (el.innerText || '').trim();
      if (!txt) continue;
      const ellipsis = cs.textOverflow === 'ellipsis' || cs.webkitLineClamp !== 'none';
      clipped.push({ el: (el.tagName + '.' + [...el.classList].slice(0, 2).join('.')).slice(0, 60), text: txt.slice(0, 40), designed: ellipsis, dx: el.scrollWidth - el.clientWidth, dy: el.scrollHeight - el.clientHeight });
    }
  }
  return { horizontalScroll: horizontal, clippedCount: clipped.length, clipped: clipped.slice(0, 20) };
})()
```

## Scroll
Run `computer.scroll` (down, 10 ticks) over the main content, then:
```js
({ scrollY: window.scrollY, docH: document.documentElement.scrollHeight, winH: innerHeight,
   bodyOverflow: getComputedStyle(document.body).overflow, bodyInline: document.body.getAttribute('style'),
   scrollers: [...document.querySelectorAll('body *')].filter(e => { const c = getComputedStyle(e); return /(auto|scroll)/.test(c.overflowY) && e.scrollHeight > e.clientHeight + 2; }).map(e => (e.tagName + '.' + [...e.classList].slice(0, 2).join('.')).slice(0, 60)).slice(0, 10) })
```
Expect `scrollY > 0` or one of `scrollers` to be the intended container; footer visible in the screenshot.

## Modal / drawer residue (after closing)
```js
({ bodyOverflow: document.body.style.overflow, bodyClass: document.body.className,
   backdrops: document.querySelectorAll('.modal-backdrop, .offcanvas-backdrop, [class*="overlay"]').length,
   openModals: document.querySelectorAll('.modal.show, .offcanvas.show, [role=dialog]').length,
   scrollY: window.scrollY })
```
Expect empty overflow, 0 backdrops, 0 open dialogs, and a subsequent wheel scroll to move the page.

## Z-order sanity (while a dropdown/toast/drawer is open)
```js
(() => { const top = [...document.querySelectorAll('[role=dialog], .dropdown-menu.show, .toast, .offcanvas.show')].map(e => { const r = e.getBoundingClientRect(); const hit = document.elementFromPoint(r.left + 5, r.top + 5); return { el: e.className.toString().slice(0, 40), visibleOnTop: e.contains(hit) || e === hit }; }); return top; })()
```
