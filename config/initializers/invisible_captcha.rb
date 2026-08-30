# frozen_string_literal: true

InvisibleCaptcha.setup do |config|
  config.visual_honeypots = false
  config.timestamp_threshold = 0.5
  config.timestamp_enabled = !Rails.env.test?
  config.spinner_enabled = false
  config.honeypots = %w[subtitle_ic nickname_ic company_ic address_ic website_ic]
end
