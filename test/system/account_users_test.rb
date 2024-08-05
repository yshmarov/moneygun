require "application_system_test_case"

class AccountUsersTest < ApplicationSystemTestCase
  setup do
    @account_user = account_users(:one)
  end

  test "visiting the index" do
    visit account_users_url
    assert_selector "h1", text: "Account users"
  end

  test "should create account user" do
    visit account_users_url
    click_on "New account user"

    fill_in "Account", with: @account_user.account_id
    fill_in "Role", with: @account_user.role
    fill_in "User", with: @account_user.user_id
    click_on "Create Account user"

    assert_text "Account user was successfully created"
    click_on "Back"
  end

  test "should update Account user" do
    visit account_user_url(@account_user)
    click_on "Edit this account user", match: :first

    fill_in "Account", with: @account_user.account_id
    fill_in "Role", with: @account_user.role
    fill_in "User", with: @account_user.user_id
    click_on "Update Account user"

    assert_text "Account user was successfully updated"
    click_on "Back"
  end

  test "should destroy Account user" do
    visit account_user_url(@account_user)
    click_on "Destroy this account user", match: :first

    assert_text "Account user was successfully destroyed"
  end
end
