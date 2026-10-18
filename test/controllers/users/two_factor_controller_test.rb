# frozen_string_literal: true

require "test_helper"

class Users::TwoFactorControllerTest < ActionDispatch::IntegrationTest
  test "requires a fresh sudo session before setup" do
    sign_in users(:one)

    get new_user_two_factor_path

    assert_redirected_to new_sudo_path
  end

  test "shows setup after sudo verification" do
    user = users(:one)
    sign_in user
    authenticate_sudo user

    get new_user_two_factor_path

    assert_response :success
  end
end
