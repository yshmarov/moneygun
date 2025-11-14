# frozen_string_literal: true

# Service to fetch and cache Stripe prices
# This eliminates the need to manually sync price data between Stripe and settings.yml
class StripePriceService
  CACHE_KEY = "stripe_prices"
  CACHE_EXPIRY = 1.hour

  class << self
    def all
      Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_EXPIRY) do
        fetch_prices_from_stripe
      end
    end

    def find(price_id)
      all.find { |price| price[:id] == price_id }
    end

    def clear_cache
      Rails.cache.delete(CACHE_KEY)
    end

    private

    def fetch_prices_from_stripe
      return [] unless stripe_configured?

      price_ids = Rails.application.config_for(:settings)[:plan_price_ids] || []
      return [] if price_ids.empty?

      price_ids.map do |price_id|
        price = Stripe::Price.retrieve(price_id)
        format_price(price)
      rescue Stripe::StripeError => e
        Rails.logger.error("Failed to fetch Stripe price #{price_id}: #{e.message}")
        nil
      end.compact.sort_by { |p| [p[:interval] == "year" ? 0 : 1, p[:unit_amount]] }
    end

    def format_price(stripe_price)
      {
        id: stripe_price.id,
        unit_amount: stripe_price.unit_amount,
        currency: stripe_price.currency.upcase,
        interval: stripe_price.recurring&.interval || "one_time",
        product_id: stripe_price.product,
        active: stripe_price.active,
        nickname: stripe_price.nickname
      }
    end

    def stripe_configured?
      Rails.application.credentials.dig(:stripe, :private_key).present?
    end
  end
end
