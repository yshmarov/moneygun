# frozen_string_literal: true

require "test_helper"

class CspReportsControllerTest < ActionDispatch::IntegrationTest
  test "accepts reports without authentication" do
    post csp_reports_url,
         params: { "csp-report" => { "blocked-uri" => "https://evil.example/x.js" } }.to_json,
         headers: { "CONTENT_TYPE" => "application/csp-report" }

    assert_response :no_content
  end

  test "tolerates malformed reports" do
    post csp_reports_url, params: "not json", headers: { "CONTENT_TYPE" => "application/csp-report" }

    assert_response :no_content
  end

  test "does not log document URLs" do
    output = StringIO.new
    original_logger = Rails.logger
    Rails.logger = ActiveSupport::Logger.new(output)

    post csp_reports_url,
         params: { "csp-report" => { "document-uri" => "https://example.com/private/secret", "blocked-uri" => "https://evil.example/x.js" } }.to_json,
         headers: { "CONTENT_TYPE" => "application/csp-report" }

    assert_no_match "private/secret", output.string
    assert_match "evil.example", output.string
  ensure
    Rails.logger = original_logger
  end
end
