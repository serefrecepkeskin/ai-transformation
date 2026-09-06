// Screen sweep: every walkable route in docs/screens.md, at the desktop and mobile
// projects — loads, shows its expected text, no console errors, no failed requests,
// no overlap, no clipping, no horizontal scroll, the page (or a container) scrolls.
// Interactions, modals, gating per role and both languages stay with the verify-ui /
// ui-check skills: this file proves the floor, the agent proves the rest.
import { test, expect } from '@playwright/test'
import { loadScreens } from './screens'
import { overflowProbe, overlapProbe, scrollProbe } from './probes'

for (const screen of loadScreens()) {
  test(`${screen.name} (${screen.route})`, async ({ page }, testInfo) => {
    const consoleErrors: string[] = []
    const failedRequests: string[] = []
    page.on('console', (m) => m.type() === 'error' && consoleErrors.push(m.text()))
    page.on('response', (r) => r.status() >= 400 && failedRequests.push(`${r.status()} ${r.request().method()} ${r.url()}`))

    await page.goto(screen.route, { waitUntil: 'networkidle' })
    await expect(page.locator('body')).not.toBeEmpty()
    // "Must show" column: a quoted phrase is asserted verbatim; free text is only documentation.
    const quoted = screen.expect.match(/"([^"]+)"/)
    if (quoted) await expect(page.getByText(quoted[1], { exact: false }).first()).toBeVisible()

    await testInfo.attach(`${screen.name}-${testInfo.project.name}.png`, { body: await page.screenshot({ fullPage: true }), contentType: 'image/png' })

    const overlap = await overlapProbe(page)
    const overflow = await overflowProbe(page)
    const scroll = await scrollProbe(page)

    expect.soft(consoleErrors, 'console errors').toEqual([])
    expect.soft(failedRequests, 'non-2xx/3xx requests').toEqual([])
    expect.soft(overlap.covered, 'interactive elements covered by another element').toEqual([])
    expect.soft(overflow.horizontalScroll, 'horizontal scrollbar').toBe(false)
    expect.soft(overflow.clipped, 'text clipped without a designed ellipsis').toEqual([])
    if (scroll.docH > scroll.winH + 2) expect.soft(scroll.scrollY > 0 || scroll.scrollers > 0, 'page or a container scrolls').toBe(true)
  })
}
