# frozen_string_literal: true

# Plain Ruby object representing a Stripe price.
# Not backed by a database - fetches from Stripe API with caching.
class StripePrice
  CACHE_KEY = "stripe_prices"
  CACHE_EXPIRY = 10.minutes

  attr_reader :id, :unit_amount, :currency, :interval, :product_id, :active, :nickname

  def initialize(id:, unit_amount:, currency:, interval:, product_id:, active:, nickname:)
    @id = id
    @unit_amount = unit_amount
    @currency = currency
    @interval = interval
    @product_id = product_id
    @active = active
    @nickname = nickname
  end

  def one_time?
    interval == "one_time"
  end

  def recurring?
    !one_time?
  end

  def [](key)
    public_send(key)
  end

  class << self
    def all
      Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_EXPIRY) { fetch_all }
    end

    def find(price_id)
      return nil if price_id.blank?

      all.find { |price| price.id == price_id } || fetch_one(price_id)
    end

    def clear_cache
      Rails.cache.delete(CACHE_KEY)
    end

    private

    def fetch_all
      return [] unless stripe_configured?

      price_ids = configured_price_ids
      return [] if price_ids.empty?

      prices = price_ids.filter_map { |id| fetch_one(id) }
      prices.sort_by { |p| [p.interval == "year" ? 0 : 1, p.unit_amount] }
    end

    def fetch_one(price_id)
      return nil unless stripe_configured?

      stripe_price = Stripe::Price.retrieve(price_id)
      from_stripe(stripe_price)
    rescue Stripe::StripeError => e
      Rails.logger.error("Failed to fetch Stripe price #{price_id}: #{e.message}")
      nil
    end

    def from_stripe(stripe_price)
      new(
        id: stripe_price.id,
        unit_amount: stripe_price.unit_amount,
        currency: stripe_price.currency.upcase,
        interval: stripe_price.recurring&.interval || "one_time",
        product_id: stripe_price.product,
        active: stripe_price.active,
        nickname: stripe_price.nickname
      )
    end

    def configured_price_ids
      Rails.application.config_for(:settings)[:plan_price_ids] || []
    end

    def stripe_configured?
      Rails.application.credentials.dig(:stripe, :private_key).present?
    end
  end
end
