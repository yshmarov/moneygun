# frozen_string_literal: true

class CspReportsController < ApplicationController
  allow_unauthenticated_access
  skip_forgery_protection

  SAFE_FIELDS = %w[violated-directive effective-directive blocked-uri disposition].freeze

  def create
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
