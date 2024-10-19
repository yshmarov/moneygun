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

    # user is not a member of the account
    get account_account_users_url(accounts(:two))
    assert_response :not_found
  end

  test "should get new" do
    # admin can invite new account user
    get new_account_account_user_url(@account)
    assert_response :success

    # user is not account user
    sign_in @user2
    get new_account_account_user_url(@account)
    assert_response :not_found

    # user is account member
    @account.account_users.create(user: @user2, role: "member")
    sign_in @user2
    get new_account_account_user_url(@account)
    assert_response :redirect
  end

  test "should create account_user" do
    email = "julia@superails.com"

    # nil email
    assert_no_difference("User.count") do
      assert_no_difference("AccountUser.count") do
        post account_account_users_url(@account), params: { invite_account_user_form: { email: nil } }
      end
    end
    assert_response :unprocessable_entity

    # invalid email
    assert_no_difference("User.count") do
      assert_no_difference("AccountUser.count") do
        post account_account_users_url(@account), params: { invite_account_user_form: { email: "foo" } }
      end
    end
    assert_response :unprocessable_entity

    # missing role
    assert_no_difference("User.count") do
      assert_no_difference("AccountUser.count") do
        post account_account_users_url(@account), params: { invite_account_user_form: { email: } }
      end
    end
    assert_response :unprocessable_entity

    # success
    assert_difference("User.count") do
      assert_difference("AccountUser.count") do
        post account_account_users_url(@account), params: { invite_account_user_form: { email:, role: "member" } }
      end
    end

    assert_redirected_to account_account_users_url
    assert @account.users.find_by(email:)

    # when user is already a member
    assert_no_difference("User.count") do
      assert_no_difference("AccountUser.count") do
        post account_account_users_url(@account), params: { invite_account_user_form: { email: } }
      end
    end
    assert_response :unprocessable_entity
  end

  test "#edit" do
    # admin can edit himself
    get edit_account_account_user_url(@account, @account_user)
    assert_response :success

    # admin can edit other account user
    @account.users << @user2
    second_account_user = @account.account_users.find_by(user: @user2)
    get edit_account_account_user_url(@account, second_account_user)
    assert_response :success

    # only admin can edit account user
    sign_in @user2
    get edit_account_account_user_url(@account, @account_user)
    assert_response :redirect
  end

  test "#update" do
    # admin can't make himself a member
    patch account_account_user_url(@account, @account_user), params: { account_user: { role: "member" } }
    assert_response :unprocessable_entity
    assert @account_user.reload.admin?
    assert_match "Role cannot be changed because this is the only admin.", response.body

    # admin can update other account user
    @account.users << @user2
    second_account_user = @account.account_users.find_by(user: @user2)
    patch account_account_user_url(@account, second_account_user), params: { account_user: { role: "admin" } }
    assert_redirected_to account_account_users_url
    assert second_account_user.reload.admin?

    # can not update account user with invalid role
    assert_raises(ArgumentError) do
      patch account_account_user_url(@account, second_account_user), params: { account_user: { role: "foo" } }
    end

    # member can not update account user
    first_account_user = @account.account_users.find_by(user: @user)
    first_account_user.member!
    patch account_account_user_url(@account, second_account_user), params: { account_user: { role: "member" } }
    assert_redirected_to root_url
    assert second_account_user.reload.admin?
  end

  test "#destroy" do
    # does not destroy only account user
    assert_difference("AccountUser.count", 0) do
      delete account_account_user_url(@account, @account_user)
    end
    assert_redirected_to account_account_users_url
    follow_redirect!
    assert_response :success

    # destroys another account user
    @account.users << @user2
    second_account_user = @account.account_users.find_by(user: @user2)
    assert_difference("AccountUser.count", -1) do
      delete account_account_user_url(@account, second_account_user)
    end
    assert_redirected_to account_account_users_url
    follow_redirect!
    assert_response :success

    # does not destroy only admin account user
    @account.users << @user2
    second_account_user = @account.account_users.find_by(user: @user2)
    assert_difference("AccountUser.count", 0) do
      delete account_account_user_url(@account, @account_user)
    end
    assert_redirected_to account_account_users_url
    follow_redirect!
    assert_response :success

    # destroys admin if there is another admin
    second_account_user.admin!
    assert_difference("AccountUser.count", -1) do
      delete account_account_user_url(@account, @account_user)
    end
    assert_redirected_to accounts_path
    follow_redirect!
    assert_response :success
  end
end
