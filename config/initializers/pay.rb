Pay.setup do |config|
  config.business_name = Rails.application.config_for(:settings).dig(:site, :name)
  config.business_address = Rails.application.config_for(:settings).dig(:site, :address)
  config.application_name = Rails.application.config_for(:settings).dig(:site, :name)
  config.support_email = "#{Rails.application.config_for(:settings).dig(:site, :name)} <#{Rails.application.config_for(:settings).dig(:site, :email)}>"
  config.enabled_processors = [ :stripe ]
  config.send_emails = false

  # ActiveSupport.on_load(:pay) do
  #   Pay::Webhooks.delegator.subscribe "payment_method.attached", PaymentMethodAddedProcessor.new
  #   # setup_intent.succeeded
  # end
end

module PaymentMethodExtensions
  extend ActiveSupport::Concern

  included do
    after_create_commit :give_credits
  end

  def give_credits
    customer.owner.give_credits(100, reason: "payment_method_added")
  end

  def bizz
    "buzz"
  end
end

Rails.configuration.to_prepare do
  # Pay::Stripe::PaymentMethod.include PaymentMethodExtensions
  Pay::PaymentMethod.include PaymentMethodExtensions
end
