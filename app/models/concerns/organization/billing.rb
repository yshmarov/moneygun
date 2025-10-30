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

  delegate :email, to: :owner
end
