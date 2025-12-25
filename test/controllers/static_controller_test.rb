# frozen_string_literal: true

require "test_helper"

class StaticControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success

    sign_in users(:one)
    get root_url
    assert_redirected_to organizations_path
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

  test "should get refunds" do
    get refunds_url
    assert_response :success
  end

  test "should get reset_app" do
    get reset_app_url
    assert_response :success
  end
end
