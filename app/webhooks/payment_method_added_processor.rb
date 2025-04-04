# frozen_string_literal: true

# NOT USED
class PaymentMethodAddedProcessor
  def call(event)
    stripe_customer_id = event.data.object.customer
    pay_customer = Pay::Customer.find_by(processor_id: stripe_customer_id)
    organization = pay_customer.owner

    organization.give_credits(50, reason: "payment_method_added")
  end
end
