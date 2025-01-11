# Setup Guide

This guide will help you get the Weather Forecast application up and running on your local machine.

## Prerequisites

- Ruby (version specified in `.ruby-version`)
- Node.js for E2E tests (version specified in `test/e2e/.node-version`)
- Git
- SQLite3 (used for SolidCache)
- config/master.key to decrypt credentials (obtained from the project owner)

## Initial Setup

1. Clone the repository and install ruby dependencies
```bash
git clone https://github.com/iabdulin/weather-forecast.git
cd weather-forecast
bundle install
```

2. Create the database and cache database for SolidCache
```bash
bin/rails db:create
```

3. Setup credentials

4.1. Obtain master.key from the project owner
4.2. Place it in config/master.key

The project uses the following credentials:
```yaml
weatherapi_com_api_key: your_weatherapi_key # https://www.weatherapi.com/
mapbox_api_key: your_mapbox_key # https://www.mapbox.com/
```

To edit credentials, you can use the following command (you have to have the master.key in the config folder otherwise Rails will not be able to decrypt the credentials file):
```bash
bin/rails credentials:edit
```

4. Setup Playwright to run e2e tests

This will install npm packages and browsers for Playwright
```bash
cd test/e2e
npm install
npx playwright install
```

## Development

### Option 1: Run using Foreman

```bash
foreman start -f=Procfile.dev
```

### Option 2: Run Rails server & Tailwind CSS watcher

Rails server (The application will be available at `http://localhost:3000`):
```bash
bin/rails s
```

Tailwind CSS watcher:
```bash
bin/rails tailwindcss:watch
```

### Linting & Security Scanning

Linting with StandardRB:
```bash
bin/rails standard
```

Brakeman for security scanning:
```bash
bin/brakeman
```

## Testing

1. Run the Ruby test suite:
```bash
bin/rails test
```

2. Run system tests with Playwright:
```bash
cd test/e2e
npm run test
```

## Troubleshooting

**Credential Access Errors**
  - Ensure you have the correct master key in `config/master.key`
  - Make sure credentials are properly formatted in YAML
  - If editing credentials fails, try: `EDITOR="code --wait" bin/rails credentials:edit`

**Test Failures**
  - Ensure VCR cassettes are up to date
  - Check if API keys are properly configured in test environment
  - Try clearing test cache: `bin/rails tmp:clear`

## Additional Resources

- [Rails Credentials Guide](https://guides.rubyonrails.org/security.html#custom-credentials)
- [Geocoder Gem](https://github.com/alexreisner/geocoder)
- [VCR Gem](https://github.com/vcr/vcr)
- [Playwright Documentation](https://playwright.dev/)
- [WeatherAPI.com Documentation](https://www.weatherapi.com/docs/)
- [Mapbox Documentation](https://docs.mapbox.com/)
