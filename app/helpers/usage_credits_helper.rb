module UsageCreditsHelper
  def price_per_credit(credit_pack)
    total_credits = credit_pack.credits + credit_pack.bonus_credits
    price_per_credit = (credit_pack.price_cents.to_f/100) / total_credits
    number_to_currency(price_per_credit, unit: credit_pack.price_currency)
  end

  def credit_pack_label(credit_pack)
    price_per_credit = price_per_credit(credit_pack)

    label = "#{format_credits(credit_pack.credits)}"
    label += " (+#{credit_pack.bonus_credits} bonus)" if credit_pack.bonus_credits > 0
    label += " - #{format_credit_price(credit_pack.price_cents)}"
    label += " (#{price_per_credit}/credit)"
    label
  end

  def credits_badge(organization)
    content_tag(:div, class: "font-medium border border-gray-200 bg-amber-400 rounded-lg px-1") do
      concat content_tag(:span, organization.credits.to_s, data: { controller: "animated-number", animated_number_start_value: "0", animated_number_end_value: organization.credits, animated_number_duration_value: "300" })
      concat " credits"
    end
  end
end
