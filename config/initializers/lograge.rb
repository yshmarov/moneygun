# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = Rails.env.production?
  config.lograge.custom_options = lambda do |event|
    path = event.payload[:path]
    options = { request_id: event.payload[:request_id] }
    options[:path] = "/rails/active_storage/[FILTERED]" if path&.start_with?("/rails/active_storage/")
    options
  end
end
