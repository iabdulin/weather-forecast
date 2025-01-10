require "test_helper"

class ForecastControllerTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
  end

  test "index action renders successfully" do
    get "/"
    assert_response :success
    assert_equal "text/html", @response.media_type
  end

  test "address_suggestions returns json format" do
    VCR.use_cassette("address_suggestions_json") do
      get "/forecast/address_suggestions.json?query=Edmonton"
      assert_response :success
      assert_equal "application/json", @response.media_type

      json = JSON.parse(@response.body)
      assert_kind_of Hash, json
    end
  end

  test "address_suggestions returns json format with mock provider" do
    get "/forecast/address_suggestions.json?query=test_query&provider=test"
    assert_response :success
    assert_equal "application/json", @response.media_type

    json = JSON.parse(@response.body)
    assert_equal "Mock Location 1", json["suggestions"][0]["label"]
    assert_equal "Mock Location 2", json["suggestions"][1]["label"]
    assert_kind_of Hash, json
  end

  test "returns json format when requested" do
    VCR.use_cassette("forecast_json") do
      get "/forecast.json?coordinates=53.5461,-113.4937"
      assert_response :success
      assert_equal "application/json", @response.media_type

      json = JSON.parse(@response.body)
      assert_equal "Edmonton", json["forecast"]["location"]["name"]
      assert_includes json.keys, "forecast"
      assert_includes json.keys, "timestamp"
    end
  end

  test "returns json format when requested with mock provider" do
    get "/forecast.json?coordinates=42.3600,-71.0589&provider=test"
    assert_response :success
    assert_equal "application/json", @response.media_type

    json = JSON.parse(@response.body)
    assert_equal "Mock City", json["forecast"]["location"]["name"]
    assert_includes json.keys, "forecast"
    assert_includes json.keys, "timestamp"
  end

  test "handles invalid coordinates" do
    get "/forecast.json?coordinates=invalid"
    assert_response :service_unavailable

    json = JSON.parse(@response.body)
    assert_includes json.keys, "error"
  end

  test "returns html format when requested" do
    url = "/forecast/53.5461,-113.4937"
    VCR.use_cassette("forecast_html") do
      get url
      assert_response :success
      assert_equal "text/html", @response.media_type

      assert_select "h1", "Weather Forecast"
      assert_select "h2", "Edmonton, Canada"
      assert_select "p", "Status: not cached"
    end
  end

  test "hits cache upon second request to similar coordinates" do
    coordinates = [53.5461, -113.4937]
    VCR.use_cassette("forecast_html") do
      get "/forecast/#{coordinates.join(",")}"
      assert_select "p", "Status: not cached"
    end

    coordinates = [53.51, -113.51]
    get "/forecast/#{coordinates.join(",")}"
    assert_select "p", "Status: cached 0 minutes ago"
  end

  test "returns html format when requested with mock provider" do
    get "/forecast/42.3600,-71.0589?provider=test"
    assert_response :success
    assert_equal "text/html", @response.media_type

    assert_select "h1", "Weather Forecast"
    assert_select "h2", "Mock City, Mock Country"
  end

  test "displays error in html format" do
    get "/forecast/invalid"
    assert_response :service_unavailable
    assert_equal "text/html", @response.media_type

    assert_select "h1", "Weather Service Unavailable"
  end
end
