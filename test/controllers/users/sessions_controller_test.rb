# frozen_string_literal: true

require "test_helper"

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "lists the current user's sessions" do
    sign_in users(:one)

    get user_sessions_path

    assert_response :success
  end

  test "destroys another session without ending the current one" do
    user = users(:one)
    sign_in user
    other = user.sessions.create!

    assert_difference "Session.count", -1 do
      delete user_session_path(other)
    end

    assert_redirected_to user_sessions_path
  end
end
