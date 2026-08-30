# frozen_string_literal: true

require "test_helper"

class SubscriptionHelperTest < ActionView::TestCase
  test "subscription_status_label" do
    organization = organizations(:one)
    assert_equal "🔴", subscription_status_label(organization)

    organization.set_payment_processor :fake_processor, allow_fake: true
    organization.payment_processor.subscribe(plan: "fake")
    assert_equal "🟢", subscription_status_label(organization)

    organization.payment_processor.subscribe(plan: "fake", ends_at: 1.week.from_now)
    assert_equal "🟠", subscription_status_label(organization)

    organization.update!(admin_granted_access: true)
    assert_equal "🟢", subscription_status_label(organization)
  end
end
