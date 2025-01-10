module AddressSuggestions
  module Providers
    # @abstract Base class for address suggestion providers
    # Defines the interface and common functionality for all address suggestion services.
    # Each provider must implement the {#search} method.
    class BaseProvider
      # @return [ActiveSupport::Duration] Duration for which results should be cached
      CACHE_EXPIRY = 30.minutes

      # Search for address suggestions based on a query string
      # @param query [String] The search query for address suggestions
      # @return [Array<Hash>] Array of address suggestions
      # @raise [NotImplementedError] if the subclass doesn't implement this method
      def search(query)
        raise NotImplementedError, "#{self.class} must implement #search"
      end
    end
  end
end
