# frozen_string_literal: true

require "test_helper"

class DeviseAuthTest < ActionDispatch::IntegrationTest
  test "user can login" do
    get user_organizations_path
    assert_response :redirect
    assert_redirected_to new_user_session_path

    user = users(:one)
    sign_in user
    get user_organizations_path
    assert_response :success
  end
end
