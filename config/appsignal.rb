# frozen_string_literal: true

Appsignal.configure do |config|
  config.activate_if_environment("production") unless ENV.key?("APPSIGNAL_ACTIVE")
  config.name = Rails.application.config_for(:settings).dig(:site, :name)
  config.push_api_key ||= Rails.application.credentials.appsignal
  config.revision ||= ENV["APPSIGNAL_APP_REVISION"].presence || ENV["APP_REVISION"].presence || ENV["KAMAL_VERSION"].presence
  config.send_session_data = false
end
