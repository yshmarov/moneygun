Pay.setup do |config|
  config.business_name = Rails.application.config_for(:settings).dig(:site, :name)
  config.business_address = Rails.application.config_for(:settings).dig(:site, :address)
  config.application_name = Rails.application.config_for(:settings).dig(:site, :name)
  config.support_email = "#{Rails.application.config_for(:settings).dig(:site, :name)} <#{Rails.application.config_for(:settings).dig(:site, :email)}>"
  config.enabled_processors = [ :stripe ]
  config.send_emails = false
end

module PaymentMethodExtensions
  extend ActiveSupport::Concern

  included do
    after_create_commit :reward_first_payment_method
  end

  def reward_first_payment_method
    return if customer.owner.payment_processor.payment_methods.count > 1

    customer.owner.give_credits(100, reason: "first_payment_method_added")
  end
end

# Pay::Charge.new.respond_to?(:complete_referral, true)
module ChargeExtensions
  extend ActiveSupport::Concern

  included do
    after_create_commit :complete_referral
  end

  def complete_referral
    customer.owner.owner.referral&.complete!
  end
end

Rails.configuration.to_prepare do
  Pay::PaymentMethod.include PaymentMethodExtensions
  Pay::Charge.include ChargeExtensions
end
