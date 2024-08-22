require "application_system_test_case"

class AccountsTest < ApplicationSystemTestCase
  setup do
    @account = accounts(:one)
    @user = users(:one)
    sign_in @user
  end

  test "visiting the index" do
    skip
    visit accounts_url
    assert_selector "h1", text: "Accounts"
  end

  test "should create account" do
    skip
    visit accounts_url
    click_on "New account"

    fill_in "Name", with: @account.name
    click_on "Create Account"

    assert_text "Account was successfully created"
  end

  test "should update Account" do
    skip
    visit account_url(@account)
    click_on "Edit this account", match: :first

    fill_in "Name", with: @account.name
    click_on "Update Account"

    assert_text "Account was successfully updated"
  end

  test "should destroy Account" do
    skip
    visit account_url(@account)
    click_on "Destroy this account", match: :first

    assert_text "Account was successfully destroyed"
  end
end
