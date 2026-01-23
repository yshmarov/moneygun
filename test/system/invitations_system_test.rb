# frozen_string_literal: true

require "application_system_test_case"

class InvitationsSystemTest < ApplicationSystemTestCase
  setup do
    @admin = users(:one)
    @organization = organizations(:one)
    @unassociated_user = users(:unassociated)
  end

  test "admin can send an invitation to a new user" do
    sign_in @admin

    visit organization_memberships_path(@organization)
    assert_text "Members"

    # Click to invite a new member
    click_link I18n.t("organizations.memberships.new.title")

    # Fill in the email and submit
    fill_in "Email", with: "newmember@example.com"
    click_button "Invite"

    # Should redirect and show success message
    assert_text I18n.t("organizations.sent_invitations.create.success", email: "newmember@example.com")

    # Navigate to invitations tab
    click_link I18n.t("organizations.sent_invitations.index.title")

    # Should see the invitation in the list
    assert_text "newmember@example.com"
  end

  test "admin can cancel a pending invitation" do
    # Use the existing fixture invitation
    invitation = organization_invitations(:one)

    sign_in @admin

    visit organization_sent_invitations_path(@organization)
    assert_text invitation.user.email

    # Cancel the invitation (no confirm dialog, just click)
    click_button I18n.t("organizations.sent_invitations.index.cancel_invitation")

    # Should show success message and invitation should be gone
    assert_text I18n.t("organizations.sent_invitations.destroy.success")
    assert_no_text invitation.user.email
  end

  test "user can see and accept a pending invitation" do
    # Use the existing fixture invitation (unassociated user has invitation to org one)
    invitation = organization_invitations(:one)
    user = invitation.user

    sign_in user

    visit user_organizations_received_invitations_path

    # Should see the organization in invitations
    assert_text invitation.organization.name

    # Accept the invitation
    click_button I18n.t("public.organizations.show.actions.accept_invitation")

    # Should be redirected to the organization and show success
    assert_text I18n.t("invitations.accept.success")

    # User should now be a member
    assert invitation.organization.reload.participant?(user)
  end

  test "user can decline a pending invitation" do
    # Create a new user for this test to avoid conflicts with existing fixtures
    new_user = User.create!(email: "decline_test@example.com", password: "password123", confirmed_at: Time.current)
    invitation = @organization.sent_invitations.create!(user: new_user)

    sign_in new_user

    visit user_organizations_received_invitations_path

    # Should see the organization in invitations
    assert_text @organization.name

    # Decline the invitation
    click_button I18n.t("public.organizations.show.actions.reject_invitation")

    # Should show success message
    assert_text I18n.t("invitations.decline.success")

    # Invitation should be destroyed
    assert_not OrganizationInvitation.exists?(invitation.id)

    # User should not be a member
    assert_not @organization.reload.participant?(new_user)
  end

  test "user without invitations sees empty state" do
    # Create a new user with no invitations
    new_user = User.create!(email: "no_invitations@example.com", password: "password123", confirmed_at: Time.current)

    sign_in new_user

    visit user_organizations_received_invitations_path

    # Should not see any organizations
    assert_no_text @organization.name
  end
end
