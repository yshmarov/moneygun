# frozen_string_literal: true

module PgHero
  class CaptureSpaceStatsJob < ApplicationJob
    def perform
      return unless ActiveRecord::Base.connection.data_source_exists?("pghero_space_stats")

      PgHero.capture_space_stats
    rescue ActiveRecord::ActiveRecordError, PgHero::Error => e
      Rails.logger.warn("[PgHero] space stats capture skipped: #{e.message}")
    end
  end
end
