# frozen_string_literal: true

UsageCredits.configure do |config|
  #
  # Define your credit-consuming operations below
  #
  # Example:
  #
  # operation :send_email do
  #   costs 1.credit
  # end
  #
  # operation :process_image do
  #   costs 10.credits + 1.credit_per(:mb)
  #   validate ->(params) { params[:size] <= 100.megabytes }, "File too large"
  # end
  #
  # operation :generate_ai_response do
  #   costs 5.credits
  #   validate ->(params) { params[:prompt].length <= 1000 }, "Prompt too long"
  #   meta category: :ai, description: "Generate AI response"
  # end
  #
  # operation :process_items do
  #   costs 1.credit_per(:units)  # Cost per item processed
  #   meta category: :batch, description: "Process items in batch"
  # end
  #
  #
  #
  # Example credit packs (uncomment and modify as needed):
  #
  credit_pack :tiny do
    gives 10.credits
    costs 10.dollars # Price can be in cents or dollars
  end

  credit_pack :starter do
    gives 100.credits
    bonus 10.credits  # Optional bonus credits
    costs 100.dollars
  end

  credit_pack :pro do
    gives 1000.credits
    bonus 200.credits
    costs 1000.dollars
  end
  #
  #
  #
  # Example subscription plans (uncomment and modify as needed):
  #
  subscription_plan :basic do
    stripe_price "price_1R68bjLRcgxgTmfQL2kBW5pX"
    gives 100.credits.every(:month)
    signup_bonus 10.credits
    unused_credits :expire  # Credits reset each month
  end

  subscription_plan :pro do
    stripe_price "price_1R68c1LRcgxgTmfQijgGMDfT"
    gives 1000.credits.every(:month)
    signup_bonus 200.credits
    trial_includes 20.credits
    unused_credits :expire  # Credits expire at the end of the fulfillment period (use :rollover to roll over to next period)
  end
  #
  #
  #
  # Alert when balance drops below this threshold (default: 100 credits)
  # Set to nil to disable low balance alerts
  #
  config.low_balance_threshold = 5.credits
  #
  #
  # Handle low credit balance alerts – Useful to sell booster credit packs, for example
  #
  # config.on_low_balance do |user|
  # Send notification to user when their balance drops below the threshold
  # UserMailer.low_credits_alert(user).deliver_later
  # end
  #
  #
  #
  # For how long expiring credits from the previous fulfillment cycle will "overlap" the following fulfillment period.
  # During this time, old credits from the previous period will erroneously count as available balance.
  # But if we set this to 0 or nil, user balance will show up as zero some time until the next fulfillment cycle hits.
  # A good default is to match the frequency of your UsageCredits::FulfillmentJob
  # fulfillment_grace_period = 5.minutes
  #
  #
  #
  # Rounding strategy for credit calculations (default: :ceil)
  # :ceil - Always round up (2.1 => 3)
  # :floor - Always round down (2.9 => 2)
  # :round - Standard rounding (2.4 => 2, 2.6 => 3)
  #
  # config.rounding_strategy = :ceil
  #
  #
  # Format credits for display (default: "X credits")
  #
  # config.format_credits do |amount|
  #   "#{amount} credits"
  # end
end

module WalletExtensions
  extend ActiveSupport::Concern

  included do
    # def self.auto_refill_threshold
    #   100.credits
    # end

    validates :auto_refill_enabled, inclusion: { in: [ false ] }, if: -> { auto_refill_credit_pack.blank? }
  end

  def foo
    "bar"
  end
end

Rails.configuration.to_prepare do
  UsageCredits::Wallet.include WalletExtensions
end
