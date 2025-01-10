require "test_helper"

class Weather::WeatherServiceTest < ActiveSupport::TestCase
  def setup
    super
    @service = Weather::WeatherService.new(provider_name: nil)
    @coordinates = "53.5461,-113.4937"
    @cache_key = "weather_forecast/Weather::Providers::WeatherApiComProvider/53.5_-113.5"
    @mock_forecast = {
      forecast: {test: "test"},
      timestamp: Time.current
    }.with_indifferent_access
    Rails.cache.clear
  end

  class InitializeTest < Weather::WeatherServiceTest
    test "initializes with WeatherApiComProvider by default" do
      assert_equal Weather::Providers::WeatherApiComProvider, @service.provider.class
    end

    test "initializes with test provider when specified" do
      service = Weather::WeatherService.new(provider_name: "test")
      assert_equal Weather::Providers::MockProvider, service.provider.class
    end

    test "raises error for invalid provider" do
      error = assert_raises(Weather::Error) do
        Weather::WeatherService.new(provider_name: "invalid_provider")
      end
      assert_equal "Provider invalid_provider not found", error.message
    end
  end

  class GetForecastTest < Weather::WeatherServiceTest
    test "returns cached forecast when available" do
      VCR.use_cassette("weather_service_test") do
        # First call should hit the provider
        result = @service.get_forecast(@coordinates)

        assert_equal "Edmonton", result["forecast"]["location"]["name"]
        assert_equal "Canada", result["forecast"]["location"]["country"]
        assert_nil result[:cache_age]
      end

      # Second call should use cache
      result = @service.get_forecast(@coordinates)
      assert_equal "Edmonton", result["forecast"]["location"]["name"]
      assert_not_nil result[:cache_age]
    end

    test "handles provider errors gracefully" do
      @service.provider.stub(:get_forecast, ->(_) { raise Weather::Error.new("API Error") }) do
        assert_raises(Weather::Error) do
          @service.get_forecast("10,10")
        end
      end
    end

    test "validates forecast data structure" do
      invalid_forecast = {invalid: "data"}
      @service.provider.stub(:get_forecast, ->(_) { invalid_forecast }) do
        assert_raises(Weather::Error) do
          @service.get_forecast("20,20")
        end
      end
    end

    test "includes timestamp in cached response" do
      VCR.use_cassette("weather_service_test") do
        result = @service.get_forecast(@coordinates)
        assert_instance_of ActiveSupport::TimeWithZone, result[:timestamp]
      end
    end
  end

  class TransformCoordinatesTest < Weather::WeatherServiceTest
    def setup
      super
      @service = Weather::WeatherService.new(provider_name: "weatherapi_com")
    end

    test "returns transformed coordinates with valid input" do
      result = @service.send(:transform_coordinates, "53.5461,-113.4937")
      assert_equal [53.5461, -113.4937], result
    end

    test "raises error when coordinates are nil" do
      error = assert_raises(Weather::Error) do
        @service.send(:transform_coordinates, nil)
      end
      assert_equal "Coordinates cannot be nil", error.message
    end

    test "raises error for invalid format" do
      error = assert_raises(Weather::Error) do
        @service.send(:transform_coordinates, "invalid")
      end
      assert_match(/Invalid coordinates format/, error.message)
    end

    test "raises error for out of range latitude" do
      error = assert_raises(Weather::Error) do
        @service.send(:transform_coordinates, "91,0")
      end
      assert_match(/Coordinates out of valid range/, error.message)
    end

    test "raises error for out of range longitude" do
      error = assert_raises(Weather::Error) do
        @service.send(:transform_coordinates, "0,181")
      end
      assert_match(/Coordinates out of valid range/, error.message)
    end

    test "handles whitespace in coordinates" do
      result = @service.send(:transform_coordinates, " 42.3601  ,   -71.0589 ")
      assert_equal [42.3601, -71.0589], result
    end
  end

  class CachingTest < Weather::WeatherServiceTest
    test "includes provider class name in cache key" do
      result = @service.send(:cache_key, 53.5461, -113.4937)
      assert_includes result, @service.provider.class.name
    end

    test "generates correct cache key with rounded coordinates" do
      result = @service.send(:cache_key, 53.5461, -113.4937)
      assert_equal @cache_key, result
    end

    test "uses provider's CACHE_EXPIRY when defined" do
      custom_expiry = 1800 # 30 minutes
      provider_class = Class.new
      provider_class.const_set(:CACHE_EXPIRY, custom_expiry)

      @service.stub(:provider, provider_class.new) do
        result = @service.send(:cache_expiry)
        assert_equal custom_expiry, result
      end
    end

    test "uses BaseProvider CACHE_EXPIRY when provider doesn't define it" do
      provider_class = Class.new

      @service.stub(:provider, provider_class.new) do
        result = @service.send(:cache_expiry)
        assert_equal Weather::Providers::BaseProvider::CACHE_EXPIRY, result
      end
    end
  end
end
