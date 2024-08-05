require "application_system_test_case"

class DeviseAuthSystemTest < ApplicationSystemTestCase
  test "sign in existing user" do
    user = users(:one)
    sign_in user

    visit dashboard_path
    assert_current_path dashboard_path
    assert_text "Find me in app/views/static/dashboard.html.erb"
  end

  test "create user and sign in" do
    email = "julia@superails.com"
    password = "password"
    User.create(email:, password:)

    visit dashboard_path
    # visit new_user_session_path

    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Log in"

    assert_current_path dashboard_path
    assert_text "Signed in successfully."
  end
end
