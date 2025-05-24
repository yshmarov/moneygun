require "test_helper"

class Organizations::InvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @user = users(:one)
    @invitation = access_requests(:invite_to_organization_one)
    sign_in @user
  end

  test "should get index" do
    get organization_invitations_url(@organization)
    assert_response :success
  end

  test "should get index and show only pending invitations" do
    pending_invitations = @organization.user_invitations.pending.to_a

    approved_invitation = @organization.user_invitations.create!(
      user: users(:two),
      status: :approved
    )

    get organization_invitations_url(@organization)
    assert_response :success

    pending_invitations.each do |invitation|
      assert_match invitation.user.email, response.body
    end

    assert_no_match approved_invitation.user.email, response.body
  end

  test "#destroy removes invitation" do
    assert_difference("AccessRequest.count", -1) do
      delete organization_invitation_url(@organization, @invitation)
    end
    assert_redirected_to organization_invitations_path(@organization)
    assert_equal I18n.t("organizations.invitations.destroy.success"), flash[:notice]
  end

  test "#destroy redirects with alert when invitation not found" do
    delete organization_invitation_url(@organization, id: "nonexistent")
    assert_redirected_to organization_invitations_path(@organization)
    assert_equal I18n.t("organizations.invitations.errors.not_found"), flash[:alert]
  end
end
