# frozen_string_literal: true

module SubscriptionHelper
  def subscription_status_label(organization)
    return "🔴" unless organization.has_access?
    return "🟠" if organization.payment_processor&.subscription&.cancelled? && !organization.complimentary_access?

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
    StripePrice.find(subscription.processor_plan)
  end

  def plans
    StripePrice.all
  end

  def subscription_plan_labels(subscription)
    if subscription.on_trial? && subscription.on_grace_period?
      {
        status: t("organizations.subscriptions.plan.trial_cancelled"),
        access: t("organizations.subscriptions.plan.you_will_lose_access_in", distance_of_time_in_words: distance_of_time_in_words(subscription.trial_ends_at, Time.current)),
        button: t("organizations.subscriptions.plan.resume_subscription"),
        date: subscription.trial_ends_at
      }
    elsif subscription.on_trial?
      {
        status: t("organizations.subscriptions.plan.free_trial"),
        access: t("organizations.subscriptions.plan.first_charge"),
        button: t("organizations.subscriptions.plan.manage_billing"),
        date: subscription.trial_ends_at
      }
    elsif subscription.on_grace_period?
      {
        status: t("organizations.subscriptions.plan.cancelled"),
        access: t("organizations.subscriptions.plan.you_will_lose_access_in", distance_of_time_in_words: distance_of_time_in_words(subscription.current_period_end, Time.current)),
        button: t("organizations.subscriptions.plan.resume_subscription"),
        date: subscription.current_period_end
      }
    else
      {
        status: t("organizations.subscriptions.plan.active"),
        access: t("organizations.subscriptions.plan.next_billing_date"),
        button: t("organizations.subscriptions.plan.manage_billing"),
        date: subscription.current_period_end
      }
    end
  end
end
