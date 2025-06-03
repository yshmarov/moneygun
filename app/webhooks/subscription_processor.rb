# frozen_string_literal: true

class SubscriptionProcessor
  def call(event)
    stripe_customer_id = event.data.object.customer
    pay_customer = Pay::Customer.find_by(processor_id: stripe_customer_id)
    user = pay_customer.owner

    # TODO: add telegram user
    send_admin_notification(pay_customer, event)
  end

  private

  def send_admin_notification(pay_customer, event)
    user = pay_customer.owner
    subscription = pay_customer.subscription
    # safest to get latest subscription from Stripe
    # stripe_subscription_id = event.data.object.id
    # subscription = Stripe::Subscription.retrieve(stripe_subscription_id)
    stripe_plan = subscription.data["subscription_items"].first["price"]

    message = <<~MSG
      wow #{user.email} paid #{stripe_plan["unit_amount"].to_f / 100}
    MSG
    Telegrama.send_message(message, chat_id: Rails.application.config_for(:settings).dig(:telegram, :admin_chat_id))
  end
end
