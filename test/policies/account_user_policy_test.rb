require "test_helper"

class AccountUserPolicyTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @account = accounts(:one)
    @account_user = @account.account_users.find_by(user: @user)
  end

  def test_edit
    assert AccountUserPolicy.new(@user, @account_user).edit?

    user2 = users(:two)
    assert_not AccountUserPolicy.new(user2, @account_user).edit?

    account_user2 = @account.account_users.create(user: user2, role: AccountUser.roles[:member])
    assert_not AccountUserPolicy.new(user2, @account_user).edit?

    account_user2.update(role: AccountUser.roles[:admin])
    assert AccountUserPolicy.new(user2, @account_user).edit?
  end

  def test_update
    assert AccountUserPolicy.new(@user, @account_user).update?
  end

  def test_destroy
    assert AccountUserPolicy.new(@user, @account_user).destroy?
  end
end
