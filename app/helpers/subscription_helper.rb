module SubscriptionHelper
  def subscription_status_label(organization)
    return "🔴" unless organization.payment_processor.subscribed?
    return "🟠" if organization.payment_processor.subscription.cancelled?

    "🟢"
  end

  CURRENCY_SYMBOLS = {
    "usd" => "$",
    "eur" => "€",
    "pln" => "zł"
  }.freeze

  def currency_symbol(currency)
    CURRENCY_SYMBOLS[currency.downcase]
  end

  def plan_for(subscription)
    plans = Rails.application.config_for(:settings)[:plans]
    plans.find { |plan| plan[:id] == subscription.processor_plan }
  end
end
