require "test_helper"

class InboxPolicyTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @account = accounts(:one)
    @account_user = @account.account_users.find_by(user: @user)
    @inbox1 = inboxes(:one)
    @inbox2 = inboxes(:two)
  end

  def test_index
    assert InboxPolicy.new(@user, @inbox1).index?
    assert_not InboxPolicy.new(@user, @inbox2).index?

    user2 = users(:two)
    assert_not AccountUserPolicy.new(user2, @account_user).edit?

    account_user2 = @account.account_users.create(user: user2, role: AccountUser.roles[:member])
    assert_not InboxPolicy.new(user2, @inbox1).index?

    account_user2.update(role: AccountUser.roles[:admin])
    assert InboxPolicy.new(user2, @inbox1).index?
  end

  def test_show
    assert InboxPolicy.new(@user, @inbox1).show?
    assert_not InboxPolicy.new(@user, @inbox2).show?
  end

  def test_create
    assert InboxPolicy.new(@user, @inbox1).create?
    assert_not InboxPolicy.new(@user, @inbox2).create?
  end

  def test_update
    assert InboxPolicy.new(@user, @inbox1).update?
    assert_not InboxPolicy.new(@user, @inbox2).update?
  end

  def test_destroy
    assert InboxPolicy.new(@user, @inbox1).destroy?
    assert_not InboxPolicy.new(@user, @inbox2).destroy?
  end
end
