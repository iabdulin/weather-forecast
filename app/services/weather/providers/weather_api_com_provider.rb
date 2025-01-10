module Weather
  module Providers
    # Provider class for integrating with the WeatherAPI.com service
    # @see https://www.weatherapi.com/docs/
    class WeatherApiComProvider < BaseProvider
      # Number of days to fetch in forecast
      FORECAST_DAYS = 3 # Free tier only allows 3 days

      # Initializes the provider with API credentials
      # @raise [KeyError] if the API key is not configured
      def initialize
        @api_key = ENV["WEATHERAPI_COM_API_KEY"] || Rails.application.credentials.weatherapi_com_api_key!
        @base_url = "http://api.weatherapi.com/v1/forecast.json"
      end

      # Fetches weather forecast for given coordinates
      # @param coordinates [String] Location coordinates in "latitude,longitude" format
      # @return [Hash] Processed weather data including current conditions and forecast
      # @raise [Weather::Error] if the API request fails or response is invalid
      def get_forecast(coordinates)
        response = make_api_request(coordinates)
        parse_response(response)
      rescue Weather::Error
        raise # re-raise any of our custom errors
      rescue JSON::ParserError => e
        raise Weather::Error.new("Failed to parse API response: #{e.message}")
      rescue => e
        Rails.logger.error("Weather API error: #{e.message}")
        raise Weather::Error.new("Failed to fetch weather data")
      end

      private

      # Makes HTTP request to the WeatherAPI.com endpoint
      # @param coordinates [String] Location coordinates
      # @return [Net::HTTPResponse] Raw API response
      # @raise [Weather::Error] if the request fails
      def make_api_request(coordinates)
        uri = build_uri(coordinates)
        response = Net::HTTP.get_response(uri)

        unless response.is_a?(Net::HTTPSuccess)
          raise Weather::Error.new("API request failed with status #{response.code}", response)
        end

        response
      rescue SocketError, Timeout::Error, URI::InvalidURIError => e
        raise Weather::Error.new("API request failed: #{e.message}")
      end

      # Builds the URI for the API request
      # @param coordinates [String] Location coordinates
      # @return [URI] Formatted URI with query parameters
      def build_uri(coordinates)
        uri = URI(@base_url)
        uri.query = URI.encode_www_form({
          q: coordinates,
          key: @api_key,
          days: FORECAST_DAYS
        })
        uri
      end

      # Parses and structures the API response
      # @param response [Net::HTTPResponse] Raw API response
      # @return [Hash] Structured weather data
      # @raise [JSON::ParserError] if response cannot be parsed
      def parse_response(response)
        data = JSON.parse(response.body)
        Rails.logger.info("Data: #{data}")
        {
          location: data["location"].slice(*%w[name country]),
          current: build_current_conditions(data["current"]),
          forecast: build_forecast(data["forecast"]["forecastday"])
        }.with_indifferent_access
      end

      # Builds the current conditions hash from API data
      # @param current_data [Hash] Current weather conditions from API
      # @return [Hash] Processed current conditions
      def build_current_conditions(current_data)
        {
          **current_data.slice(*%w[
            last_updated_epoch last_updated temp_c is_day
            wind_kph wind_dir humidity feelslike_c
          ]),
          condition: current_data["condition"].slice(*%w[text icon])
        }
      end

      # Builds the forecast array from API data
      # @param forecast_data [Array<Hash>] Forecast data from API
      # @return [Array<Hash>] Processed forecast data
      def build_forecast(forecast_data)
        forecast_data.map do |day|
          {
            date: day["date"],
            condition: day["day"]["condition"].slice(*%w[text icon]),
            **day["day"].slice(*%w[
              maxtemp_c mintemp_c avghumidity maxwind_kph
            ])
          }
        end
      end
    end
  end
end
