# frozen_string_literal: true

Rails.application.configure do
  boolean = ActiveModel::Type::Boolean.new

  config.good_job.preserve_job_records = true
  config.good_job.retry_on_unhandled_error = false
  config.good_job.on_thread_error = ->(exception) { Rails.logger.error(exception) }
  config.good_job.execution_mode = ENV.fetch("GOOD_JOB_EXECUTION_MODE", :external).to_sym
  config.good_job.queues = ENV.fetch("GOOD_JOB_QUEUES", "*")
  config.good_job.max_threads = ENV.fetch("GOOD_JOB_MAX_THREADS", 5).to_i
  config.good_job.poll_interval = ENV.fetch("GOOD_JOB_POLL_INTERVAL", 10).to_i
  config.good_job.shutdown_timeout = ENV.fetch("GOOD_JOB_SHUTDOWN_TIMEOUT", 25).to_i
  config.good_job.enable_cron = boolean.cast(ENV.fetch("GOOD_JOB_ENABLE_CRON", !Rails.env.production?))
  config.good_job.cron_graceful_restart_period = ENV.fetch("GOOD_JOB_CRON_GRACEFUL_RESTART_PERIOD", 60).to_i

  config.good_job.cron = {
    cleanup_magic_links: { cron: "0 * * * *", class: "MagicLink::CleanupJob" },
    cleanup_saml_requests: { cron: "20 * * * *", class: "SamlAuthRequest::CleanupJob" },
    cleanup_sessions: { cron: "30 3 * * *", class: "Session::CleanupJob" },
    purge_invitations: { cron: "45 2 * * *", class: "Invitation::PurgeJob" },
    purge_data_exports: { cron: "15 3 * * *", class: "DataExport::PurgeJob" },
    purge_unattached_blobs: { cron: "45 3 * * *", class: "ActiveStorage::PurgeUnattachedBlobsJob" },
    purge_soft_deleted_organizations: { cron: "30 4 * * *", class: "Organization::PurgeJob" },
    clamav_signature_update: { cron: "0 4 * * *", class: "ClamavUpdateJob" },
    capture_pghero_query_stats: { cron: "*/15 * * * *", class: "PgHero::CaptureQueryStatsJob" },
    capture_pghero_space_stats: { cron: "30 5 * * *", class: "PgHero::CaptureSpaceStatsJob" }
  }

  config.after_initialize do
    next unless boolean.cast(ENV.fetch("GOOD_JOB_ENABLE_CRON", false))

    recently_refreshed = ActiveRecord::Base.connection.select_value(<<~SQL.squish)
      SELECT 1 FROM good_jobs
      WHERE serialized_params->>'job_class' = 'ClamavUpdateJob'
        AND finished_at > NOW() - INTERVAL '24 hours'
        AND error IS NULL
      LIMIT 1
    SQL
    ClamavUpdateJob.perform_later if recently_refreshed.blank?
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.warn("[ClamAV] boot-time signature seed skipped: #{e.message}")
  end
end
