# frozen_string_literal: true

module PgHero
  class CaptureQueryStatsJob < ApplicationJob
    def perform
      return unless ActiveRecord::Base.connection.data_source_exists?("pghero_query_stats")
      return unless PgHero.databases.each_value.any?(&:query_stats_enabled?)

      PgHero.capture_query_stats
    rescue ActiveRecord::ActiveRecordError, PgHero::Error => e
      Rails.logger.warn("[PgHero] query stats capture skipped: #{e.message}")
    end
  end
end
