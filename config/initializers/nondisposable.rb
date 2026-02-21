# frozen_string_literal: true

Nondisposable.configure do |config|
  config.error_message = "is invalid"
  config.excluded_domains = %w[privaterelay.appleid.com]
end
