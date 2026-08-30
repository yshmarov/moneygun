# frozen_string_literal: true

require "test_helper"

class SubscriptionsPlanTest < ActionView::TestCase
  setup do
    Current.organization = organizations(:one)
  end

  teardown do
    Current.reset
  end

  test "complimentary access renders without a payment processor" do
    Current.organization.update!(admin_granted_access: true)
    Current.organization.stubs(:payment_processor).returns(nil)

    render partial: "organizations/subscriptions/plan", locals: { subscription: nil }

    assert_includes rendered, I18n.t("organizations.subscriptions.plan.granted_access")
    assert_includes rendered, I18n.t(
      "organizations.subscriptions.plan.granted_access_detail",
      site_name: Rails.application.config_for(:settings).dig(:site, :name)
    )
  end

  test "active subscription renders its lifecycle state" do
    billing_date = 1.month.from_now
    subscription = stub(
      on_trial?: false,
      on_grace_period?: false,
      current_period_end: billing_date,
      processor_plan: "price_test"
    )
    Current.organization.stubs(:has_access?).returns(true)
    Current.organization.stubs(:payment_processor).returns(nil)
    StripePrice.stubs(:find).with("price_test").returns(nil)

    render partial: "organizations/subscriptions/plan", locals: { subscription: subscription }

    assert_includes rendered, I18n.t("organizations.subscriptions.plan.active")
    assert_includes rendered, I18n.t("organizations.subscriptions.plan.next_billing_date")
  end
end
