# frozen_string_literal: true

require "test_helper"

class JoinRequestTest < ActiveSupport::TestCase
  test "should not be valid if user already has a join request for that organization" do
    join_request = JoinRequest.new(user: users(:three), organization: organizations(:one))
    assert_not join_request.valid?
    assert_includes join_request.errors.messages[:user_id], I18n.t("errors.messages.already_has_pending_request")
  end

  test "should return only pending join requests" do
    rejected_request = JoinRequest.create!(status: :rejected, user: users(:one), organization: organizations(:one))
    pending_requests = JoinRequest.pending

    assert_equal 1, pending_requests.count
    assert_includes pending_requests, join_requests(:one)
    assert_not_includes pending_requests, rejected_request
  end

  test "when approved, creates a membership and sends notification" do
    join_request = join_requests(:one)
    user = join_request.user

    assert_difference "Membership.count", 1 do
      assert_difference "Noticed::Notification.count", 1 do
        join_request.approve!(completed_by: users(:one))
      end
    end

    assert_equal "approved", join_request.reload.status

    notification = user.notifications.last
    assert_equal "Membership::RequestAcceptedNotifier::Notification", notification.type
    assert_equal join_request.organization, notification.params[:organization]
  end

  test "when rejected, destroys the join request and sends notification" do
    join_request = join_requests(:one)
    join_request_id = join_request.id
    user = join_request.user
    organization = join_request.organization

    assert_no_difference "Membership.count" do
      assert_difference "JoinRequest.count", -1 do
        assert_difference "Noticed::Notification.count", 1 do
          join_request.reject!(completed_by: users(:one))
        end
      end
    end

    assert_not JoinRequest.exists?(join_request_id)

    notification = user.notifications.last
    assert_equal "Membership::RequestRejectedNotifier::Notification", notification.type
    assert_equal organization, notification.params[:organization]
  end
end
