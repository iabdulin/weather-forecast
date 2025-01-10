# Weather Forecast

## Demo
https://github.com/user-attachments/assets/537c8d30-864d-4fbd-b518-c73688f28472


## CI
![CI](https://github.com/iabdulin/weather-forecast/actions/workflows/ci.yml/badge.svg)
- Linting with StandardRB
- Security scanning with Brakeman
- Security scanning with Importmap audit
- Rails minitests
- E2E tests with Playwright (not added to CI yet)

## Getting Started

For detailed setup instructions, please see our [Setup Guide](docs/setup.md).


## Application Flow

#### Forecast Controller ([source](https://github.com/iabdulin/weather-forecast/blob/main/app/controllers/forecast_controller.rb))

Main controller for the application, 3 endpoints:
- **index** (also root_url): displays the form to enter address or city (HTML only format)
- **address_suggestions**: inits Address `SuggestionsService` and fetches address suggestions (JSON only format)
- **show**: inits `WeatherService` and displays the forecast for the given address (supports both JSON and HTML format)


#### Address Suggestions Service ([source](https://github.com/iabdulin/weather-forecast/blob/main/app/services/address_suggestions/suggestions_service.rb))

Responsible for fetching address suggestions from the provider and caching them (cache_key is simply `suggestions_#{query}`).
Validates suggestions results to have all required values.
Can be initialized with a specific provider for a potential extensibility and easier testing.
**Providers:**
- [BaseProvider](https://github.com/iabdulin/weather-forecast/blob/main/app/services/address_suggestions/providers/base_provider.rb): abstract class
- [MapboxProvider](https://github.com/iabdulin/weather-forecast/blob/main/app/services/address_suggestions/providers/mapbox_provider.rb): fetches address suggestions from the Mapbox API, default provider
- [MockProvider](https://github.com/iabdulin/weather-forecast/blob/main/app/services/address_suggestions/providers/mock_provider.rb): used for testing


#### Weather Service ([source](https://github.com/iabdulin/weather-forecast/blob/main/app/services/weather/weather_service.rb))

Responsible for fetching weather data from the provider and caching it (cache_key is `weather_forecast/#{@provider.class.name}/#{lat.round(1)}_#{lng.round(1)}`, see "Caching Strategy" section for more information).
Validates and transforms passed coordinates.
Validates result with [ForecastValidator](https://github.com/iabdulin/weather-forecast/blob/main/app/services/weather/forecast_validator.rb).
Can be initialized with a specific provider for a potential extensibility and easier testing.
**Providers:**
- [BaseProvider](https://github.com/iabdulin/weather-forecast/blob/main/app/services/weather/providers/base_provider.rb): abstract class
- [WeatherApiProvider](https://github.com/iabdulin/weather-forecast/blob/main/app/services/weather/providers/weather_api_com_provider.rb): fetches weather data from the [WeatherApi](https://www.weatherapi.com/) API
- [MockProvider](https://github.com/iabdulin/weather-forecast/blob/main/app/services/weather/providers/mock_provider.rb): used for testing


## Testing Strategy

- Ruby Minitest: "47 runs, 136 assertions". Used VCR gem to record HTTP requests in tests.
- E2E Tests with Playwright: 6 tests

## Caching strategy

While the requirements specify caching by zip codes, I implemented geospatial binning instead, for these reasons:

1. **Global Coverage**: Zip codes aren't universal and don't exist in many areas
2. **Simplicity**: Rounding coordinates (0.1°) is simpler than managing zip codes
3. **Precision**: Creates zones roughly 11km tall, with width varying by latitude
4. **Efficiency**: While theoretically possible to have 6.48M zones (1,800 lat × 3,600 lng bins), in practice only populated areas are cached, resulting in tens of thousands of keys at max.
5. **Data Integrity**: Prevents cache poisoning by avoiding zip code validation. With zip-code based caching, a malicious user could send requests like "90210,(-50.123,160.456)" where the coordinates are actually in the middle of the ocean. This would cache incorrect weather data under the Beverly Hills zip code, affecting other users. Our coordinate-based approach prevents this by using the actual coordinates as the cache key, ensuring data integrity. Validating coordinates against zip codes would require an extra geocoding lookup on each request, which would be inefficient.

This approach better serves global users while being simpler to maintain and scale.

## Technical Decisions

### Default Rails Stack

I chose to use the default Rails stack without removing any components like ActiveRecord or Action Cable because:
- This keeps the app easily extensible for future requirements
- It maintains familiar Rails conventions for other developers
- There's little gain in removing components and it often creates more complexity than it solves

### Using Stimulus for JS

I chose to use Stimulus for JS because it's a default Rails component and it's a simple way to handle JS.
I also wanted to learn it more because I have extensive experience with modern JS frameworks (Angular, Vue) but haven't written jquery-like JS code for the last decade.

### Using Tailwind for CSS

I chose to use Tailwind library because, in my experience, it's the easiest way to write maintainable CSS. It provides consistent styling patterns and reduces the need for custom CSS while keeping everything readable in the HTML.

### Using Playwright for E2E Testing

I chose to use Playwright for E2E testing because it's a modern and easy-to-use testing library.
I also like to use Playwright for actual development to get the application to the right state.
This simplifies the development process a lot and allows to write e2e tests at the same time as the code.


## Potential Improvements

### Fallbacks for when the Mapbox or WeatherAPI services are down
The current implementation doesn't have any backups for when the Mapbox or WeatherAPI services are down. For production, I'd add fallback providers like Google Maps API for geocoding and OpenWeather API for weather data to ensure service reliability. Both Address Suggestions Service and Weather Service support adding new Providers.

### Default Location
The current implementation displays the forecast for the location the user searched for. For production, I'd display the forecast for the location the user is currently in by default. This is a common UX pattern for weather apps and would improve user experience.

### API Rate Limit Handling
Current implementation doesn't handle API rate limit responses explicitly. For production, I'd add better error handling when we hit Mapbox or WeatherAPI rate limits, showing user-friendly messages and potentially implementing a backoff strategy.

### Configure E2E tests in CI
Haven't had enough time for this.

### Linter for JS and CSS
Haven't had enough time for this.
