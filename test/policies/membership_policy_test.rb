require "test_helper"

class MembershipPolicyTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @organization = organizations(:one)
    @membership = @organization.memberships.find_by(user: @user)
  end

  def test_edit
    assert MembershipPolicy.new(@user, @membership).edit?

    user2 = users(:two)
    assert_not MembershipPolicy.new(user2, @membership).edit?

    membership2 = @organization.memberships.create(user: user2, role: Membership.roles[:member])
    assert_not MembershipPolicy.new(user2, @membership).edit?

    membership2.update(role: Membership.roles[:admin])
    assert MembershipPolicy.new(user2, @membership).edit?
  end

  def test_update
    assert MembershipPolicy.new(@user, @membership).update?
  end

  def test_destroy
    assert MembershipPolicy.new(@user, @membership).destroy?
  end
end
