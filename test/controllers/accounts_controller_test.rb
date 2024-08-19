require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)

    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get accounts_url
    assert_response :success

    # displays only accounts that the user is a member of
    assert_match @account.name, response.body
    account2 = accounts(:two)
    assert_no_match account2.name, response.body
  end

  test "should get new" do
    get new_account_url
    assert_response :success
  end

  test "should create account" do
    assert_difference("Account.count") do
      post accounts_url, params: { account: { name: @account.name } }
    end

    assert_redirected_to account_url(Account.last)
    assert_equal @user, Account.last.users.first
    assert_equal "admin", @user.account_users.last.role
  end

  test "should show account" do
    get account_url(@account)
    assert_response :success

    # does not show account if user is not a member
    account = accounts(:two)
    get account_url(account)
    assert_redirected_to root_url
  end

  test "should get edit" do
    get edit_account_url(@account)
    assert_response :success
  end

  test "should update account" do
    patch account_url(@account), params: { account: { name: @account.name } }
    assert_redirected_to account_url(@account)
  end

  test "should destroy account" do
    account_user = @account.account_users.find_by(user: @user)
    account_user.update!(role: AccountUser.roles[:member])

    assert_no_difference("Account.count") do
      delete account_url(@account)
    end

    account_user.update!(role: AccountUser.roles[:admin])
    assert_difference("Account.count", -1) do
      delete account_url(@account)
    end

    assert_redirected_to accounts_url
  end
end
