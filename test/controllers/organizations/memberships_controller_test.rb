# frozen_string_literal: true

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
    assert_response :unprocessable_content
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
    assert_response :unprocessable_content
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

  test "#suspend - admin can suspend member" do
    @organization.users << @user2
    member_membership = @organization.memberships.find_by(user: @user2)
    assert member_membership.active?

    patch suspend_organization_membership_url(@organization, member_membership)
    assert_redirected_to organization_memberships_url(@organization)
    assert member_membership.reload.suspended?
  end

  test "#suspend - idempotent on already suspended" do
    @organization.users << @user2
    member_membership = @organization.memberships.find_by(user: @user2)
    member_membership.update!(suspended_at: Time.current)

    patch suspend_organization_membership_url(@organization, member_membership)
    assert_redirected_to organization_memberships_url(@organization)
    assert member_membership.reload.suspended?
  end

  test "#suspend - non-admin cannot suspend" do
    @organization.users << @user2
    other_membership = @organization.memberships.create(user: users(:unassociated), role: "member")

    sign_in @user2 # member, not admin
    patch suspend_organization_membership_url(@organization, other_membership)
    assert_redirected_to root_url
    assert other_membership.reload.active?
  end

  test "#suspend - cannot suspend owner" do
    owner_membership = @organization.memberships.find_by(user: @organization.owner)

    patch suspend_organization_membership_url(@organization, owner_membership)
    assert_redirected_to root_url # Pundit denies
    assert owner_membership.reload.active?
  end

  test "#suspend - cannot suspend only admin" do
    # Transfer ownership so we can test suspending a non-owner admin
    @organization.users << @user2
    member_membership = @organization.memberships.find_by(user: @user2)
    member_membership.update!(role: "admin")
    @organization.transfer_ownership(@user2)

    # Now @user is admin but not owner, @user2 is owner and admin
    owner_membership = @organization.memberships.find_by(user: @user)
    # @user can suspend themselves since @user2 is also admin
    patch suspend_organization_membership_url(@organization, owner_membership)
    assert_redirected_to organization_memberships_url(@organization)
    assert owner_membership.reload.suspended?
  end

  test "#activate" do
    # add a suspended member
    @organization.users << @user2
    member_membership = @organization.memberships.find_by(user: @user2)
    member_membership.update!(suspended_at: Time.current)
    assert member_membership.suspended?

    # admin can activate a suspended member
    patch activate_organization_membership_url(@organization, member_membership)
    assert_redirected_to organization_memberships_url(@organization)
    assert member_membership.reload.active?

    # activate is idempotent
    patch activate_organization_membership_url(@organization, member_membership)
    assert_redirected_to organization_memberships_url(@organization)
    assert member_membership.reload.active?

    # non-admin cannot activate
    # Create another suspended member to try to activate
    another_suspended = @organization.memberships.create(user: users(:unassociated), role: "member", suspended_at: Time.current)
    sign_in @user2
    patch activate_organization_membership_url(@organization, another_suspended)
    assert_redirected_to root_url
    assert another_suspended.reload.suspended?
  end
end
