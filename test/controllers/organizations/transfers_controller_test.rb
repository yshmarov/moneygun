# frozen_string_literal: true

require "test_helper"

class Organizations::TransfersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @organization = organizations(:one)
    @membership = memberships(:one)

    @user2 = users(:two)
  end

  test "#show" do
    sign_in @user

    get organization_transfer_path(@organization)
    assert_response :success
  end

  test "admin can transfer organization" do
    @membership2 = @organization.memberships.create!(user: @user2, role: Membership.roles[:member])
    sign_in @user

    patch organization_transfer_path(@organization), params: { user_id: @user2.id }
    assert_redirected_to organization_dashboard_path(@organization)
    assert_equal @user2, @organization.reload.owner
  end

  test "regular_user cannot transfer organization" do
    @membership2 = @organization.memberships.create!(user: @user2, role: Membership.roles[:member])
    sign_in @user2

    patch organization_transfer_path(@organization), params: { user_id: @user2.id }
    assert_redirected_to organization_dashboard_path(@organization)
    assert_equal @user, @organization.reload.owner
  end

  test "transfer organization to non-member" do
    sign_in @user

    patch organization_transfer_path(@organization), params: { user_id: @user2.id }
    assert_response :unprocessable_content
    assert_equal @user, @organization.reload.owner
  end

  test "transfer organization that user is not a member of" do
    sign_in @user2

    patch organization_transfer_path(@organization), params: { user_id: @user2.id }
    assert_redirected_to user_organizations_url
    assert_match I18n.t("shared.errors.not_authorized"), flash[:alert]
    assert_equal @user, @organization.reload.owner
  end
end
