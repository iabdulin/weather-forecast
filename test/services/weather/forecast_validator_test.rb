require "test_helper"

class Weather::ForecastValidatorTest < ActiveSupport::TestCase
  setup do
    @valid_forecast = {
      location: {
        name: "Edmonton",
        country: "Canada",
        lat: 53.5461,
        lon: -113.4937
      },
      current: {
        temp_c: 10.0,
        is_day: 1,
        wind_kph: 10.0,
        wind_dir: "N",
        humidity: 10,
        feelslike_c: 10.0,
        condition: {
          text: "Sunny",
          icon: "sunny.png"
        }
      },
      forecast: [{
        "date" => "2024-03-20",
        "condition" => {
          "text" => "Cloudy",
          "icon" => "cloudy.png"
        },
        "maxtemp_c" => 15.5,
        "mintemp_c" => 8.0,
        "avghumidity" => 75,
        "maxwind_kph" => 20.5
      }]
    }.with_indifferent_access
  end

  test "validates valid forecast" do
    assert Weather::ForecastValidator.validate!(@valid_forecast)
  end

  test "raises error for nil forecast" do
    error = assert_raises(Weather::Error) do
      Weather::ForecastValidator.validate!(nil)
    end
    assert_equal "Forecast cannot be nil", error.message
  end

  test "raises error for missing location fields" do
    @valid_forecast["location"].delete("name")

    error = assert_raises(Weather::Error) do
      Weather::ForecastValidator.validate!(@valid_forecast)
    end
    assert_equal "Missing key: location.name", error.message
  end

  test "raises error when forecast array contains invalid items" do
    @valid_forecast["forecast"] = "not an array"

    error = assert_raises(Weather::Error) do
      Weather::ForecastValidator.validate!(@valid_forecast)
    end
    assert_equal "Expected Array for forecast", error.message
  end
end
