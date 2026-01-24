# frozen_string_literal: true

require "test_helper"

class JoinRequestTest < ActiveSupport::TestCase
  test "should not be valid if user already has a join request for that organization" do
    join_request = JoinRequest.new(user: users(:three), organization: organizations(:one))
    assert_not join_request.valid?
    assert_includes join_request.errors.messages[:user_id], I18n.t("errors.messages.already_has_pending_request")
  end

  test "should return only pending join requests" do
    # Use organization three which has user three as owner, and create request from user two (not a member)
    rejected_request = JoinRequest.create!(status: :rejected, user: users(:two), organization: organizations(:three))
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

  test "should not be valid if user is already a member" do
    organization = organizations(:one)
    existing_member = users(:one)

    join_request = JoinRequest.new(user: existing_member, organization: organization)
    assert_not join_request.valid?
    assert_includes join_request.errors.messages[:user], I18n.t("errors.messages.already_member")
  end

  test "approve! returns false and adds error when not pending" do
    join_request = join_requests(:one)
    join_request.update!(status: :approved)

    result = join_request.approve!

    assert_equal false, result
    assert_includes join_request.errors[:base], I18n.t("errors.messages.not_pending")
  end

  test "reject! returns false and adds error when not pending" do
    join_request = join_requests(:one)
    join_request.update!(status: :approved)

    result = join_request.reject!

    assert_equal false, result
    assert_includes join_request.errors[:base], I18n.t("errors.messages.not_pending")
  end

  test "approve! tracks completed_by" do
    join_request = join_requests(:one)
    admin = users(:one)

    join_request.approve!(completed_by: admin)

    assert_equal admin, join_request.reload.completed_by
  end

  test "when created, notifies organization admins" do
    organization = organizations(:one)
    user = users(:unassociated)
    admin = users(:one)

    # Organization one has users(:one) as admin
    assert_difference "Noticed::Notification.count", 1 do
      JoinRequest.create!(user: user, organization: organization)
    end

    notification = admin.notifications.last
    assert_equal "Membership::JoinRequestNotifier::Notification", notification.type
    assert_equal organization, notification.params[:organization]
    assert_equal user, notification.params[:user]
  end
end
