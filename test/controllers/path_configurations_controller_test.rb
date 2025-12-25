# frozen_string_literal: true

require "test_helper"

class PathConfigurationsControllerTest < ActionDispatch::IntegrationTest
  test "android" do
    get "/hotwire_native/android/path_configuration"
    assert_response :success
  end

  test "ios" do
    get "/hotwire_native/ios/path_configuration"
    assert_response :success
    assert_match("pull_to_refresh_enabled", response.body)
    assert_no_match "Notifications", response.body

    sign_in users(:one)
    get "/hotwire_native/ios/path_configuration"
    assert_response :success
    assert_match "Notifications", response.body
  end
end
