require 'test_helper'

class ProjectPolicyTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @organization = organizations(:one)
    @membership = @organization.memberships.find_by(user: @user)
    @project1 = projects(:one)
    @project2 = projects(:two)
  end

  def test_index
    assert ProjectPolicy.new(@membership, @project1).index?
    # assert_not ProjectPolicy.new(@membership, @project2).index?

    user2 = users(:two)
    membership2 = @organization.memberships.create(user: user2, role: Membership.roles[:member])
    assert_not ProjectPolicy.new(membership2, @project1).index?

    membership2.update(role: Membership.roles[:admin])
    assert ProjectPolicy.new(membership2, @project1).index?
  end

  def test_show
    assert ProjectPolicy.new(@membership, @project1).show?
    # assert_not ProjectPolicy.new(@membership, @project2).show?
  end

  def test_create
    assert ProjectPolicy.new(@membership, @project1).create?
    # assert_not ProjectPolicy.new(@membership, @project2).create?
  end

  def test_update
    assert ProjectPolicy.new(@membership, @project1).update?
    # assert_not ProjectPolicy.new(@membership, @project2).update?
  end

  def test_destroy
    assert ProjectPolicy.new(@membership, @project1).destroy?
    # assert_not ProjectPolicy.new(@membership, @project2).destroy?
  end
end
