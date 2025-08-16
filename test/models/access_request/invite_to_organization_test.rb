require "test_helper"

class AccessRequest::InviteToOrganizationTest < ActiveSupport::TestCase
  test "when created, sends invitation notification" do
    organization = organizations(:two)
    user = users(:three)

    assert_difference "Noticed::Notification.count", 1 do
      invitation = organization.user_invitations.create!(user: user)
    end

    # Check that notification was sent to the correct user
    notification = user.notifications.last
    assert_equal "MembershipInvitationNotifier::Notification", notification.type
    assert_equal organization, notification.params[:organization]
  end

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
