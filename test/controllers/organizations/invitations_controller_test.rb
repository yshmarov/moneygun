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

  test "should get new" do
    @membership = memberships(:one)

    @user = users(:one)
    @user2 = users(:two)
    @organization = organizations(:one)
    sign_in @user

    # admin can invite new membership
    get new_organization_invitation_path(@organization)
    assert_response :success

    # user is not membership
    sign_in @user2
    get new_organization_invitation_path(@organization)
    assert_redirected_to organizations_url
    assert_match I18n.t("shared.errors.not_authorized"), flash[:alert]

    # user is organization member
    @organization.memberships.create(user: @user2, role: "member")
    sign_in @user2
    get new_organization_invitation_path(@organization)
    assert_response :redirect
  end

  test "should create access request" do
    @membership = memberships(:one)

    @user = users(:one)
    @user2 = users(:two)
    @organization = organizations(:one)
    sign_in @user

    email = "julia@superails.com"

    # nil email
    assert_no_difference("User.count") do
      assert_no_difference("Membership.count") do
        post organization_invitations_url(@organization), params: { membership_invitation: { email: nil } }
      end
    end
    assert_response :unprocessable_entity

    assert_no_difference("User.count") do
      assert_no_difference("Membership.count") do
        post organization_invitations_url(@organization)
      end
    end
    assert_response :unprocessable_entity

    # invalid email
    assert_no_difference("User.count") do
      assert_no_difference("Membership.count") do
        post organization_invitations_url(@organization), params: { membership_invitation: { email: "foo" } }
      end
    end
    assert_response :unprocessable_entity

    # success
    assert_difference("User.count") do
      assert_difference("AccessRequest::InviteToOrganization.count") do
        post organization_invitations_url(@organization), params: { membership_invitation: { email: } }
      end
    end

    assert_redirected_to organization_memberships_url
    assert_equal "julia@superails.com", @organization.user_invitations.last.user.email

    # when user is already a member
    assert_no_difference("User.count") do
      assert_no_difference("Membership.count") do
        post organization_invitations_url(@organization), params: { membership_invitation: { email: } }
      end
    end
    assert_response :unprocessable_entity
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
