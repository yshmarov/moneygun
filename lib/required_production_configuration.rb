# frozen_string_literal: true

class RequiredProductionConfiguration
  class MissingConfigurationError < StandardError; end

  BASE_VARIABLES = %w[HOST DATABASE_URL].freeze
  S3_VARIABLES = %w[AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY BUCKET_NAME].freeze

  def self.verify!(environment: ENV)
    required = BASE_VARIABLES.dup
    required.concat(S3_VARIABLES) if environment.fetch("ACTIVE_STORAGE_SERVICE", "s3") == "s3"
    missing = required.reject { |key| environment[key].present? }
    return if missing.empty?

    raise MissingConfigurationError, "Missing required production configuration: #{missing.join(', ')}"
  end
end
