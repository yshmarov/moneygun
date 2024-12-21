require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "has_active_admin_when created" do
    # user creates an org
    # user has admin membership with active status
    # assert_equal "admin", membership.role
    # assert_equal "active", membership.invitation_status
    # assert_includes membership.errors.messages[:base], "Role cannot be changed because this is the only admin."
  end
end
