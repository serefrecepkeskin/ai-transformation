// Signs in once and saves the session for the desktop/mobile projects.
// Credentials come from the environment only (never from the repo):
//   E2E_EMAIL, E2E_PASSWORD — a test persona, never a real person's account.
// TEMPLATE — the bootstrap prompt fills the selectors from the real login page.
import { test as setup, expect } from '@playwright/test'

const authFile = 'e2e/.auth/user.json'

setup('authenticate', async ({ page }) => {
  const email = process.env.E2E_EMAIL
  const password = process.env.E2E_PASSWORD
  if (!email || !password) {
    // A public-only app can skip this: keep an empty state so the projects still run.
    await page.context().storageState({ path: authFile })
    return
  }
  await page.goto('/login') // TODO(confirm): login route
  await page.getByLabel(/e-?mail/i).fill(email) // TODO(confirm): selectors
  await page.getByLabel(/password|şifre/i).fill(password)
  await page.getByRole('button', { name: /sign in|giriş/i }).click()
  await expect(page).not.toHaveURL(/login/) // TODO(confirm): what proves the session exists
  await page.context().storageState({ path: authFile })
})
