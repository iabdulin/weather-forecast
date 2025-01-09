module AddressSuggestions
  module Providers
    # Provides address suggestions and geocoding functionality using the Mapbox
    class MapboxProvider < BaseProvider
      def initialize
        Geocoder.configure(
          lookup: :mapbox,
          api_key: Rails.application.credentials.mapbox_api_key!,
          timeout: 5,
          units: :km
        )
      end

      # Searches for address suggestions based on the provided query
      # @param query [String] the search query for address lookup
      # @return [Array<Hash>] array of formatted address suggestions with the following keys:
      #   - :label [String] human-readable address for display
      #   - :coordinates [String] comma-separated latitude and longitude for weather api request
      #   - :country_code [String] two-letter country code or "unknown" for emoji flag
      # @raise [InvalidResponseError] if the response is invalid
      def search(query)
        Geocoder.search(query).map { |result|
          Rails.logger.info("Result: #{result}")
          {
            label: result.address,
            coordinates: result.coordinates.join(","),
            country_code: result.country_code || "unknown"
          }
        }
      end
    end
  end
end
