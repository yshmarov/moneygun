# frozen_string_literal: true

# Backport of Rails 8.2 combined credentials (Rails.app.creds).
# Checks ENV first, then falls back to encrypted credentials.
# ENV keys are derived by uppercasing and joining nested keys with "__" (double underscore).
#
# Examples:
#   Rails.app.creds.option(:stripe, :private_key)
#   # => ENV["STRIPE__PRIVATE_KEY"] || credentials.dig(:stripe, :private_key)
#
#   Rails.app.creds.require(:stripe, :private_key)
#   # => same, but raises KeyError if missing from both
#
# TODO: Remove this file after upgrading to Rails 8.2+

unless Rails.respond_to?(:app)
  class AppCreds
    def option(*keys, default: nil)
      env_value(*keys) || Rails.application.credentials.dig(*keys) || default
    end

    def require(*keys)
      value = option(*keys)
      raise KeyError, "Missing credential: #{keys.map(&:to_s).join('.')}" if value.blank?
      value
    end

    private

    def env_value(*keys)
      env_key = keys.map { |k| k.to_s.upcase }.join("__")
      ENV[env_key].presence
    end
  end

  class AppContainer
    def creds
      @creds ||= AppCreds.new
    end

    def credentials
      Rails.application.credentials
    end
  end

  Rails.define_singleton_method(:app) { @_app ||= AppContainer.new }
end
