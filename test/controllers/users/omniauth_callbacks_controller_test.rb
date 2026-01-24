# frozen_string_literal: true

require "test_helper"

class Users::OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  include GoogleOauth2Helper

  setup do
    skip if Devise.omniauth_configs.keys.exclude?(:google_oauth2)
  end

  test "oauth success" do
    assert_difference "User.count", 1 do
      login_with_google_oauth2_oauth
    end

    assert_redirected_to user_organizations_path
    assert_response :found

    sign_out controller.current_user

    assert_no_difference "User.count" do
      login_with_google_oauth2_oauth
    end
  end

  test "oauth with existing connected account returns correct user" do
    # First, create a user and connected account
    user = users(:one)
    user.connected_accounts.create!(
      provider: "google_oauth2",
      uid: "test_uid_123",
      payload: { "info" => { "email" => "test@example.com" } }
    )

    # Mock the OAuth response to match the existing connected account
    mock_auth = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "test_uid_123",
      info: { email: "test@example.com" },
      credentials: {
        token: "mock_token",
        refresh_token: "mock_refresh_token",
        expires_at: Time.current.to_i
      }
    )
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = mock_auth
    Rails.application.env_config["omniauth.auth"] = mock_auth

    # Attempt to sign in with the same OAuth credentials
    assert_no_difference "User.count" do
      assert_no_difference "ConnectedAccount.count" do
        post user_google_oauth2_omniauth_callback_path
      end
    end

    # Should be redirected somewhere (app-specific)
    assert_response :redirect
    # Check that the user is signed in by verifying the session
    assert_equal user.id, session["warden.user.user.key"].first.first
    # NOTE: The redirect path may vary depending on app logic (e.g., /campaigns or /me/onboarding)
  end
end
