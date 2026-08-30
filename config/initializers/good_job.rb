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
    maintenance: {
      cron: "15 * * * *",
      class: "MaintenanceJob",
      description: "Remove expired authentication state and abandoned uploads"
    }
  }
end
