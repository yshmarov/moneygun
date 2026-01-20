# frozen_string_literal: true

require "test_helper"

class AccessRequest::InviteToOrganizationTest < ActiveSupport::TestCase
  test "when created, sends invitation notification" do
    organization = organizations(:two)
    user = users(:three)

    assert_difference "Noticed::Notification.count", 1 do
      organization.sent_invitations.create!(user: user)
    end

    # Check that notification was sent to the correct user
    notification = user.notifications.last
    assert_equal "Membership::InvitationNotifier::Notification", notification.type
    assert_equal organization, notification.params[:organization]
  end

  test "when approved, creates a membership" do
    access_request = access_requests(:invite_to_organization_one)
    access_request.user
    assert_difference "Membership.count", 1 do
      access_request.approve!
    end

    assert_equal "approved", access_request.reload.status
  end

  test "when rejected, destroys the access request" do
    access_request = access_requests(:invite_to_organization_one)
    assert_no_difference "Membership.count" do
      assert_difference "AccessRequest.count", -1 do
        access_request.reject!
      end
    end

    assert_not AccessRequest.exists?(access_request.id)
  end
end
