const { expect } = require('@playwright/test')

export async function verifyUnits(units, page, tempElementsCount = 8, windElementsCount = 4) {
  const tempElements = page.locator('[data-units-target="temperature"]')
  const count = await tempElements.count()
  expect(count).toBe(tempElementsCount)

  const windElements = page.locator('[data-units-target="wind"]')
  const windCount = await windElements.count()
  expect(windCount).toBe(windElementsCount)
  // Verify all temperature elements show °C or °F
  for (const tempElement of await tempElements.all()) {
    await expect(tempElement).toContainText(units === 'metric' ? '°C' : '°F')
    await expect(tempElement).not.toContainText(units === 'metric' ? '°F' : '°C')
  }

  // Verify all wind elements show km/h or mph
  for (const windElement of await windElements.all()) {
    await expect(windElement).toContainText(units === 'metric' ? 'km/h' : 'mph')
    await expect(windElement).not.toContainText(units === 'metric' ? 'mph' : 'km/h')
  }
}
