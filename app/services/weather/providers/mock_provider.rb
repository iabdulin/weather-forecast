# Mock weather provider for testing and development purposes.
# This provider returns static weather data and can simulate errors
# when given specific coordinates.
module Weather
  module Providers
    class MockProvider < BaseProvider
      CACHE_EXPIRY = 1.second

      WEATHER_CONDITIONS = [
        {code: 1000, text: "Sunny", icon: 113},
        {code: 1003, text: "Partly cloudy", icon: 116},
        {code: 1006, text: "Cloudy", icon: 119},
        {code: 1009, text: "Overcast", icon: 122},
        {code: 1030, text: "Mist", icon: 143},
        {code: 1063, text: "Patchy rain possible", icon: 176},
        {code: 1066, text: "Patchy snow possible", icon: 179},
        {code: 1069, text: "Patchy sleet possible", icon: 182},
        {code: 1072, text: "Patchy freezing drizzle possible", icon: 185},
        {code: 1087, text: "Thundery outbreaks possible", icon: 200}
      ].freeze

      # Retrieves mock forecast data for given coordinates
      #
      # @param coordinates [String] The location coordinates to fetch weather for
      # @return [Hash] Mock weather data with location, current conditions, and forecast
      # @raise [Weather::Error] When coordinates are set to "raise_error"
      # @raise [Weather::TimeoutError] When coordinates are set to "timeout"
      def get_forecast(coordinates)
        Rails.logger.info "[Weather::Providers::MockProvider] Getting forecast for coordinates: #{coordinates}"

        case coordinates
        when "raise_error"
          Rails.logger.error "[Weather::Providers::MockProvider] Mock error triggered"
          raise Weather::Error.new("Mock provider error")
        when "timeout"
          Rails.logger.error "[Weather::Providers::MockProvider] Mock timeout triggered"
          raise Weather::TimeoutError.new("Mock provider timeout")
        when "empty"
          {}
        else
          result = get_mock_data(coordinates)

          Rails.logger.info "[Weather::Providers::MockProvider] Successfully retrieved mock forecast"
          result
        end
      end

      private

      def get_mock_data(coordinates)
        {
          location: mock_location_data(coordinates),
          current: mock_current_data,
          forecast: mock_forecast_data
        }.with_indifferent_access
      end

      def mock_location_data(coordinates)
        {
          name: "Mock City",
          country: "Mock Country",
          lat: coordinates.split(",").first,
          lon: coordinates.split(",").last,
          localtime: Time.current
        }
      end

      def mock_current_data
        {
          temp_c: 11,
          is_day: 1,
          feelslike_c: 11,
          wind_kph: 11,
          wind_dir: "N",
          humidity: 11,
          condition: mock_condition
        }
      end

      def mock_forecast_data
        3.times.map do |i|
          {
            date: i.days.from_now.to_date.to_s,
            maxtemp_c: rand(15..35),
            mintemp_c: rand(-5..15),
            maxwind_kph: rand(0..50),
            condition: mock_condition,
            avghumidity: rand(30..80)
          }
        end
      end

      def mock_condition
        condition = WEATHER_CONDITIONS.sample
        {
          code: condition[:code],
          text: condition[:text],
          icon: "https://cdn.weatherapi.com/weather/64x64/day/#{condition[:icon]}.png"
        }
      end
    end
  end
end
