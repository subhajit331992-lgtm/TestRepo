import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './',
  timeout: 30000,
  retries: 0,
  reporter: [['html', { outputFolder: 'playwright-report', open: 'never' }]],
  projects: [
    {
      name: 'Chromium',
      use: {
        ...devices['Desktop Chrome'],
        headless: false,
        viewport: { width: 1280, height: 720 },
      },
    },
    {
      name: 'Firefox',
      use: {
        ...devices['Desktop Firefox'],
        headless: false,
        viewport: { width: 1280, height: 720 },
      },
    },
  ],
});