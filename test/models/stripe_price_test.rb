# frozen_string_literal: true

require "test_helper"

class StripePriceTest < ActiveSupport::TestCase
  test "one_time? returns true for one-time prices" do
    price = StripePrice.new(
      id: "price_123",
      unit_amount: 1000,
      currency: "USD",
      interval: "one_time",
      product_id: "prod_123",
      active: true,
      nickname: "One-time"
    )

    assert price.one_time?
    assert_not price.recurring?
  end

  test "recurring? returns true for subscription prices" do
    price = StripePrice.new(
      id: "price_123",
      unit_amount: 1000,
      currency: "USD",
      interval: "month",
      product_id: "prod_123",
      active: true,
      nickname: "Monthly"
    )

    assert price.recurring?
    assert_not price.one_time?
  end

  test "bracket accessor returns attribute values" do
    price = StripePrice.new(
      id: "price_123",
      unit_amount: 1000,
      currency: "USD",
      interval: "month",
      product_id: "prod_123",
      active: true,
      nickname: "Monthly"
    )

    assert_equal "price_123", price[:id]
    assert_equal 1000, price[:unit_amount]
    assert_equal "month", price[:interval]
  end
end
