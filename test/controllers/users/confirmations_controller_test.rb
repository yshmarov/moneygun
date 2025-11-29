# frozen_string_literal: true

require "test_helper"

class Users::ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  test "user is signed in after confirming email" do
    # Create an unconfirmed user
    user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: nil
    )

    assert_not user.confirmed?
    assert_nil user.confirmed_at

    # Generate confirmation token by sending confirmation instructions
    user.send_confirmation_instructions
    user.reload
    confirmation_token = user.confirmation_token
    assert_not_nil confirmation_token

    # Visit the confirmation URL
    get user_confirmation_path(confirmation_token: confirmation_token)

    # Reload user to get updated confirmed_at
    user.reload

    # Verify user is confirmed
    assert user.confirmed?
    assert_not_nil user.confirmed_at

    # Verify user is signed in by checking session
    assert_response :redirect
    # Check that the user is signed in by verifying the session
    assert_equal user.id, session["warden.user.user.key"].first.first
  end
end
