require "test_helper"

class UserTest < ActiveSupport::TestCase
  # TODO: memberships with associated downstream records should not be deletable
  test "destroying organization owner destroys organization" do
    organization = organizations(:one)
    user = users(:one)

    assert_difference "Organization.count", -1 do
      assert_difference "Membership.count", -1 do
        user.destroy
      end
    end

    # TODO: this should not be a valid state!
    assert organization.memberships.none?
  end

  test "destroying organization member (non-owner) does not destroy organization" do
    organization = organizations(:one)
    user = users(:unassociated)
    organization.memberships.create!(user:, role: Membership.roles[:admin])

    assert_no_difference "Organization.count" do
      assert_difference "Membership.count", -1 do
        user.destroy
      end
    end

    assert organization.memberships.any?
  end
end
