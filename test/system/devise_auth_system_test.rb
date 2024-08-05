require "application_system_test_case"

class DeviseAuthSystemTest < ApplicationSystemTestCase
  test "sign in existing user" do
    user = users(:one)
    sign_in user

    visit accounts_path
    assert_current_path accounts_path
    assert_text "New account"
  end

  test "create user and sign in" do
    email = "julia@superails.com"
    password = "password"
    User.create(email:, password:)

    visit accounts_path
    # visit new_user_session_path

    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Log in"

    assert_current_path accounts_path
    assert_text "Signed in successfully."
  end
end
