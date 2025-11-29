# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should redirect to sign in when not authenticated" do
    get user_url
    assert_redirected_to new_user_session_url
  end

  test "should get show when authenticated" do
    sign_in @user
    get user_url
    assert_response :success
  end
end
