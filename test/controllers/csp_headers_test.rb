# frozen_string_literal: true

require "test_helper"

class CspHeadersTest < ActionDispatch::IntegrationTest
  test "public pages emit an enforced policy" do
    get new_session_url

    assert_response :success
    policy = response.headers["Content-Security-Policy"]
    assert_predicate policy, :present?
    assert_match "base-uri 'self'", policy
    assert_match "frame-ancestors 'self'", policy
    assert_match %r{form-action[^;]*https://checkout\.stripe\.com}, policy
    assert_match %r{form-action[^;]*https://billing\.stripe\.com}, policy
  end

  test "authenticated pages emit an enforced policy" do
    sign_in users(:one)

    get organizations_url

    assert_response :success
    assert_predicate response.headers["Content-Security-Policy"], :present?
  end
end
