require 'test_helper'

class AccessRequest::UserRequestForOrganizationTest < ActiveSupport::TestCase
  test 'when approved, creates a membership and sends notification' do
    access_request = access_requests(:membership_request_one)
    user = access_request.user

    assert_difference 'Membership.count', 1 do
      assert_difference 'Noticed::Notification.count', 1 do
        access_request.approve!(completed_by: users(:one))
      end
    end

    assert_equal 'approved', access_request.reload.status

    # Check that notification was sent to the correct user
    notification = user.notifications.last
    assert_equal 'Membership::RequestAcceptedNotifier::Notification', notification.type
    assert_equal access_request.organization, notification.params[:organization]
  end

  test 'when rejected, updates the access request status and sends notification' do
    access_request = access_requests(:membership_request_one)

    assert_difference 'Membership.count', 0 do
      assert_difference 'Noticed::Notification.count', 1 do
        access_request.reject!(completed_by: users(:one))
      end
    end

    assert_equal 'rejected', access_request.reload.status

    # Check that notification was sent to the correct user
    notification = access_request.user.notifications.last
    assert_equal 'Membership::RequestRejectedNotifier::Notification', notification.type
    assert_equal access_request.organization, notification.params[:organization]
  end
end
