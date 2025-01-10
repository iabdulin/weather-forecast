const { test, expect } = require('@playwright/test')
const { verifyUnits } = require('./_support')

test.describe('Mock provider', () => {
  test('displays mock data', async ({ page }) => {
    await page.goto('/forecast/1,1?provider=test')
    await expect(page.getByText('Mock City')).toBeVisible()
    await expect(page.getByText('Mock Country')).toBeVisible()
    await expect(page.getByText('Feels like 52°F')).toBeVisible()
    await expect(page.getByText('7 mph N wind, 11% humidity')).toBeVisible()
    await verifyUnits('imperial', page)
  })

  test('returns json data', async ({ request }) => {
    const response = await request.get('/forecast.json?coordinates=1,1&provider=test')
    expect(await response.json()).toMatchObject({
      "forecast": {
        "location": {
          "name": "Mock City",
          "country": "Mock Country",
        },
        "current": {
          "temp_c": 11,
          "feelslike_c": 11,
        },
      }
    })
  })

  test.describe('Error handling', () => {
    test('displays html error message', async ({ page }) => {
      await page.goto('/forecast/raise_error?provider=test')
      await expect(page.getByText('Weather service unavailable')).toBeVisible()
    })

    test('returns json error message', async ({ request }) => {
      const response = await request.get('/forecast.json?coordinates=raise_error&provider=test')
      expect(response.status()).toBe(503)
      expect(await response.json()).toEqual({ error: 'Weather service unavailable' })
    })
  })
})
