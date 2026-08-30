# frozen_string_literal: true

require "test_helper"

class MembershipPolicyTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @organization = organizations(:one)
    @membership = @organization.memberships.find_by(user: @user)
  end

  def test_edit
    assert_not MembershipPolicy.new(@membership, @membership).edit?

    user2 = users(:two)
    membership2 = @organization.memberships.create(user: user2, role: :member)
    assert_not MembershipPolicy.new(membership2, @membership).edit?

    membership2.update(role: :admin)
    assert_not MembershipPolicy.new(membership2, @membership).edit?
    assert MembershipPolicy.new(@membership, membership2).edit?
  end

  def test_update
    assert_not MembershipPolicy.new(@membership, @membership).update?
  end

  def test_destroy
    assert_not MembershipPolicy.new(@membership, @membership).destroy?
  end
end
