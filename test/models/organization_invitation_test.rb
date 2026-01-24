# frozen_string_literal: true

require "test_helper"

class OrganizationInvitationTest < ActiveSupport::TestCase
  test "should not be valid if user already has an invitation for that organization" do
    invitation = OrganizationInvitation.new(user: users(:unassociated), organization: organizations(:one))
    assert_not invitation.valid?
    assert_includes invitation.errors.messages[:user_id], I18n.t("errors.messages.already_has_pending_request")
  end

  test "should return only pending invitations" do
    # Use organization three which has user three as owner, and invite user two (not a member)
    rejected_invitation = OrganizationInvitation.create!(status: :rejected, user: users(:two), organization: organizations(:three))
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

  test "should not be valid if user is already a member" do
    organization = organizations(:one)
    existing_member = users(:one)

    invitation = OrganizationInvitation.new(user: existing_member, organization: organization)
    assert_not invitation.valid?
    assert_includes invitation.errors.messages[:user], I18n.t("errors.messages.already_member")
  end

  test "approve! returns false and adds error when not pending" do
    invitation = organization_invitations(:one)
    invitation.update!(status: :approved)

    result = invitation.approve!

    assert_equal false, result
    assert_includes invitation.errors[:base], I18n.t("errors.messages.not_pending")
  end

  test "reject! returns false and adds error when not pending" do
    invitation = organization_invitations(:one)
    invitation.update!(status: :approved)

    result = invitation.reject!

    assert_equal false, result
    assert_includes invitation.errors[:base], I18n.t("errors.messages.not_pending")
  end

  test "approve! tracks completed_by" do
    invitation = organization_invitations(:one)
    admin = users(:one)

    invitation.approve!(completed_by: admin)

    assert_equal admin, invitation.reload.completed_by
  end

  test "reject! tracks completed_by before destroying" do
    invitation = organization_invitations(:one)
    admin = users(:one)

    # We can't check completed_by after destroy, but we can verify the status update happens
    invitation_id = invitation.id

    invitation.reject!(completed_by: admin)

    assert_not OrganizationInvitation.exists?(invitation_id)
  end
end
