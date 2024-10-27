require "test_helper"

class UserTest < ActiveSupport::TestCase
  # TODO: memberships with associated downstream records should not be deletable
  test "destroying a user destroys associated memberships" do
    organization = organizations(:one)
    user = users(:one)

    assert_no_difference "Organization.count" do
      assert_difference "Membership.count", -1 do
        user.destroy
      end
    end

    # TODO: this should not be a valid state!
    assert organization.memberships.none?
  end
end
