# frozen_string_literal: true

class VirusScanSweepJob < ApplicationJob
  GRACE_PERIOD = 1.hour
  RECORDED = %q("virus_scan_status"\s*:)
  PENDING = %q("virus_scan_status"\s*:\s*"pending")

  def perform
    unscanned_files.find_each do |attachment|
      next unless ScansForViruses.covers?(attachment)

      if ActiveStorageSafety.recorded_scan_status(attachment.blob)
        VirusScanJob.perform_later(attachment.blob)
      else
        ScansForViruses.enqueue_scan(attachment.blob)
      end
    rescue ActiveRecord::RecordNotFound
      next
    end
  end

  private

  def unscanned_files
    ActiveStorage::Attachment
      .joins(:blob).includes(:blob)
      .where(active_storage_blobs: { created_at: ...GRACE_PERIOD.ago })
      .where("active_storage_blobs.metadata IS NULL OR active_storage_blobs.metadata !~ ? OR active_storage_blobs.metadata ~ ?", RECORDED, PENDING)
  end
end
