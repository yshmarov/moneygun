# frozen_string_literal: true

require "test_helper"

class Organizations::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    skip "Stripe credentials not configured" if Rails.application.credentials.dig(:stripe, :private_key).blank?
    @organization = organizations(:one)
    @user = users(:one)
    sign_in @user
  end

  test "#index" do
    get organization_subscriptions_url(@organization)
    assert_response :success
  end

  test "#index can be accessed only by current organization admins" do
    user = users(:two)
    @organization.memberships.create!(user:, role: "member")
    sign_in user
    get organization_dashboard_url(@organization)
    assert_response :success

    get organization_subscriptions_url(@organization)
    assert_response :redirect
  end

  test "#checkout" do
    price_ids = Rails.application.config_for(:settings)[:plan_price_ids] || []
    skip "No price IDs configured" if price_ids.empty?
    get organization_subscriptions_checkout_path(@organization, price_id: price_ids.first)
    assert_match %r{\Ahttps://checkout.stripe.com/c/pay/cs_test_}, response.redirect_url
  end
end
