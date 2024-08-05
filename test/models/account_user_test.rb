require "test_helper"

class AccountUserTest < ActiveSupport::TestCase
  test "unique user-account combination" do
    account_user = AccountUser.new(account: accounts(:one), user: users(:one))
    assert_not account_user.valid?
    assert_includes account_user.errors.messages[:user_id], "has already been taken"
    assert_includes account_user.errors.messages[:account_id], "has already been taken"
  end
end
