module AddressSuggestions
  module Providers
    class MockProvider < BaseProvider
      def search(query)
        [
          {
            label: "Mock Location 1",
            coordinates: "40.7128,-74.0060",
            country_code: "CA"
          },
          {
            label: "Mock Location 2",
            coordinates: "51.5074,-0.1278",
            country_code: "US"
          }
        ]
      end
    end
  end
end
