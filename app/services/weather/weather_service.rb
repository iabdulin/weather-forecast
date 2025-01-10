module Weather
  # Service class to handle weather forecast retrieval from various providers
  # @api public
  class WeatherService
    attr_reader :provider

    # Initializes the weather service with a specific provider
    # @param provider_name [String] the name of the weather provider to use
    # @raise [Weather::Error] if the provider is not found
    def initialize(provider_name: nil)
      provider_name ||= "weatherapi_com"
      Rails.logger.info "Initializing WeatherService with provider: #{provider_name}"

      case provider_name
      when "weatherapi_com"
        @provider = Providers::WeatherApiComProvider.new
      when "test"
        @provider = Providers::MockProvider.new
      else
        Rails.logger.error "Invalid weather provider requested: #{provider_name}"
        raise Weather::Error.new("Provider #{provider_name} not found")
      end
    end

    # Retrieves weather forecast for given coordinates
    # @param coordinates [String] the location coordinates to get forecast for
    # @return [Hash] the weather forecast data
    def get_forecast(coordinates)
      lat, lng = transform_coordinates(coordinates)
      Rails.logger.debug "Getting forecast for #{lat},#{lng}"
      cache_key = cache_key(lat, lng)
      cached_data = Rails.cache.read(cache_key)
      cache_age = cached_data ? ((Time.current - cached_data[:timestamp]) / 60).round : nil
      Rails.logger.info(cache_age ? "Cache HIT for forecast (#{cache_age}min old): #{cache_key}" : "Cache MISS for forecast: #{cache_key}")

      result = Rails.cache.fetch(cache_key, expires_in: cache_expiry) do
        forecast = provider.get_forecast("#{lat},#{lng}")
        ForecastValidator.validate!(forecast)
        {
          forecast: forecast,
          timestamp: Time.current
        }
      end
      result[:cache_age] = cache_age
      result.with_indifferent_access
    end

    private

    # Validates and transforms coordinates into latitude and longitude
    # @param coordinates [String] the coordinates to validate and transform
    # @return [Array<Float>] an array containing latitude and longitude
    # @raise [Weather::Error] if the coordinates are invalid
    def transform_coordinates(coordinates)
      raise Weather::Error.new("Coordinates cannot be nil") if coordinates.nil?

      lat, lng = coordinates.split(",").map(&:to_f)

      # Validate coordinates format
      unless lat && lng
        Rails.logger.error "Invalid coordinates format: #{coordinates.inspect}"
        raise Weather::Error.new("Invalid coordinates format. Expected 'lat,lng' but got: #{coordinates.inspect}")
      end

      # Validate coordinate ranges
      unless lat.between?(-90, 90) && lng.between?(-180, 180)
        Rails.logger.error "Coordinates out of range: lat=#{lat}, lng=#{lng}"
        raise Weather::Error.new("Coordinates out of valid range: latitude must be -90 to 90, longitude must be -180 to 180")
      end

      [lat, lng]
    end

    # Generates a cache key for weather data by rounding coordinates.
    # Creates zones approximately 11km wide, with length varying by latitude:
    # wider at equator (11km), narrower at poles (0km).
    #
    # @param lat [Float] latitude (-90 to 90)
    # @param lng [Float] longitude (-180 to 180)
    # @return [String] "weather_LAT_LNG" with coordinates rounded to 0.1°
    # @example cache_key(42.3601, -71.0589) # => "weather_42.4_-71.1"
    def cache_key(lat, lng)
      "weather_forecast/#{@provider.class.name}/#{lat.round(1)}_#{lng.round(1)}"
    end

    # Returns the cache expiry time for the provider
    # Fallback to BaseProvider::CACHE_EXPIRY if the provider does not define it
    # @return [Integer] the cache expiry time in seconds
    def cache_expiry
      provider.class.const_defined?(:CACHE_EXPIRY) ? provider.class::CACHE_EXPIRY : Providers::BaseProvider::CACHE_EXPIRY
    end
  end
end
