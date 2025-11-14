# frozen_string_literal: true

require "test_helper"

class OrganizationPolicyTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @organization = organizations(:one)
    @membership = @organization.memberships.find_by(user: @user)
  end

  def test_show
    assert OrganizationPolicy.new(@membership, @organization).show?
    @organization.users.delete(@user)
    assert_not OrganizationPolicy.new(@membership, @organization).show?
  end

  def test_edit
    assert OrganizationPolicy.new(@membership, @organization).edit?

    @new_membership = @organization.memberships.create(user: users(:two), role: Membership.roles[:member])
    assert_not OrganizationPolicy.new(@new_membership, @organization).edit?
  end

  def test_update
    assert OrganizationPolicy.new(@membership, @organization).update?
  end

  def test_destroy
    assert OrganizationPolicy.new(@membership, @organization).destroy?
    assert_not OrganizationPolicy.new(memberships(:two), @organization).destroy?
  end
end
