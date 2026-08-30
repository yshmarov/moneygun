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

  test "subscription_plan_labels describe active subscriptions" do
    billing_date = 1.month.from_now
    subscription = stub(on_trial?: false, on_grace_period?: false, current_period_end: billing_date)

    labels = subscription_plan_labels(subscription)

    assert_equal I18n.t("organizations.subscriptions.plan.active"), labels[:status]
    assert_equal I18n.t("organizations.subscriptions.plan.next_billing_date"), labels[:access]
    assert_equal I18n.t("organizations.subscriptions.plan.manage_billing"), labels[:button]
    assert_equal billing_date, labels[:date]
  end

  test "subscription_plan_labels describe cancelled subscriptions" do
    access_ends_at = 1.week.from_now
    subscription = stub(on_trial?: false, on_grace_period?: true, current_period_end: access_ends_at)

    labels = subscription_plan_labels(subscription)

    assert_equal I18n.t("organizations.subscriptions.plan.cancelled"), labels[:status]
    assert_equal I18n.t("organizations.subscriptions.plan.resume_subscription"), labels[:button]
    assert_equal access_ends_at, labels[:date]
    assert_match distance_of_time_in_words(access_ends_at, Time.current), labels[:access]
  end
end
