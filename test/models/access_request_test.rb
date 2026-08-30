# frozen_string_literal: true

require "test_helper"

class AccessRequestTest < ActiveSupport::TestCase
  test "should not be valid if user already has an access request for that organization" do
    access_request = AccessRequest.new(user: users(:three), organization: organizations(:one))
    assert_not access_request.valid?
    assert_includes access_request.errors.messages[:user_id], I18n.t("errors.messages.already_has_pending_request")
  end

  test "should return only pending access requests" do
    rejected_access_request = AccessRequest.create!(status: :rejected, user: users(:one), organization: organizations(:one))
    pending_access_requests = AccessRequest.pending

    assert_equal 1, pending_access_requests.count
    assert_includes pending_access_requests, access_requests(:membership_request_one)
    assert_not_includes pending_access_requests, rejected_access_request
  end
end
