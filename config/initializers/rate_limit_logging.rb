# frozen_string_literal: true

# Log which limit tripped, never the key (which may be an email address or IP).
ActiveSupport::Notifications.subscribe("rate_limit.action_controller") do |event|
  Rails.logger.warn("[RateLimit] #{event.payload.slice(:scope, :name, :count, :to).to_json}")
end
