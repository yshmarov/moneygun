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
    after_create_commit :give_payment_method_added_credits
  end

  def give_payment_method_added_credits
    customer.owner.give_credits(100, reason: "payment_method_added")
  end
end

Rails.configuration.to_prepare do
  Pay::PaymentMethod.include PaymentMethodExtensions
end
