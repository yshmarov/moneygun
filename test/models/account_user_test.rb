require "test_helper"

class AccountUserTest < ActiveSupport::TestCase
  test "unique user-account combination" do
    account_user = AccountUser.new(account: accounts(:one), user: users(:one))
    assert_not account_user.valid?
    assert_includes account_user.errors.messages[:user_id], "has already been taken"
    assert_includes account_user.errors.messages[:account_id], "has already been taken"
  end

  test "try_destroy" do
    # does not destroy only admin
    account = accounts(:one)
    account_user = account.account_users.first
    assert_not account_user.try_destroy

    # does not destroy only admin
    # destroys member
    new_account_user = account.account_users.create(user: users(:two), role: "member")
    assert_not account_user.try_destroy
    assert new_account_user.try_destroy

    # destroys admin if there is another admin
    new_account_user = account.account_users.create(user: users(:two), role: "admin")
    assert account_user.try_destroy
    assert_not new_account_user.try_destroy
  end

  test "cannot_change_role_if_only_admin" do
    account = accounts(:one)
    account_user = account.account_users.find_by(role: "admin")

    account_user.role = "member"
    assert_not account_user.save
    assert_includes account_user.errors.messages[:base], "Role cannot be changed because this is the only admin."
  end
end
