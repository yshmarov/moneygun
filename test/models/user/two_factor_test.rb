# frozen_string_literal: true

require "test_helper"

class User::TwoFactorTest < ActiveSupport::TestCase
  test "enabling two-factor authentication creates one-time backup codes" do
    user = users(:one)
    secret = ROTP::Base32.random

    codes = user.enable_two_factor!(secret)

    assert_predicate user, :two_factor_enabled?
    assert_equal User::TwoFactor::BACKUP_CODE_COUNT, codes.size
    assert user.verify_otp(ROTP::TOTP.new(secret).now)
    assert user.verify_otp(codes.first)
    assert_not user.verify_otp(codes.first)
    assert_equal User::TwoFactor::BACKUP_CODE_COUNT - 1, user.remaining_backup_codes_count
  end

  test "disabling two-factor authentication clears every credential" do
    user = users(:one)
    user.enable_two_factor!(ROTP::Base32.random)

    user.disable_two_factor!

    assert_not_predicate user, :two_factor_enabled?
    assert_nil user.otp_secret
    assert_nil user.otp_backup_codes
  end
end
