module AddressSuggestions
  # Service class to handle address suggestions retrieval from various providers
  # @api public
  class SuggestionsService
    attr_reader :provider

    # Initializes the suggestions service with a specific provider
    # @param provider_name [String] the name of the provider to use
    # @raise [AddressSuggestions::Error] if the provider is not found
    def initialize(provider_name: nil)
      provider_name ||= "mapbox"
      case provider_name
      when "mapbox"
        @provider = Providers::MapboxProvider.new
      when "test"
        @provider = Providers::MockProvider.new
      else
        raise AddressSuggestions::Error.new("Provider #{provider_name} not found")
      end
    end

    def get_suggestions(query)
      query = query.to_s.strip
      cache_key = "suggestions_#{query}"
      cached_data = Rails.cache.read(cache_key)
      cache_age = cached_data ? ((Time.current - cached_data[:timestamp]) / 60).round : nil

      Rails.logger.info(cache_age ? "Cache HIT for suggestions (#{cache_age}min old): #{query}" : "Cache MISS for suggestions: #{query}")

      result = Rails.cache.fetch(cache_key, expires_in: cache_expiry) do
        results = @provider.search(query)
        validate_response!(results)
        {
          suggestions: results,
          timestamp: Time.current
        }
      end
      result[:cache_age] = cache_age
      result.with_indifferent_access
    end

    private

    # Validates the response format from the provider
    # @param response [Array<Hash>] The response from the provider
    # @raise [RuntimeError] if the response format is invalid
    # @return [void]
    def validate_response!(results)
      return if results.is_a?(Array) && results.all? { |r| valid_result?(r) }
      raise Error.new("Invalid response format from #{self.class}. Results: #{results}")
    end

    # Validates an individual result hash
    # @param result [Hash] Single address suggestion result
    # @return [Boolean] true if the result format is valid
    def valid_result?(result)
      result.is_a?(Hash) &&
        result[:label].is_a?(String) &&
        result[:coordinates].is_a?(String) &&
        result[:country_code].is_a?(String)
    end

    # Returns the cache expiry time for the provider
    # Fallback to BaseProvider::CACHE_EXPIRY if the provider does not define it
    # @return [Integer] the cache expiry time in seconds
    def cache_expiry
      provider.class.const_defined?(:CACHE_EXPIRY) ? provider.class::CACHE_EXPIRY : Providers::BaseProvider::CACHE_EXPIRY
    end
  end
end
