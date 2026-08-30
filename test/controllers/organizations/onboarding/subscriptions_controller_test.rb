# frozen_string_literal: true

require "test_helper"

class Organizations::Onboarding::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    sign_in users(:one)
  end

  test "skips billing when Stripe is not configured" do
    StripePrice.stubs(:configured?).returns(false)

    get organization_onboarding_subscription_url(@organization)

    assert_redirected_to organization_dashboard_url(@organization)
  end

  test "shows pricing when billing is configured" do
    StripePrice.stubs(:configured?).returns(true)
    StripePrice.stubs(:all).returns([])

    get organization_onboarding_subscription_url(@organization)

    assert_response :success
    assert_select "h1", I18n.t("organizations.onboarding.subscription.title")
  end
end
