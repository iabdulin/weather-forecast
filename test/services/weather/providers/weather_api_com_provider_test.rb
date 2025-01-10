require "test_helper"

module Weather
  module Providers
    class WeatherApiComProviderTest < ActiveSupport::TestCase
      def setup
        @provider = WeatherApiComProvider.new
        @coordinates = "53.5461,-113.4937" # Edmonton coordinates
      end

      test "successfully fetches and parses weather forecast" do
        VCR.use_cassette("weather_api_com_provider_test") do
          result = @provider.get_forecast(@coordinates)
          assert_equal "Edmonton", result[:location][:name]
          assert_equal "Canada", result[:location][:country]

          # Test current conditions
          assert_kind_of Hash, result[:current]
          assert result[:current][:temp_c].is_a?(Numeric)
          assert result[:current][:condition].key?(:text)
          assert result[:current][:condition].key?(:icon)

          # Test forecast
          assert_kind_of Array, result[:forecast]
          assert_equal WeatherApiComProvider::FORECAST_DAYS, result[:forecast].length

          forecast_day = result[:forecast].first
          assert forecast_day.key?(:date)
          assert forecast_day.key?(:maxtemp_c)
          assert forecast_day.key?(:mintemp_c)
          assert forecast_day[:condition].key?(:text)
        end
      end

      test "raises Weather::Error on API error response" do
        error_response = mock_error_response("Invalid API key", 401)

        Net::HTTP.stub :get_response, error_response do
          error = assert_raises(Weather::Error) do
            @provider.get_forecast(@coordinates)
          end

          assert_equal "Failed to fetch weather data", error.message
        end
      end

      test "raises Weather::Error on network error" do
        Net::HTTP.stub :get_response, ->(*_args) { raise SocketError, "Network error" } do
          error = assert_raises(Weather::Error) do
            @provider.get_forecast(@coordinates)
          end

          assert_equal "API request failed: Network error", error.message
        end
      end

      test "raises Weather::Error on invalid JSON response" do
        invalid_response = mock_successful_response("invalid json")

        Net::HTTP.stub :get_response, invalid_response do
          error = assert_raises(Weather::Error) do
            @provider.get_forecast(@coordinates)
          end

          assert_match(/Failed to parse API response/, error.message)
        end
      end

      private

      def mock_successful_response(body)
        response = Net::HTTPSuccess.new(1.0, "200", "OK")
        response.define_singleton_method(:body) { body }
        response
      end

      def mock_error_response(message, code)
        response = Net::HTTPClientError.new(1.0, code.to_s, message)
        response.define_singleton_method(:code) { code.to_s }
        response
      end
    end
  end
end
