# Setup Guide

This guide will help you get the Weather Forecast application up and running on your local machine.

## Prerequisites

- Ruby (version specified in `.ruby-version`)
- Node.js for E2E tests (version specified in `test/e2e/.node-version`)
- Git
- SQLite3 (used for SolidCache)
- config/master.key to decrypt credentials (obtained from the project owner)
- (optional) Foreman gem to run the application locally (`gem install foreman`. It's not bundled with the project as recommended in the gem documentation)

## Initial Setup

1. Clone the repository and install ruby dependencies
```bash
git clone https://github.com/iabdulin/weather-forecast.git
cd weather-forecast
bundle install
```

2. Create the database and cache database for SolidCache
```bash
bin/rails db:setup
```

3. Setup credentials

- Obtain master.key from the project owner
- Place it in config/master.key

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

### Option 1: Run Rails server & Tailwind CSS watcher

Rails server (The application will be available at `http://localhost:3000`):
```bash
bin/rails s
```

Tailwind CSS watcher:
```bash
bin/rails tailwindcss:watch
```

### Option 2: Run using Foreman

```bash
foreman start -f=Procfile.dev
```
Will start the Rails server (`http://localhost:5000/`) and Tailwind CSS watcher.
Might fail on the very first run because Tailwind CSS watcher won't precompile the CSS. Just quit and run it again.

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
- start the Rails server with `bin/rails s`
- Run the tests:
```bash
cd test/e2e
npm run test
```

If you start the application with `foreman`, then update the baseURL in `test/e2e/playwright.config.js` to `http://localhost:5000/`

## Troubleshooting

**Credential Access Errors**
  - Ensure you have the correct master key in `config/master.key`
  - Make sure credentials are properly formatted in YAML
  - If editing credentials fails, try: `EDITOR="code --wait" bin/rails credentials:edit`

**ActiveRecord::StatementInvalid (Could not find table 'solid_cache_entries'):**
  - Run `bin/rails db:setup` to create the database and cache database
  - Make sure that you have the databases created in /storage

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
