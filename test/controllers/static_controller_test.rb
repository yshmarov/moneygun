require "test_helper"

class StaticControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should get dashboard" do
    get dashboard_url
    assert_redirected_to new_user_session_url
    user = users(:one)
    sign_in user
    get dashboard_url
    assert_response :success
  end

  test "should get pricing" do
    get pricing_url
    assert_response :success
  end

  test "should get terms" do
    get terms_url
    assert_response :success
  end

  test "should get privacy" do
    get privacy_url
    assert_response :success
  end
end
