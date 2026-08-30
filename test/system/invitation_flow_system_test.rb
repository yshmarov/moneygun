# frozen_string_literal: true

require "application_system_test_case"

class InvitationFlowSystemTest < ApplicationSystemTestCase
  test "an admin invites a teammate from the roster" do
    organization = organizations(:one)
    sign_in users(:one)
    visit organization_memberships_path(organization)

    click_on I18n.t("organizations.invitations.new.title")
    fill_in Invitation.human_attribute_name(:email), with: "newteammate@example.com"
    click_on I18n.t("organizations.invitations.new.submit")

    assert_current_path(/tab=pending/)
    assert_text "newteammate@example.com"
    assert organization.invitations.exists?(email: "newteammate@example.com")
  end

  test "an invited user accepts and joins the organization" do
    invitation = invitations(:pending)
    user = users(:unassociated)
    sign_in user
    visit user_invitation_path(invitation)

    click_on I18n.t("users.invitations.show.accept")

    assert_current_path organization_dashboard_path(invitation.organization)
    assert user.reload.memberships.active.exists?(organization: invitation.organization)
  end
end
