require "test_helper"

class AccessRequestTest < ActiveSupport::TestCase
  test "should not be valid if user already has an access request for that organization" do
    access_request = AccessRequest.new(user: users(:one), organization: organizations(:two))
    assert_not access_request.valid?
    assert_includes access_request.errors.messages[:user_id], "already has a pending request"
  end

  test "should return only pending access requests" do
    rejected_access_request = AccessRequest.create!(status: :rejected, user: users(:one), organization: organizations(:one))
    pending_access_requests = AccessRequest.pending

    assert_equal 2, pending_access_requests.count
    assert_includes pending_access_requests, access_requests(:invite_to_organization_one)
    assert_includes pending_access_requests, access_requests(:invite_to_organization_two)
    assert_not_includes pending_access_requests, rejected_access_request
  end

  test "approve" do
    access_request = AccessRequest.new
    assert_raises NotImplementedError do
      access_request.approve!
    end
  end

  test "reject" do
    access_request = AccessRequest.new
    assert_raises NotImplementedError do
      access_request.reject!
    end
  end
end
