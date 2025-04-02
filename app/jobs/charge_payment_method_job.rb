# organization = Organization.find(1)
# ChargePaymentMethodJob.perform_now(organization, :starter)
class ChargePaymentMethodJob < ApplicationJob
  queue_as :default

  def perform(organization, credit_pack)
    processor_id = organization.payment_processor.processor_id
    payment_method = Stripe::PaymentMethod.list(customer: processor_id).first.id
    credit_pack = UsageCredits.find_credit_pack(credit_pack.name)

    payment_intent = Stripe::PaymentIntent.create({
                                                    amount: credit_pack.price_cents,
                                                    currency: credit_pack.price_currency,
                                                    payment_method:,
                                                    confirm: true,
                                                    metadata: {
                                                      pack_name: credit_pack.name,
                                                      credits: credit_pack.credits,
                                                      bonus_credits: credit_pack.bonus_credits
                                                    },
                                                    customer: processor_id,
                                                    automatic_payment_methods: { enabled: true,
                                                                                 allow_redirects: "never" }
                                                  })

    if payment_intent.status == "succeeded"
      organization.give_credits(credit_pack.total_credits, reason: credit_pack.name)
    end
    payment_intent
  end
end
