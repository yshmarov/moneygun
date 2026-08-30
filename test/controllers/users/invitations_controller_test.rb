# frozen_string_literal: true

require "test_helper"

class Users::InvitationsControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated invitation stores return path and prefilled email outside the URL" do
    invitation = invitations(:pending)

    get user_invitation_path(invitation)

    assert_redirected_to new_session_path
    assert_no_match(/email_address=/, response.location)
    follow_redirect!
    assert_select "input[name=email_address][value=?]", invitation.email
  end

  test "recipient accepts invitation" do
    invitation = invitations(:pending)
    sign_in users(:unassociated)

    assert_difference "Membership.count", 1 do
      patch accept_user_invitation_path(invitation)
    end

    assert_redirected_to organization_dashboard_path(invitation.organization)
  end

  test "another user cannot act on invitation" do
    invitation = invitations(:pending)
    sign_in users(:two)

    assert_no_difference "Membership.count" do
      patch accept_user_invitation_path(invitation)
    end

    assert_response :not_found
  end
end
