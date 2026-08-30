# frozen_string_literal: true

require "test_helper"

class Organizations::InvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    sign_in users(:one)
  end

  test "admin creates an email-first invitation without creating a user" do
    assert_difference -> { Invitation.count } => 1, -> { User.count } => 0 do
      post organization_invitations_path(@organization), params: { invitation: { email: "invitee@example.com", role: "admin" } }
    end

    assert_redirected_to organization_memberships_path(@organization, tab: "pending")
    assert_equal "admin", Invitation.find_by!(email: "invitee@example.com").role
  end

  test "cannot invite an active member" do
    assert_no_difference "Invitation.count" do
      post organization_invitations_path(@organization), params: { invitation: { email: users(:one).email, role: "member" } }
    end

    assert_response :unprocessable_content
  end

  test "another tenant invitation cannot be revoked" do
    foreign = organizations(:two).invitations.create!(email: "foreign@example.com", invited_by: users(:two))

    delete organization_invitation_path(@organization, foreign)

    assert_response :not_found
    assert_predicate foreign.reload, :persisted?
  end
end
