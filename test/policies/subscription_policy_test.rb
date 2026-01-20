# frozen_string_literal: true

require "test_helper"

class SubscriptionPolicyTest < ActiveSupport::TestCase
  def setup
    @organization = organizations(:one)
    @admin = @organization.memberships.find_by(user: users(:one))
    @member = @organization.memberships.create!(user: users(:two), role: :member)
  end

  test "admin can access subscription actions" do
    policy = SubscriptionPolicy.new(@admin, :subscription)

    assert policy.index?
    assert policy.checkout?
    assert policy.success?
    assert policy.billing_portal?
  end

  test "member cannot access subscription actions" do
    policy = SubscriptionPolicy.new(@member, :subscription)

    assert_not policy.index?
    assert_not policy.checkout?
    assert_not policy.success?
    assert_not policy.billing_portal?
  end

  test "raises error without membership" do
    assert_raises(Pundit::NotAuthorizedError) do
      SubscriptionPolicy.new(nil, :subscription)
    end
  end
end
