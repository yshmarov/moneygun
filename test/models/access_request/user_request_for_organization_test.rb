# frozen_string_literal: true

require "test_helper"

class AccessRequest::UserRequestForOrganizationTest < ActiveSupport::TestCase
  test "when approved, creates a membership and sends notification" do
    access_request = access_requests(:membership_request_one)
    user = access_request.user

    assert_difference "Membership.count", 1 do
      assert_difference "Noticed::Notification.count", 1 do
        access_request.approve!(completed_by: users(:one))
      end
    end

    assert_equal "approved", access_request.reload.status

    # Check that notification was sent to the correct user
    notification = user.notifications.last
    assert_equal "Membership::RequestAcceptedNotifier::Notification", notification.type
    assert_equal access_request.organization, notification.params[:organization]
  end

  test "when rejected, destroys the access request and sends notification" do
    access_request = access_requests(:membership_request_one)
    access_request_id = access_request.id
    user = access_request.user
    organization = access_request.organization

    assert_no_difference "Membership.count" do
      assert_difference "AccessRequest.count", -1 do
        assert_difference "Noticed::Notification.count", 1 do
          access_request.reject!(completed_by: users(:one))
        end
      end
    end

    assert_not AccessRequest.exists?(access_request_id)

    # Check that notification was sent to the correct user
    notification = user.notifications.last
    assert_equal "Membership::RequestRejectedNotifier::Notification", notification.type
    assert_equal organization, notification.params[:organization]
  end
end
