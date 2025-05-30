require "test_helper"

class AccessRequest::InviteToOrganizationTest < ActiveSupport::TestCase
  test "when approved, creates a membership" do
    access_request = access_requests(:invite_to_organization_one)
    user = access_request.user
    assert_difference "Membership.count", 1 do
      access_request.approve!
    end

    assert_equal "approved", access_request.reload.status
  end

  test "when rejected, updates the access request status" do
    access_request = access_requests(:invite_to_organization_one)
    assert_difference "Membership.count", 0 do
      access_request.reject!
    end

    assert_equal "rejected", access_request.reload.status
  end
end
