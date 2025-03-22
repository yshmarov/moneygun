# frozen_string_literal: true

module PlanHelper
  def subscription_status_label(user, class_list: nil)
    return "🚫" unless user.payment_processor.subscribed?
    return "🚨" if user.payment_processor.subscription.cancelled?

    "✅"
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
    plans = Rails.application.config_for(:settings).dig(:plans)
    plans.find { |plan| plan[:id] == subscription.processor_plan }
  end
end
