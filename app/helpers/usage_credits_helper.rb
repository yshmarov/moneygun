module UsageCreditsHelper
  def price_per_credit(credit_pack)
    total_credits = credit_pack.credits + credit_pack.bonus_credits
    price_per_credit = (credit_pack.price_cents.to_f/100) / total_credits
    number_to_currency(price_per_credit, unit: credit_pack.price_currency)
  end

  def credit_pack_label(credit_pack)
    price_per_credit = price_per_credit(credit_pack)

    label = "#{credit_pack.name.to_s.titleize} - #{credit_pack.credits} credits"
    label += " (+#{credit_pack.bonus_credits} bonus)" if credit_pack.bonus_credits > 0
    label += " (#{number_to_currency(credit_pack.price_cents.to_f / 100, unit: credit_pack.price_currency)}"
    label += " - #{price_per_credit}/credit)"
    label
  end
end
