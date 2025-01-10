require "test_helper"

class ForecastControllerTest < ActionDispatch::IntegrationTest
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
end
