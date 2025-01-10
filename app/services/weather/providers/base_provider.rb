module Weather
  module Providers
    class BaseProvider
      CACHE_EXPIRY = 30.minutes

      def get_forecast(coordinates)
        raise NotImplementedError, "Subclass #{self.class.name} must implement #get_forecast"
      end
    end
  end
end
