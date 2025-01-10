require "test_helper"

module Weather
  module Providers
    class MockProviderTest < ActiveSupport::TestCase
      setup do
        @provider = MockProvider.new
      end

      test "returns mock weather data for valid coordinates" do
        result = @provider.get_forecast("valid_coordinates")

        assert Weather::ForecastValidator.validate!(result)

        assert_equal "Mock City", result[:location][:name]
        assert_equal "Mock Country", result[:location][:country]

        current = result[:current]
        assert_equal 11, current[:temp_c]
        assert_equal 11, current[:feelslike_c]
        assert_equal 11, current[:wind_kph]
        assert_equal "N", current[:wind_dir]
        assert_equal 11, current[:humidity]
        assert_not_nil current[:condition][:text]
        assert_not_nil current[:condition][:icon]

        assert_equal 3, result[:forecast].size
      end

      test "raises Weather::Error when coordinates are 'raise_error'" do
        error = assert_raises(Weather::Error, "Mock provider error") do
          @provider.get_forecast("raise_error")
        end

        assert_equal "Mock provider error", error.message
      end
    end
  end
end
