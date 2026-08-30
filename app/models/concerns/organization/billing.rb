# frozen_string_literal: true

module Organization::Billing
  extend ActiveSupport::Concern

  included do
    pay_customer default_payment_processor: :stripe, stripe_attributes: :stripe_attributes

    scope :subscribed, lambda {
      kept.where(id: Pay::Subscription.active.for_name(Pay.default_product_name)
                     .joins(:customer)
                     .where(pay_customers: { owner_type: "Organization", deleted_at: nil })
                     .select("pay_customers.owner_id"))
    }
    scope :with_access, -> { subscribed.or(kept.where(admin_granted_access: true)) }
  end

  def stripe_attributes(pay_customer)
    {
      metadata: {
        pay_customer_id: pay_customer.id,
        organization_id: id
      }
    }
  end

  def pay_should_sync_customer?
    super || saved_change_to_owner_id?
  end

  def trial_days
    Rails.application.config_for(:settings)[:free_trial_days].to_i
  end

  # rubocop:disable Naming/PredicatePrefix
  def has_access?
    return true if admin_granted_access?
    return false unless payment_processor

    payment_processor.subscribed?
  end
  # rubocop:enable Naming/PredicatePrefix

  def active_subscription?
    return false unless payment_processor

    subscription = payment_processor.subscription
    subscription.present? && subscription.ends_at.nil?
  end

  def complimentary_access?
    admin_granted_access? && !active_subscription?
  end

  def trial_eligible?
    return false if has_access? || !trial_days.positive?

    payment_processor.nil? || payment_processor.subscription.nil?
  end

  delegate :email, to: :owner
end
