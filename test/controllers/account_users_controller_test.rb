require "test_helper"

class AccountUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account_user = account_users(:one)

    @user = users(:one)
    @account = accounts(:one)
    sign_in @user
  end

  test "should get index" do
    get account_account_users_url(@account)
    assert_response :success
    assert_match @account_user.user.email, response.body
  end

  test "should get new" do
    get new_account_account_user_url(@account)
    assert_response :success
  end

  test "should create account_user" do
    email = "julia@superails.com"

    assert_difference("User.count") do
      assert_difference("AccountUser.count") do
        post account_account_users_url(@account), params: { email: }
      end
    end

    assert_redirected_to account_account_users_url
    assert @account.users.find_by(email:)
  end
end
