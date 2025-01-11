module Weather
  module Providers
    # @abstract Base class for weather forecast providers
    # Defines the interface and common functionality for all weather providers.
    # Each provider must implement the {#get_forecast} method.
    class BaseProvider
      # @return [ActiveSupport::Duration] Duration for which results should be cached
      CACHE_EXPIRY = 30.minutes

      # Retrieves weather forecast for given coordinates
      # @param coordinates [String] Location coordinates in "latitude,longitude" format
      # @return [Hash] Weather forecast data
      # @raise [NotImplementedError] if the subclass doesn't implement this method
      def get_forecast(coordinates)
        raise NotImplementedError, "Subclass #{self.class.name} must implement #get_forecast"
      end
    end
  end
end
