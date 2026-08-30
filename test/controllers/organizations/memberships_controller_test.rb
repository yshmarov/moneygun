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

  test "index shows each member's last activity" do
    last_seen_at = 2.minutes.ago
    @user.sessions.update_all(last_seen_at: last_seen_at) # rubocop:disable Rails/SkipsModelValidations

    get organization_memberships_url(@organization)

    assert_response :success
    assert_match(
      I18n.t("organizations.memberships.index.last_seen_html", time_ago: ApplicationController.helpers.time_ago_in_words(last_seen_at)),
      response.body
    )
  end

  test "#edit" do
    # The owner's role is immutable.
    get edit_organization_membership_url(@organization, @membership)
    assert_redirected_to organizations_url

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
    # The owner cannot edit their own membership.
    patch organization_membership_url(@organization, @membership), params: { membership: { role: "member" } }
    assert_redirected_to organizations_url
    assert @membership.reload.admin?

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

    # member can not update membership
    sign_in @user2
    second_membership.member!
    patch organization_membership_url(@organization, second_membership), params: { membership: { role: "admin" } }
    assert_redirected_to organizations_url
    assert second_membership.reload.member?
  end

  test "#destroy" do
    # does not destroy only membership
    assert_difference("Membership.count", 0) do
      delete organization_membership_url(@organization, @membership)
    end
    assert_redirected_to organizations_url
    follow_redirect!
    assert_response :success

    # deactivates another membership without deleting its history
    @organization.users << @user2
    second_membership = @organization.memberships.find_by(user: @user2)
    assert_no_difference("Membership.count") do
      delete organization_membership_url(@organization, second_membership)
    end
    assert second_membership.reload.deactivated?
    assert_redirected_to organization_memberships_url
    follow_redirect!
    assert_response :success

    # does not destroy only admin membership
    second_membership.update!(deactivated_at: nil)
    assert_difference("Membership.count", 0) do
      delete organization_membership_url(@organization, @membership)
    end
    assert_redirected_to organizations_url
    follow_redirect!
    assert_response :success

    # does not destroy owner even if there is another admin
    second_membership.admin!
    assert_no_difference("Membership.count") do
      delete organization_membership_url(@organization, @membership)
    end

    # deactivates non-owner admin if there is another admin
    assert_no_difference("Membership.count") do
      delete organization_membership_url(@organization, second_membership)
    end
    assert second_membership.reload.deactivated?
  end
end
