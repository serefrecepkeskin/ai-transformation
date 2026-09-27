// Reads docs/screens.md so the e2e sweep and the ui-check skill share one inventory.
// Columns: | Screen | Route | Gate | Roles to check | Must show / must not show |
// Only rows whose Route is a plain path are walked; rows with parameters (`/x/:id`)
// need a fixture and are skipped with a note — add them to smoke.spec.ts by hand.
import fs from 'node:fs'
import path from 'node:path'

export type Screen = { name: string; route: string; gate: string; roles: string; expect: string }

export function loadScreens(): Screen[] {
  const md = fs.readFileSync(path.join(process.cwd(), 'docs/screens.md'), 'utf8')
  const rows = md
    .split('\n')
    .filter((l) => l.startsWith('|') && !l.startsWith('| Screen') && !l.startsWith('|---'))
    .map((l) => l.split('|').slice(1, -1).map((c) => c.trim()))
    .filter((c) => c.length >= 5)
  const screens = rows.map(([name, route, gate, roles, expectText]) => ({
    name,
    route: route.replace(/`/g, ''),
    gate,
    roles,
    expect: expectText,
  }))
  const walkable = screens.filter((s) => /^\/[^\s:*]*$/.test(s.route) && s.name !== 'TODO')
  if (walkable.length === 0) {
    throw new Error('docs/screens.md has no walkable routes — fill the screen inventory first (bootstrap prompt §2)')
  }
  return walkable
}
