require "test_helper"

module AddressSuggestions
  module Providers
    class MapboxProviderTest < ActiveSupport::TestCase
      setup do
        @provider = MapboxProvider.new
      end

      test "initializes with correct Geocoder configuration" do
        assert_equal :mapbox, Geocoder.config.lookup
        assert_equal Rails.application.credentials.mapbox_api_key!, Geocoder.config.api_key
      end

      test "search returns formatted address suggestions" do
        # mock_result = Minitest::Mock.new
        # mock_result.expect :address, "123 Main St, New York, NY"
        # mock_result.expect :coordinates, [40.7128, -74.0060]
        # mock_result.expect :country_code, "US"
        query = "8882 170 St NW"
        VCR.use_cassette("mapbox_provider_test") do
          results = @provider.search(query)
          assert_equal 5, results.length
          suggestion = results.first

          assert_equal "8882 170 Street Northwest, Edmonton, Alberta T5T 0J2, Canada", suggestion[:label]
          assert_equal "53.522271,-113.618482", suggestion[:coordinates]
          assert_equal "CA", suggestion[:country_code]
        end
      end

      test "search handles missing country code" do
        VCR.use_cassette("mapbox_provider_test_missing_country_code") do
          results = @provider.search("Singapore")
          assert_equal "unknown", results.first[:country_code]
          assert_equal "Singapore", results.first[:label]
          assert_equal "1.351616,103.808053", results.first[:coordinates]
        end
      end

      test "search with empty results" do
        VCR.use_cassette("mapbox_provider_test_empty_results") do
          results = @provider.search("asdfasdfasdfasfd")

          assert_empty results
        end
      end
    end
  end
end
