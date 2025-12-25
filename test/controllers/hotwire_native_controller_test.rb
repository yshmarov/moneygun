# frozen_string_literal: true

require "test_helper"

class HotwireNativeTest < ActionDispatch::IntegrationTest
  test "zoom is disabled for native" do
    get root_path, headers: { HTTP_USER_AGENT: "Hotwire Native" }
    assert_response :success
    assert_match(/user-scalable=0/, response.body)
  end

  test "zoom is enabled for web" do
    get root_path
    assert_response :success
    assert_no_match(/user-scalable=0/, response.body)
  end
end
