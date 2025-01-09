class ForecastController < ApplicationController
  # The index action displays the home page
  def index
  end

  # Returns a JSON response with address suggestions for a given query
  def address_suggestions
    query = params[:query]
    suggestions_service = AddressSuggestions::SuggestionsService.new(provider_name: params[:provider])
    suggestions = suggestions_service.get_suggestions(query)
    Rails.logger.info("Suggestions: #{suggestions}")
    render json: suggestions
  end
end
