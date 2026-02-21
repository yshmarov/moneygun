# frozen_string_literal: true

Rails.application.configure do
  config.good_job.preserve_job_records = true
  config.good_job.retry_on_unhandled_error = false
  config.good_job.on_thread_error = ->(exception) { Rails.logger.error(exception) }
  config.good_job.execution_mode = ENV.fetch("GOOD_JOB_EXECUTION_MODE", :external).to_sym
  config.good_job.queues = "*"
  config.good_job.max_threads = ENV.fetch("GOOD_JOB_MAX_THREADS", 5).to_i
  config.good_job.poll_interval = 1
  config.good_job.enable_cron = true

  config.good_job.cron = {}
end
