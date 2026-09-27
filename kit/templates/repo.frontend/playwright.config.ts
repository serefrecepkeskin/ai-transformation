// Playwright e2e — the agent-independent half of UI verification. `npm run test:e2e`
// walks every screen in docs/screens.md at desktop and mobile width, runs the same
// layout probes the verify-ui skill runs by hand, and keeps screenshots as evidence.
// TEMPLATE — the bootstrap prompt fills the TODO(confirm) lines from the real app.
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  reporter: [['list'], ['html', { open: 'never' }]],
  use: {
    baseURL: process.env.E2E_BASE_URL ?? 'http://localhost:5173', // TODO(confirm): dev server URL
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  // TODO(confirm): the command that serves the app for e2e (or drop webServer and start it yourself)
  webServer: {
    command: 'npm run dev',
    url: process.env.E2E_BASE_URL ?? 'http://localhost:5173',
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
  projects: [
    { name: 'setup', testMatch: /auth\.setup\.ts/ },
    {
      name: 'desktop',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1440, height: 900 }, storageState: 'e2e/.auth/user.json' },
      dependencies: ['setup'],
    },
    {
      name: 'mobile',
      use: { ...devices['Pixel 7'], storageState: 'e2e/.auth/user.json' },
      dependencies: ['setup'],
    },
  ],
})
