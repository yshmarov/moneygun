# frozen_string_literal: true

require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @user_with_org = users(:one)
    @organization = organizations(:one)
  end

  test "after_sign_in_path_for" do
    user = User.create!(
      email: "noorg@example.com",
      password: "password123",
      confirmed_at: Time.current
    )

    post user_session_path, params: { user: { email: user.email, password: user.password } }
    assert_redirected_to organizations_path

    sign_out user

    post user_session_path, params: { user: { email: user.email, password: user.password } }
    assert_redirected_to organizations_path
  end
end
