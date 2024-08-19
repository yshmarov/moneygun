require "test_helper"

class AccountUserPolicyTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @account = accounts(:one)
    @account_user = @account.account_users.find_by(user: @user)
  end

  def test_edit
    assert AccountUserPolicy.new(@user, @account_user).edit?
    @account_user.update(role: AccountUser.roles[:member])
    assert_not AccountUserPolicy.new(@user, @account_user).edit?
  end

  def test_update
    assert AccountUserPolicy.new(@user, @account_user).update?
  end

  def test_destroy
    assert AccountUserPolicy.new(@user, @account_user).destroy?
  end
end
