# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

if ENV["COVERAGE"] == "true"
  require "simplecov"

  SimpleCov.start "rails" do
    enable_coverage :branch
    skip "/test/"
    skip "/vendor/"
  end
end

require_relative "../config/environment"
require "rails/test_help"
require "factory_bot_rails"
require "mocha/minitest"
require "webmock/minitest"

WebMock.disable_net_connect!(allow_localhost: true)

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods

    workers = if ENV["TEST_WORKERS"]
                ENV.fetch("TEST_WORKERS").to_i
              elsif RUBY_PLATFORM.match?(/arm64.*darwin/)
                1
              else
                :number_of_processors
              end
    parallelize(workers: workers)

    parallelize_setup do |worker|
      SimpleCov.at_fork.call(worker) if ENV["COVERAGE"] == "true"
    end

    parallelize_teardown do |_worker|
      SimpleCov.result if ENV["COVERAGE"] == "true"
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def sign_in(user)
      session_record = user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1")
      host! "example.com" if respond_to?(:host!)
      cookies[:session_token] = session_record.signed_id
    end

    def sign_out(_user = nil)
      cookies[:session_token] = "" if respond_to?(:cookies)
    end

    def authenticate_sudo(user)
      magic_link = user.magic_links.create!(purpose: :sudo)
      post sudo_path, params: { code: magic_link.code }
    end

    def accept_agreement(agreement_key, subject:, actor: subject, authority: "self")
      version = Agreements.current_version(agreement_key)
      Agreements.accept!(agreement_key, version_id: version.id, subject:, actor:, authority:,
                                        acceptance_statement: version.acceptance_statement, locale: "en")
    end

    def encrypt_cookie_value(name, value)
      jar = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
      jar.encrypted[name] = value
      jar[name]
    end

    def decrypt_cookie_value(name, value)
      jar = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
      jar[name] = value
      jar.encrypted[name]
    end

    def create_sso_connection(organization, domains: ["acme.com"], verified: true, **attributes)
      connection = organization.build_sso_connection(**attributes)
      Array(domains).each do |domain|
        connection.sso_domains.build(domain: domain, verified_at: (Time.current if verified))
      end
      connection.save!
      connection
    end
  end
end

module SamlTestCertificate
  def self.pem
    @pem ||= begin
      key = OpenSSL::PKey::RSA.new(2048)
      certificate = OpenSSL::X509::Certificate.new
      certificate.version = 2
      certificate.serial = 1
      certificate.subject = certificate.issuer = OpenSSL::X509::Name.new([["CN", "idp.example.com"]])
      certificate.public_key = key.public_key
      certificate.not_before = Time.current.to_time
      certificate.not_after = 10.years.from_now.to_time
      certificate.sign(key, OpenSSL::Digest.new("SHA256"))
      certificate.to_pem
    end
  end
end
