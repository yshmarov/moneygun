# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError

  # Don't retry on validation errors - these won't succeed on retry
  discard_on ActiveRecord::RecordInvalid

  discard_on ActiveRecord::RecordNotFound

  retry_on ActiveRecord::ConnectionNotEstablished, wait: 5.seconds, attempts: 3
  retry_on Timeout::Error, wait: :exponentially_longer, attempts: 3
end
