require "test_helper"

class MembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @membership = memberships(:one)

    @user = users(:one)
    @user2 = users(:two)
    @organization = organizations(:one)
    sign_in @user
  end

  test "should get index" do
    get organization_memberships_url(@organization)
    assert_response :success
    assert_match @membership.user.email, response.body

    # user is not a member of the organization
    get organization_memberships_url(organizations(:two))
    assert_redirected_to organizations_url
    assert_match I18n.t("shared.errors.not_authorized"), flash[:alert]
  end

  test "#edit" do
    # admin can edit himself
    get edit_organization_membership_url(@organization, @membership)
    assert_response :success

    # admin can edit other membership
    @organization.users << @user2
    second_membership = @organization.memberships.find_by(user: @user2)
    get edit_organization_membership_url(@organization, second_membership)
    assert_response :success

    # only admin can edit membership
    sign_in @user2
    get edit_organization_membership_url(@organization, @membership)
    assert_response :redirect
  end

  test "#update" do
    # only admin can't make himself a member
    patch organization_membership_url(@organization, @membership), params: { membership: { role: "member" } }
    assert_response :unprocessable_entity
    assert @membership.reload.admin?
    assert_match "Role cannot be changed because this is the only admin.", response.body

    # admin can update other membership
    @organization.users << @user2
    second_membership = @organization.memberships.find_by(user: @user2)
    patch organization_membership_url(@organization, second_membership), params: { membership: { role: "admin" } }
    assert_redirected_to organization_memberships_url
    assert second_membership.reload.admin?

    # can not update membership with invalid role
    assert_raises(ArgumentError) do
      patch organization_membership_url(@organization, second_membership), params: { membership: { role: "foo" } }
    end

    # organization owner can not demote himself from admin
    first_membership = @organization.memberships.find_by(user: @user)
    patch organization_membership_url(@organization, first_membership), params: { membership: { role: "member" } }
    assert_response :unprocessable_entity
    assert first_membership.reload.admin?
    assert_match "Organization owner cannot be demoted from admin role.", response.body

    # member can not update membership
    sign_in @user2
    second_membership.member!
    patch organization_membership_url(@organization, second_membership), params: { membership: { role: "admin" } }
    assert_redirected_to root_url
    assert second_membership.reload.member?
  end

  test "#destroy" do
    # does not destroy only membership
    assert_difference("Membership.count", 0) do
      delete organization_membership_url(@organization, @membership)
    end
    assert_redirected_to organization_memberships_url
    follow_redirect!
    assert_response :success

    # destroys another membership
    @organization.users << @user2
    second_membership = @organization.memberships.find_by(user: @user2)
    assert_difference("Membership.count", -1) do
      delete organization_membership_url(@organization, second_membership)
    end
    assert_redirected_to organization_memberships_url
    follow_redirect!
    assert_response :success

    # does not destroy only admin membership
    @organization.users << @user2
    second_membership = @organization.memberships.find_by(user: @user2)
    assert_difference("Membership.count", 0) do
      delete organization_membership_url(@organization, @membership)
    end
    assert_redirected_to organization_memberships_url
    follow_redirect!
    assert_response :success

    # does not destroy owner even if there is another admin
    second_membership.admin!
    assert_no_difference("Membership.count") do
      delete organization_membership_url(@organization, @membership)
    end

    # destroys non-owner admin if there is another admin
    assert_difference("Membership.count", -1) do
      delete organization_membership_url(@organization, second_membership)
    end
  end
end
