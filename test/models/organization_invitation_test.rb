# frozen_string_literal: true

require "test_helper"

class OrganizationInvitationTest < ActiveSupport::TestCase
  test "should not be valid if user already has an invitation for that organization" do
    invitation = OrganizationInvitation.new(user: users(:unassociated), organization: organizations(:one))
    assert_not invitation.valid?
    assert_includes invitation.errors.messages[:user_id], I18n.t("errors.messages.already_has_pending_request")
  end

  test "should return only pending invitations" do
    rejected_invitation = OrganizationInvitation.create!(status: :rejected, user: users(:one), organization: organizations(:one))
    pending_invitations = OrganizationInvitation.pending

    assert_equal 2, pending_invitations.count
    assert_includes pending_invitations, organization_invitations(:one)
    assert_includes pending_invitations, organization_invitations(:two)
    assert_not_includes pending_invitations, rejected_invitation
  end

  test "when created, sends invitation notification" do
    organization = organizations(:two)
    user = users(:three)

    assert_difference "Noticed::Notification.count", 1 do
      organization.sent_invitations.create!(user: user)
    end

    notification = user.notifications.last
    assert_equal "Membership::InvitationNotifier::Notification", notification.type
    assert_equal organization, notification.params[:organization]
  end

  test "when approved, creates a membership" do
    invitation = organization_invitations(:one)
    assert_difference "Membership.count", 1 do
      invitation.approve!
    end

    assert_equal "approved", invitation.reload.status
  end

  test "when rejected, destroys the invitation" do
    invitation = organization_invitations(:one)
    assert_no_difference "Membership.count" do
      assert_difference "OrganizationInvitation.count", -1 do
        invitation.reject!
      end
    end

    assert_not OrganizationInvitation.exists?(invitation.id)
  end
end
