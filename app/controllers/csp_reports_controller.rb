# frozen_string_literal: true

class CspReportsController < ApplicationController
  allow_unauthenticated_access
  skip_forgery_protection
  rate_limit to: 30, within: 1.minute, by: -> { anonymous_ip }

  SAFE_FIELDS = %w[violated-directive effective-directive blocked-uri disposition].freeze
  MAX_REPORT_SIZE = 64.kilobytes

  def create
    return head :content_too_large if request.content_length.to_i > MAX_REPORT_SIZE

    report = parsed_report["csp-report"] || parsed_report
    Rails.logger.warn("[CSP] violation: #{report.slice(*SAFE_FIELDS).to_json}") if report.is_a?(Hash) && report.present?

    head :no_content
  end

  private

  def parsed_report
    @parsed_report ||= JSON.parse(request.raw_post.presence || "{}")
  rescue JSON::ParserError
    @parsed_report = {}
  end
end
