Pay.setup do |config|
  config.business_name = Rails.application.config_for(:settings).dig(:site, :name)
  config.business_address = Rails.application.config_for(:settings).dig(:site, :address)
  config.application_name = Rails.application.config_for(:settings).dig(:site, :name)
  config.support_email = "#{Rails.application.config_for(:settings).dig(:site, :name)} <#{Rails.application.config_for(:settings).dig(:site, :email)}>"
  config.enabled_processors = [ :stripe ]
  config.send_emails = false
end
