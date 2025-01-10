# Setup Guide

This guide will help you get the Weather Forecast application up and running on your local machine.

## Prerequisites

- Ruby (version specified in `.ruby-version`)
- Node.js for E2E tests (version specified in `test/e2e/.node-version`)
- Git
- SQLite3 (used for SolidCache)

## Initial Setup

1. Clone the repository and install ruby dependencies
```bash
git clone https://github.com/yourusername/weather-forecast.git
cd weather-forecast
bundle install
bin/rails db:create
bin/rails db:migrate
```

2. Setup Playwright

```bash
cd tests/e2e
npm install
```

## Create and edit the encrypted credentials file

```bash
bin/rails credentials:edit
```

Add the following credentials:
weatherapi_com_api_key: your_weatherapi_key # Get from https://www.weatherapi.com/
mapbox_api_key: your_mapbox_key # Get from https://www.mapbox.com/

## Development

Rails server (The application will be available at `http://localhost:3000`):
```bash
bin/rails s
```

Tailwind CSS watcher:
```bash
bin/rails tailwindcss:watch
```

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
cd tests/e2e
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
