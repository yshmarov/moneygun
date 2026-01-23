# frozen_string_literal: true

require "test_helper"

class Organizations::ReceivedJoinRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @organization = organizations(:one)

    sign_in @user
  end

  test "should get index" do
    get organization_received_join_requests_url(@organization)
    assert_response :success
  end

  test "should get index and show only pending requests" do
    pending_requests = @organization.received_join_requests.pending.to_a

    approved_request = @organization.received_join_requests.create!(
      user: users(:two),
      status: :approved
    )

    get organization_received_join_requests_url(@organization)
    assert_response :success

    pending_requests.each do |request|
      assert_match request.user.email, response.body
    end

    assert_no_match approved_request.user.email, response.body
  end

  test "should approve join request for public organization" do
    join_request = join_requests(:one)
    join_request.organization.update!(privacy_setting: :public)

    assert_difference "Membership.count", 1 do
      assert_no_difference "JoinRequest.count" do
        post approve_organization_received_join_request_url(@organization, join_request)
      end
    end

    assert_equal "approved", join_request.reload.status
    assert_redirected_to organization_received_join_requests_url(@organization)
    assert_equal I18n.t("join_requests.approve.success"), flash[:notice]
  end

  test "should approve join request for restricted organization" do
    join_request = join_requests(:one)
    join_request.organization.update!(privacy_setting: :restricted)

    assert_difference "Membership.count", 1 do
      post approve_organization_received_join_request_url(@organization, join_request)
    end

    assert_equal "approved", join_request.reload.status
    assert_redirected_to organization_received_join_requests_url(@organization)
    assert_equal I18n.t("join_requests.approve.success"), flash[:notice]
  end

  test "should reject join request" do
    join_request = join_requests(:one)
    join_request_id = join_request.id

    assert_no_difference "Membership.count" do
      assert_difference "JoinRequest.count", -1 do
        post reject_organization_received_join_request_url(@organization, join_request)
      end
    end

    assert_not JoinRequest.exists?(join_request_id)
    assert_redirected_to organization_received_join_requests_url(@organization)
    assert_equal I18n.t("join_requests.reject.success"), flash[:notice]
  end

  test "should return 404 if join request is not found" do
    join_request_id = "invalid"

    post reject_organization_received_join_request_url(@organization, join_request_id)

    assert_response :not_found
  end
end
