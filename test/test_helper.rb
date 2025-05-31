ENV["RAILS_ENV"] ||= "test"

require_relative "supports/simplecov"
require_relative "../config/environment"
require "rails/test_help"
require "ostruct"

module ActiveSupport
  class TestCase
    include Devise::Test::IntegrationHelpers

    # Run tests in parallel with specified workers
    parallelize_setup do |_worker|
      SimpleCov.command_name "Job::#{Process.pid}" if const_defined?(:SimpleCov)
    end

    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module GoogleOauth2Helper
  def login_with_google_oauth2_oauth
    file = File.read("test/fixtures/google_oauth2.json")
    parsed_file = JSON.parse(file, object_class: OpenStruct)

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = parsed_file
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
  end
end
