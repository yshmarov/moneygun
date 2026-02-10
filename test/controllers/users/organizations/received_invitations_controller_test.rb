# frozen_string_literal: true

require "test_helper"

class Users::Organizations::ReceivedInvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @invitation = access_requests(:invite_to_organization_one)
    @unassociated_user = users(:unassociated)
    sign_in @unassociated_user
  end

  test "should get index" do
    get user_organizations_received_invitations_url
    assert_response :success

    assert_match @invitation.organization.name, response.body
    organization2 = organizations(:two)
    assert_no_match organization2.name, response.body
  end

  test "should get show for own pending invitation" do
    get user_organizations_received_invitation_url(@invitation)
    assert_response :success
    assert_match @invitation.organization.name, response.body
  end

  test "should return 404 for another user's invitation on show" do
    other_user_invitation = access_requests(:invite_to_organization_two)
    get user_organizations_received_invitation_url(other_user_invitation)
    assert_response :not_found
  end

  test "should redirect to login when not signed in for show" do
    sign_out @unassociated_user
    get user_organizations_received_invitation_url(@invitation)
    assert_redirected_to new_user_session_url
  end

  test "should accept invitation" do
    assert_difference "@unassociated_user.memberships.count", 1 do
      patch accept_user_organizations_received_invitation_url(@invitation)
    end

    assert_redirected_to organization_dashboard_url(@invitation.organization)
    assert_equal I18n.t("invitations.accept.success"), flash[:notice]
    assert_equal "approved", @invitation.reload.status
  end

  test "should decline invitation" do
    invitation_id = @invitation.id

    assert_no_difference "@unassociated_user.memberships.count" do
      assert_difference "AccessRequest.count", -1 do
        patch decline_user_organizations_received_invitation_url(@invitation)
      end
    end

    assert_redirected_to user_organizations_received_invitations_url
    assert_equal I18n.t("invitations.decline.success"), flash[:notice]
    assert_not AccessRequest.exists?(invitation_id)
  end

  test "should not accept invitation if not signed in" do
    sign_out @unassociated_user
    patch accept_user_organizations_received_invitation_url(@invitation)
    assert_redirected_to new_user_session_url
  end

  test "should not decline invitation if not signed in" do
    sign_out @unassociated_user
    patch decline_user_organizations_received_invitation_url(@invitation)
    assert_redirected_to new_user_session_url
  end

  test "should return 404 when accepting another user's invitation" do
    other_user_invitation = access_requests(:invite_to_organization_two)

    patch accept_user_organizations_received_invitation_url(other_user_invitation)

    assert_response :not_found
  end

  test "should return 404 when declining another user's invitation" do
    other_user_invitation = access_requests(:invite_to_organization_two)

    patch decline_user_organizations_received_invitation_url(other_user_invitation)

    assert_response :not_found
  end
end
