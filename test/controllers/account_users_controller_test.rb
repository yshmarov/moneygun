require "test_helper"

class AccountUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account_user = account_users(:one)

    @user = users(:one)
    @user2 = users(:two)
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

    assert_no_difference("User.count") do
      assert_no_difference("AccountUser.count") do
        post account_account_users_url(@account), params: { email: "foo" }
      end
    end
    assert_redirected_to new_account_account_user_url(@account)


    assert_difference("User.count") do
      assert_difference("AccountUser.count") do
        post account_account_users_url(@account), params: { email: }
      end
    end

    assert_redirected_to account_account_users_url
    assert @account.users.find_by(email:)
  end

  test "#destroy" do
    # does not destroy only account user
    assert_difference("AccountUser.count", 0) do
      delete account_account_user_url(@account, @account_user)
    end
    assert_redirected_to account_account_users_url

    # destroys another account user
    @account.users << @user2
    second_account_user = @account.account_users.find_by(user: @user2)
    assert_difference("AccountUser.count", -1) do
      delete account_account_user_url(@account, second_account_user)
    end

    # does not destroy only admin account user
    @account.users << @user2
    second_account_user = @account.account_users.find_by(user: @user2)
    assert_difference("AccountUser.count", 0) do
      delete account_account_user_url(@account, @account_user)
    end

    # destroys admin if there is another admin
    second_account_user.admin!
    assert_difference("AccountUser.count", -1) do
      delete account_account_user_url(@account, @account_user)
    end
  end
end
