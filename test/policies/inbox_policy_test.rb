require "test_helper"

class InboxPolicyTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @organization = organizations(:one)
    @membership = @organization.memberships.find_by(user: @user)
    @inbox1 = inboxes(:one)
    @inbox2 = inboxes(:two)
  end

  def test_index
    assert InboxPolicy.new(@membership, @inbox1).index?
    assert_not InboxPolicy.new(@membership, @inbox2).index?

    user2 = users(:two)
    membership2 = @organization.memberships.create(user: user2, role: Membership.roles[:member])
    assert_not InboxPolicy.new(membership2, @inbox1).index?

    membership2.update(role: Membership.roles[:admin])
    assert InboxPolicy.new(membership2, @inbox1).index?
  end

  def test_show
    assert InboxPolicy.new(@membership, @inbox1).show?
    assert_not InboxPolicy.new(@membership, @inbox2).show?
  end

  def test_create
    assert InboxPolicy.new(@membership, @inbox1).create?
    assert_not InboxPolicy.new(@membership, @inbox2).create?
  end

  def test_update
    assert InboxPolicy.new(@membership, @inbox1).update?
    assert_not InboxPolicy.new(@membership, @inbox2).update?
  end

  def test_destroy
    assert InboxPolicy.new(@membership, @inbox1).destroy?
    assert_not InboxPolicy.new(@membership, @inbox2).destroy?
  end
end
