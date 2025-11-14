# frozen_string_literal: true

module Organization::Billing
  extend ActiveSupport::Concern

  included do
    pay_customer default_payment_processor: :stripe, stripe_attributes: :stripe_attributes
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

  # rubocop:disable Naming/PredicatePrefix
  def has_access?
    return false unless payment_processor

    # Check for active subscription OR successful one-time payment (not fully refunded)
    payment_processor.subscribed? || payment_processor.charges.where("amount_refunded IS NULL OR amount_refunded < amount").exists?
  end
  # rubocop:enable Naming/PredicatePrefix

  delegate :email, to: :owner
end
