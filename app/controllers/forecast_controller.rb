class ForecastController < ApplicationController
  # The index action displays the home page
  def index
  end

  # The show action displays weather forecast for a given address and coordinates
  # It accepts a provider parameter to specify which weather service to use, defaults to WeatherApiComProvider
  # Returns HTML or JSON response with forecast data
  # If the weather service fails, returns a 503 error response
  def show
    coordinates = params[:coordinates]
    weather_service = Weather::WeatherService.new(provider_name: params[:provider])

    begin
      @forecast = weather_service.get_forecast(coordinates)
      @current_location = "#{@forecast.dig("forecast", "location", "name")}, #{@forecast.dig("forecast", "location", "country")}"
      respond_to do |format|
        format.html
        format.json { render json: @forecast }
      end
    rescue Weather::Error => e
      Rails.logger.error("Weather service error: #{e.class.name.demodulize} - #{e.message}")
      respond_to do |format|
        format.html { render "error", status: :service_unavailable }
        format.json { render json: {error: "Weather service unavailable"}, status: :service_unavailable }
      end
    end
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
