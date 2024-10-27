require "test_helper"

class OrganizationPolicyTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @organization = organizations(:one)
    @membership = @organization.memberships.find_by(user: @user)
  end

  def test_show
    assert OrganizationPolicy.new(@user, @organization).show?
    @organization.users.delete(@user)
    assert_not OrganizationPolicy.new(@user, @organization).show?
  end

  def test_edit
    assert OrganizationPolicy.new(@user, @organization).edit?
  end

  def test_update
    assert OrganizationPolicy.new(@user, @organization).show?
  end

  def test_destroy
    assert OrganizationPolicy.new(@user, @organization).show?
  end
end
