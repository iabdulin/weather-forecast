require "test_helper"

module AddressSuggestions
  class SuggestionsServiceTest < ActiveSupport::TestCase
    setup do
      Rails.cache.clear
    end

    test "initializes with default mapbox provider" do
      service = SuggestionsService.new
      assert_instance_of Providers::MapboxProvider, service.instance_variable_get(:@provider)
    end

    test "initializes with specified provider" do
      service = SuggestionsService.new(provider_name: "test")
      assert_instance_of Providers::MockProvider, service.instance_variable_get(:@provider)
    end

    test "raises error for invalid provider" do
      assert_raises(AddressSuggestions::Error) do
        SuggestionsService.new(provider_name: "invalid")
      end
    end

    test "get_suggestions returns cached results when available" do
      query = "8882 170 St NW"
      service = SuggestionsService.new(provider_name: nil)
      VCR.use_cassette("suggestions_service_test") do
        # First call should hit the provider
        result1 = service.get_suggestions(query)
        assert_equal result1[:suggestions][0],
          {"label" => "8882 170 Street Northwest, Edmonton, Alberta T5T 0J2, Canada", "coordinates" => "53.522271,-113.618482", "country_code" => "CA"}
        assert_equal result1[:suggestions].size, 5
        assert_nil result1[:cache_age]
      end

      # Second call should use cache
      result2 = service.get_suggestions(query)
      assert_equal result2[:suggestions][0],
        {"label" => "8882 170 Street Northwest, Edmonton, Alberta T5T 0J2, Canada", "coordinates" => "53.522271,-113.618482", "country_code" => "CA"}
      assert_equal result2[:suggestions].size, 5
      assert_not_nil result2[:cache_age]
    end

    test "validates response format" do
      service = SuggestionsService.new(provider_name: "test")

      provider_mock = Minitest::Mock.new
      provider_mock.expect :search, ["invalid"], ["query"]

      service.instance_variable_set(:@provider, provider_mock)

      assert_raises(AddressSuggestions::Error) do
        service.get_suggestions("query")
      end
    end

    test "validates individual result format" do
      service = SuggestionsService.new(provider_name: "test")

      valid_result = {
        label: "123 Main St",
        coordinates: "1,2",
        country_code: "US"
      }.with_indifferent_access

      invalid_results = [
        {label: 123, coordinates: "1,2", country_code: "US"},  # wrong label type
        {label: "123 Main St", coordinates: 12, country_code: "US"},  # wrong coordinates type
        {label: "123 Main St", coordinates: "1,2"},  # missing country_code
        {label: "123 Main St"}  # missing fields
      ].map { |result| result.with_indifferent_access }

      provider_mock = Minitest::Mock.new
      provider_mock.expect :search, [valid_result], ["valid"]

      service.instance_variable_set(:@provider, provider_mock)

      # Valid result should work
      result = service.get_suggestions("valid")
      assert_equal [valid_result], result[:suggestions]

      # Test each invalid result
      invalid_results.each do |invalid_result|
        provider_mock = Minitest::Mock.new
        provider_mock.expect :search, [invalid_result], ["invalid"]

        service.instance_variable_set(:@provider, provider_mock)

        assert_raises(AddressSuggestions::Error) do
          service.get_suggestions("invalid")
        end
      end
    end
  end
end
