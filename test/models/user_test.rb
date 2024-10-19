require "test_helper"

class UserTest < ActiveSupport::TestCase
  # TODO: account_users with associated downstream records should not be deletable
  test "destroying a user destroys associated account_users" do
    account = accounts(:one)
    user = users(:one)

    assert_no_difference "Account.count" do
      assert_difference "AccountUser.count", -1 do
        user.destroy
      end
    end

    # TODO: this should not be a valid state!
    assert account.account_users.none?
  end
end
