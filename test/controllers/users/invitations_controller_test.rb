require "test_helper"

class Users::InvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @invitation = access_requests(:invite_to_organization_one)
    @unassociated_user = users(:unassociated)
    sign_in @unassociated_user
  end

  test "should get index" do
    get user_invitations_url
    assert_response :success

    assert_match @invitation.organization.name, response.body
    organization2 = organizations(:two)
    assert_no_match organization2.name, response.body
  end

  test "should approve invitation" do
    assert_difference "@unassociated_user.memberships.count", 1 do
      post approve_user_invitation_url(@invitation)
    end

    assert_redirected_to user_invitations_url
    assert_equal I18n.t("invitations.approve.success"), flash[:notice]
    assert_equal "approved", @invitation.reload.status
  end

  test "should reject invitation" do
    assert_difference "@unassociated_user.memberships.count", 0 do
      post reject_user_invitation_url(@invitation)
    end

    assert_redirected_to user_invitations_url
    assert_equal I18n.t("invitations.reject.success"), flash[:notice]
    assert_equal "rejected", @invitation.reload.status
  end

  test "should not approve invitation if not signed in" do
    sign_out @unassociated_user
    post approve_user_invitation_url(@invitation)
    assert_redirected_to new_user_session_url
  end

  test "should not reject invitation if not signed in" do
    sign_out @unassociated_user
    post reject_user_invitation_url(@invitation)
    assert_redirected_to new_user_session_url
  end

  test "should not approve another user's invitation" do
    other_user_invitation = access_requests(:invite_to_organization_two)

    post approve_user_invitation_url(other_user_invitation)
    assert_redirected_to user_invitations_url
    assert_equal I18n.t("invitations.errors.not_found"), flash[:alert]
  end

  test "should not reject another user's invitation" do
    other_user_invitation = access_requests(:invite_to_organization_two)

    post reject_user_invitation_url(other_user_invitation)
    assert_redirected_to user_invitations_url
    assert_equal I18n.t("invitations.errors.not_found"), flash[:alert]
  end
end
