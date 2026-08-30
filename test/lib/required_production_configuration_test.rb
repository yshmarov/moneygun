# frozen_string_literal: true

require "test_helper"

class RequiredProductionConfigurationTest < ActiveSupport::TestCase
  test "accepts complete S3 production configuration" do
    environment = {
      "HOST" => "app.example.com",
      "WEBSITE_URL" => "https://example.com",
      "DATABASE_URL" => "postgres://example",
      "ACTIVE_STORAGE_SERVICE" => "s3",
      "AWS_ACCESS_KEY_ID" => "configured",
      "AWS_SECRET_ACCESS_KEY" => "configured",
      "BUCKET_NAME" => "configured"
    }

    assert_nothing_raised { RequiredProductionConfiguration.verify!(environment: environment) }
  end

  test "does not require S3 settings for another storage service" do
    environment = {
      "HOST" => "app.example.com", "WEBSITE_URL" => "https://example.com",
      "DATABASE_URL" => "postgres://example", "ACTIVE_STORAGE_SERVICE" => "local"
    }

    assert_nothing_raised { RequiredProductionConfiguration.verify!(environment: environment) }
  end

  test "reports all missing settings" do
    error = assert_raises(RequiredProductionConfiguration::MissingConfigurationError) do
      RequiredProductionConfiguration.verify!(environment: { "ACTIVE_STORAGE_SERVICE" => "s3" })
    end

    assert_equal "Missing required production configuration: HOST, WEBSITE_URL, DATABASE_URL, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, BUCKET_NAME", error.message
  end

  test "requires the Rails host to be a subdomain of the website host" do
    environment = {
      "HOST" => "example.com", "WEBSITE_URL" => "https://example.com",
      "DATABASE_URL" => "postgres://example", "ACTIVE_STORAGE_SERVICE" => "local"
    }

    assert_raises(RequiredProductionConfiguration::InvalidConfigurationError) do
      RequiredProductionConfiguration.verify!(environment: environment)
    end
  end

  test "rejects a website URL with a path" do
    environment = {
      "HOST" => "app.example.com", "WEBSITE_URL" => "https://example.com/marketing",
      "DATABASE_URL" => "postgres://example", "ACTIVE_STORAGE_SERVICE" => "local"
    }

    assert_raises(RequiredProductionConfiguration::InvalidConfigurationError) do
      RequiredProductionConfiguration.verify!(environment: environment)
    end
  end
end
