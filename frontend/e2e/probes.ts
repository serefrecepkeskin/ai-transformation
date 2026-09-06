// Layout probes — the same checks .claude/skills/verify-ui/references/probes.md runs
// by hand in the agent's browser, here as Playwright helpers so CI can run them.
import type { Page } from '@playwright/test'

export async function overlapProbe(page: Page) {
  return page.evaluate(() => {
    const sel = 'a[href],button,[role=button],input,select,textarea,[role=tab],[role=menuitem],[role=switch],[role=checkbox]'
    const covered: { el: string; text: string; coveredBy: string }[] = []
    let checked = 0
    const label = (e: Element) => (e.tagName + '.' + [...e.classList].slice(0, 2).join('.')).slice(0, 60)
    for (const el of document.querySelectorAll(sel)) {
      const r = el.getBoundingClientRect()
      if (r.width < 4 || r.height < 4) continue
      if (r.bottom < 0 || r.top > innerHeight || r.right < 0 || r.left > innerWidth) continue
      const cs = getComputedStyle(el)
      if (cs.visibility === 'hidden' || cs.display === 'none' || Number(cs.opacity) === 0) continue
      checked++
      const hit = document.elementFromPoint(r.left + r.width / 2, r.top + r.height / 2)
      if (hit && hit !== el && !el.contains(hit) && !hit.contains(el)) {
        covered.push({ el: label(el), text: ((el as HTMLElement).innerText || (el as HTMLInputElement).value || '').trim().slice(0, 30), coveredBy: label(hit) })
      }
    }
    return { checked, covered }
  })
}

export async function overflowProbe(page: Page) {
  return page.evaluate(() => {
    const de = document.documentElement
    const horizontalScroll = de.scrollWidth > de.clientWidth + 1
    const clipped: { el: string; text: string; designed: boolean }[] = []
    for (const el of document.querySelectorAll('body *')) {
      const cs = getComputedStyle(el)
      if (!/(hidden|clip)/.test(cs.overflowX + cs.overflowY)) continue
      if (el.scrollWidth > el.clientWidth + 2 || el.scrollHeight > el.clientHeight + 2) {
        const txt = ((el as HTMLElement).innerText || '').trim()
        if (!txt) continue
        const designed = cs.textOverflow === 'ellipsis' || (cs as unknown as { webkitLineClamp: string }).webkitLineClamp !== 'none'
        if (!designed) clipped.push({ el: (el.tagName + '.' + [...el.classList].slice(0, 2).join('.')).slice(0, 60), text: txt.slice(0, 40), designed })
      }
    }
    return { horizontalScroll, clipped }
  })
}

export async function scrollProbe(page: Page) {
  await page.mouse.wheel(0, 2000)
  await page.waitForTimeout(300)
  return page.evaluate(() => ({
    scrollY: window.scrollY,
    docH: document.documentElement.scrollHeight,
    winH: innerHeight,
    scrollers: [...document.querySelectorAll('body *')].filter((e) => {
      const c = getComputedStyle(e)
      return /(auto|scroll)/.test(c.overflowY) && e.scrollHeight > e.clientHeight + 2
    }).length,
  }))
}

export async function modalResidueProbe(page: Page) {
  return page.evaluate(() => ({
    bodyOverflow: document.body.style.overflow,
    backdrops: document.querySelectorAll('.modal-backdrop, .offcanvas-backdrop, [class*="overlay"]').length,
    openDialogs: document.querySelectorAll('.modal.show, .offcanvas.show, [role=dialog]').length,
  }))
}
