module Weather
  # Validates weather forecast data against a predefined structure
  # to ensure all required fields are present and of the correct type
  class ForecastValidator
    # Template defining the expected structure and types for a valid forecast
    VALID_FORECAST_TEMPLATE = {
      "location" => {
        "name" => String,
        "country" => String
      },
      "current" => {
        "temp_c" => Numeric,
        "is_day" => Integer,
        "wind_kph" => Numeric,
        "wind_dir" => String,
        "humidity" => Integer,
        "feelslike_c" => Numeric,
        "condition" => {
          "text" => String,
          "icon" => String
        }
      },
      "forecast" => Array
    }

    # Template defining the expected structure and types for a valid forecast day
    FORECAST_DAY_TEMPLATE = {
      "date" => String,
      "condition" => {
        "text" => String,
        "icon" => String
      },
      "maxtemp_c" => Numeric,
      "mintemp_c" => Numeric,
      "avghumidity" => Integer,
      "maxwind_kph" => Numeric
    }

    # Validates the given forecast by creating a new instance and calling validate!
    #
    # @param forecast [Hash] The forecast data to validate
    # @return [true] if validation passes
    # @raise [Weather::Error] if validation fails
    def self.validate!(forecast)
      new(forecast).validate!
    end

    # Initialize a new validator instance
    #
    # @param forecast [Hash] The forecast data to validate
    def initialize(forecast)
      @forecast = forecast
    end

    # Performs the validation of the forecast data
    #
    # @return [true] if validation passes
    # @raise [Weather::Error] if validation fails
    # @raise [Weather::Error] if forecast format is invalid
    def validate!
      validate_structure!
      true
    rescue NoMethodError, TypeError => e
      Rails.logger.error("Invalid forecast format: #{e.message}")
      raise Weather::Error, "Invalid forecast format: #{e.message}"
    end

    private

    attr_reader :forecast

    # Validates the basic structure of the forecast data
    #
    # @raise [Weather::Error] if forecast is nil
    # @raise [Weather::Error] if forecast is not a hash
    def validate_structure!
      raise Weather::Error, "Forecast cannot be nil" if forecast.nil?
      raise Weather::Error, "Forecast must be a hash" unless forecast.is_a?(Hash)

      validate_against_template!(forecast, VALID_FORECAST_TEMPLATE)
    end

    # Recursively validates data against a template structure
    #
    # @param data [Hash] The data to validate
    # @param template [Hash] The template to validate against
    # @param prefix [String] The current key path for error messages
    # @raise [Weather::Error] if validation fails
    def validate_against_template!(data, template, prefix: "")
      template.each do |key, expected_type|
        value = data[key]
        raise Weather::Error, "Missing key: #{prefix}#{key}" if value.nil?
        if expected_type == Hash || value.is_a?(Hash)
          raise Weather::Error, "Expected Hash for #{prefix}#{key}" unless value.is_a?(Hash)
          validate_against_template!(value, expected_type, prefix: "#{prefix}#{key}.")
        elsif expected_type == Array
          raise Weather::Error, "Expected Array for #{prefix}#{key}" unless value.is_a?(Array)
          value.each { |day| validate_against_template!(day, FORECAST_DAY_TEMPLATE, prefix: "#{prefix}#{key}.") }
        end
      end
    end
  end
end
