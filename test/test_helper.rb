ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock

  # Don't allow any real HTTP requests in tests
  config.allow_http_connections_when_no_cassette = false

  # Filter sensitive data
  config.filter_sensitive_data("<MAPBOX_API_KEY>") { Rails.application.credentials.mapbox_api_key }

  # # Optionally, configure cassette expiry for weather data
  config.default_cassette_options = {
    record: :once,            # Record first time, playback after
    match_requests_on: [:method, :uri] # How to match requests
    #   re_record_interval: 7.days  # Re-record after a week
  }
end
