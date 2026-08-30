# frozen_string_literal: true

require "uri"

class RequiredProductionConfiguration
  class MissingConfigurationError < StandardError; end
  class InvalidConfigurationError < StandardError; end

  BASE_VARIABLES = %w[HOST WEBSITE_URL DATABASE_URL].freeze
  S3_VARIABLES = %w[AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY BUCKET_NAME].freeze

  def self.verify!(environment: ENV)
    required = BASE_VARIABLES.dup
    required.concat(S3_VARIABLES) if environment.fetch("ACTIVE_STORAGE_SERVICE", "s3") == "s3"
    missing = required.reject { |key| environment[key].present? }
    raise MissingConfigurationError, "Missing required production configuration: #{missing.join(', ')}" if missing.any?

    website_uri = URI.parse(environment.fetch("WEBSITE_URL"))
    app_host = environment.fetch("HOST")
    valid_website = website_uri.is_a?(URI::HTTP) && website_uri.host.present? && website_uri.path.in?(["", "/"])
    valid_app_subdomain = valid_website && app_host.end_with?(".#{website_uri.host}")
    return if valid_website && valid_app_subdomain

    raise InvalidConfigurationError, "WEBSITE_URL must be an HTTP(S) apex origin and HOST must be its application subdomain"
  rescue URI::InvalidURIError
    raise InvalidConfigurationError, "WEBSITE_URL must be an HTTP(S) apex origin and HOST must be its application subdomain"
  end
end
