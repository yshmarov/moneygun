# frozen_string_literal: true

class MaintenanceJob < ApplicationJob
  queue_as :default

  def perform
    Session.cleanup
    MagicLink.cleanup
    SamlAuthRequest.cleanup
    Invitation.expired.where(created_at: ..30.days.ago).delete_all
    DataExport::PurgeJob.perform_later
    purge_abandoned_uploads
  end

  private

  def purge_abandoned_uploads
    ActiveStorage::Blob.unattached.where(created_at: ..24.hours.ago).find_each(&:purge_later)
  end
end
