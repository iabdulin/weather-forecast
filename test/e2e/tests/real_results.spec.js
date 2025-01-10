const { test, expect } = require('@playwright/test')
const { verifyUnits } = require('./_support')

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

test('toggle units', async ({ page }) => {
  await page.goto(EDMONTON_URL)

  await test.step('Default is imperial', async () => {
    await verifyUnits('imperial', page)
  })

  await test.step('Toggle to metric', async () => {
    await page.getByText('°C/km/h').click()
    await verifyUnits('metric', page)
  })

  await test.step('Choice saved after page reload', async () => {
    await page.reload()
    await verifyUnits('metric', page)
  })
})
