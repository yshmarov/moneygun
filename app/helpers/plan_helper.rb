# frozen_string_literal: true

module PlanHelper
  def subscription_status_label(user, class_list: nil)
    return unless user.payment_processor.subscribed?
    return "🚨" if user.payment_processor.subscription.cancelled?

    inline_svg_tag "svg/check-badge.svg", class: [ "stroke-white fill-blue-600 inline", class_list ]
  end

  CURRENCY_SYMBOLS = {
    "usd" => "$",
    "eur" => "€",
    "pln" => "zł"
  }.freeze

  def currency_symbol(currency)
    CURRENCY_SYMBOLS[currency.downcase]
  end
end
