# frozen_string_literal: true

require "test_helper"

class Sessions::TwoFactorControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @secret = ROTP::Base32.random
    @user.enable_two_factor!(@secret)
    verifier = Rails.application.message_verifier(:pending_two_factor)
    cookies[:pending_two_factor_token] = encrypt_cookie_value(
      :pending_two_factor_token,
      verifier.generate(@user.id, expires_at: 5.minutes.from_now)
    )
  end

  test "valid authenticator code completes sign in" do
    assert_difference "Session.count", 1 do
      post session_two_factor_path, params: { two_factor: { code: ROTP::TOTP.new(@secret).now } }
    end

    assert_redirected_to organizations_path
    assert_predicate cookies[:session_token], :present?
  end

  test "invalid code does not create a session" do
    assert_no_difference "Session.count" do
      post session_two_factor_path, params: { two_factor: { code: "000000" } }
    end

    assert_redirected_to new_session_two_factor_path
  end
end
