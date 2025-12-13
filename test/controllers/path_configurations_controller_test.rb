# frozen_string_literal: true

require "test_helper"

class PathConfigurationsControllerTest < ActionDispatch::IntegrationTest
  test "android" do
    get "/hotwire_native/v1/android/path_configuration"
    assert_response :success
  end

  test "ios" do
    get "/hotwire_native/v1/ios/path_configuration"
    assert_response :success
    assert_match("pull_to_refresh_enabled", response.body)
  end
end
