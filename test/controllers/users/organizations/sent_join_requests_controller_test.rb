# frozen_string_literal: true

require "test_helper"

class Users::Organizations::SentJoinRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    user = users(:one)
    sign_in user

    get user_organizations_sent_join_requests_url
    assert_response :success
  end

  test "should create membership for public organization" do
    membership = memberships(:one)
    user = membership.user
    requested_organization = organizations(:three)
    requested_organization.privacy_setting_public!

    sign_in user

    assert_difference "Membership.count", 1 do
      post user_organizations_sent_join_requests_url(organization_id: requested_organization.id)
    end

    assert_response :redirect
    assert_equal I18n.t("join_requests.success.access_granted"), flash[:notice]
  end

  test "should create join request for restricted organization" do
    membership = memberships(:one)
    user = membership.user
    requested_organization = organizations(:three)
    requested_organization.privacy_setting_restricted!

    sign_in user

    assert_difference "JoinRequest.count", 1 do
      post user_organizations_sent_join_requests_url(organization_id: requested_organization.id)
    end

    assert_response :redirect
    assert_equal I18n.t("join_requests.success.access_requested"), flash[:notice]
  end

  test "should return 404 if already a participant" do
    membership = memberships(:one)
    user = membership.user
    requested_organization = organizations(:one)

    sign_in user

    post user_organizations_sent_join_requests_url(organization_id: requested_organization.id)

    assert_response :not_found
  end

  test "should return 404 if organization is private" do
    membership = memberships(:one)
    user = membership.user
    organization = organizations(:two)
    organization.privacy_setting_private!

    sign_in user

    post user_organizations_sent_join_requests_url(organization_id: organization.id)

    assert_response :not_found
  end

  test "should return 404 if organization is not found" do
    membership = memberships(:one)
    user = membership.user
    organization_id = "invalid"

    sign_in user

    post user_organizations_sent_join_requests_url(organization_id:)

    assert_response :not_found
  end

  test "destroy" do
    user = users(:one)
    sign_in user

    organization = organizations(:three)
    organization.privacy_setting_restricted!

    assert_equal 0, user.reload.sent_join_requests.pending.count
    request = MembershipRequest.new(user:, organization:)
    request.save

    assert_equal 1, user.reload.sent_join_requests.pending.count

    assert_difference "JoinRequest.count", -1 do
      delete user_organizations_sent_join_request_path(user.reload.sent_join_requests.pending.first)
      assert_response :redirect
      assert_equal I18n.t("users.organizations.sent_join_requests.destroy.success"), flash[:notice]
    end
  end
end
