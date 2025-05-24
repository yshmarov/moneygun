require "test_helper"

class Organizations::MembershipRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @organization = organizations(:one)

    sign_in @user
  end

  test "should get index" do
    get organization_membership_requests_url(@organization)
    assert_response :success
  end

  test "should get index and show only pending requests" do
    pending_requests = @organization.user_requests.pending.to_a

    approved_request = @organization.user_requests.create!(
      user: users(:two),
      status: :approved
    )

    get organization_membership_requests_url(@organization)
    assert_response :success

    pending_requests.each do |request|
      assert_match request.user.email, response.body
    end

    assert_no_match approved_request.user.email, response.body
  end

  test "should approve membership request for public organization" do
    membership_request = access_requests(:membership_request_one)
    membership_request.organization.update!(privacy_setting: :public)

    assert_difference "Membership.count", 1 do
      assert_no_difference "AccessRequest.count" do
        post approve_organization_membership_request_url(@organization, membership_request)
      end
    end

    assert_equal "approved", membership_request.reload.status
    assert_redirected_to organization_membership_requests_url(@organization)
    assert_equal I18n.t("membership_requests.approve.success"), flash[:notice]
  end

  test "should approve membership request for restricted organization" do
    membership_request = access_requests(:membership_request_one)
    membership_request.organization.update!(privacy_setting: :restricted)

    assert_difference "Membership.count", 1 do
      post approve_organization_membership_request_url(@organization, membership_request)
    end

    assert_equal "approved", membership_request.reload.status
    assert_redirected_to organization_membership_requests_url(@organization)
    assert_equal I18n.t("membership_requests.approve.success"), flash[:notice]
  end

  test "should reject membership request" do
    membership_request = access_requests(:membership_request_one)

    assert_no_difference "Membership.count" do
      assert_no_difference "AccessRequest.count" do
        post reject_organization_membership_request_url(@organization, membership_request)
      end
    end

    assert_equal "rejected", membership_request.reload.status
    assert_redirected_to organization_membership_requests_url(@organization)
    assert_equal I18n.t("membership_requests.reject.success"), flash[:notice]
  end

  test "should catch error if membership request is not found" do
    membership_request_id = "invalid"

    post reject_organization_membership_request_url(@organization, membership_request_id)

    assert_redirected_to organization_membership_requests_path(@organization)
    assert_equal I18n.t("membership_requests.errors.not_found"), flash[:alert]
  end
end
