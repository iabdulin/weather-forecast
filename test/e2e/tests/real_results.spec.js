const { test, expect } = require('@playwright/test')

const EDMONTON_URL = '/forecast/53.543144,-113.493744'

test('displays results', async ({ page }) => {
  await page.goto('/')

  await expect(page).toHaveTitle(/Weather Forecast/)

  await page.getByPlaceholder('Enter address').click()
  await page.getByPlaceholder('Enter address').fill('Edmonton')

  await expect(page.getByText('🇨🇦 Edmonton, Alberta, Canada')).toBeVisible()
  await expect(page.getByText('🇨🇦 Edmonton International')).toBeVisible()
  await expect(page.getByText('🇬🇧 Edmonton, London,')).toBeVisible()
  await expect(page.getByText('🇨🇦 Edmonton Northlands,')).toBeVisible()
  await expect(page.getByText('🇺🇸 Edmonton Heights,')).toBeVisible()
  await page.locator('html').click()
  await page.getByPlaceholder('Enter address').click()
  await page.getByPlaceholder('Enter address').fill('Edmonton')
  await page.getByText('🇨🇦 Edmonton, Alberta, Canada').click()
  await page.waitForURL(EDMONTON_URL)
})

