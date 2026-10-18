# frozen_string_literal: true

module CronCheckIn
  extend ActiveSupport::Concern

  included do
    around_perform do |job, block|
      identifier = CronCheckIn.identifier_for(job.class.name)
      identifier ? Appsignal::CheckIn.cron(identifier) { block.call } : block.call
    end
  end

  def self.identifier_for(job_class_name)
    identifiers[job_class_name]
  end

  def self.identifiers
    Rails.application.config.good_job.cron.to_h do |identifier, entry|
      [entry[:class], identifier.to_s]
    end
  end
end
