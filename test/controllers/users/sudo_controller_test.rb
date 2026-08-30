# frozen_string_literal: true

require "test_helper"

class Users::SudoControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "email challenge grants recent authentication" do
    get new_sudo_path
    magic_link = @user.magic_links.for_sudo.last

    post sudo_path, params: { code: magic_link.code }

    assert_redirected_to organizations_path
    assert_no_difference "MagicLink.count" do
      post sudo_path, params: { code: magic_link.code }
    end
    assert_response :unprocessable_content
  end

  test "two-factor users authenticate without an email challenge" do
    secret = ROTP::Base32.random
    @user.enable_two_factor!(secret)

    assert_no_difference "MagicLink.count" do
      get new_sudo_path
    end

    post sudo_path, params: { code: ROTP::TOTP.new(secret).now }
    assert_redirected_to organizations_path
  end
end
