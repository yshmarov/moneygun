require "test_helper"

class AccountUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account_user = account_users(:one)
  end

  test "should get index" do
    get account_users_url
    assert_response :success
  end

  test "should get new" do
    get new_account_user_url
    assert_response :success
  end

  test "should create account_user" do
    assert_difference("AccountUser.count") do
      post account_users_url, params: { account_user: { account_id: @account_user.account_id, role: @account_user.role, user_id: @account_user.user_id } }
    end

    assert_redirected_to account_user_url(AccountUser.last)
  end

  test "should show account_user" do
    get account_user_url(@account_user)
    assert_response :success
  end

  test "should get edit" do
    get edit_account_user_url(@account_user)
    assert_response :success
  end

  test "should update account_user" do
    patch account_user_url(@account_user), params: { account_user: { account_id: @account_user.account_id, role: @account_user.role, user_id: @account_user.user_id } }
    assert_redirected_to account_user_url(@account_user)
  end

  test "should destroy account_user" do
    assert_difference("AccountUser.count", -1) do
      delete account_user_url(@account_user)
    end

    assert_redirected_to account_users_url
  end
end
