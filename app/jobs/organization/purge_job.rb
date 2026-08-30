# frozen_string_literal: true

class Organization::PurgeJob < ApplicationJob
  include ActiveJob::Continuable

  def perform
    cutoff = Rails.application.config_for(:settings).fetch(:organization_purge_after_days, 30).days.ago

    step :purge_organizations do |step|
      Organization.soft_deleted.where(deleted_at: ..cutoff).find_each(start: step.cursor) do |organization|
        organization.destroy!
        step.advance! from: organization.id
      end
    end

    step :purge_orphaned_redacted_users do
      User.redacted.where.missing(:memberships).find_each(&:destroy!)
    end
  end
end
