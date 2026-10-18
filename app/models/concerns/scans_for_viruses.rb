# frozen_string_literal: true

module ScansForViruses
  extend ActiveSupport::Concern

  class_methods do
    def scans_attachments_for_viruses(*names)
      class_attribute :virus_scanned_attachment_names, instance_writer: false, default: []
      self.virus_scanned_attachment_names = names.map(&:to_s).freeze
      after_commit :enqueue_virus_scans, on: %i[create update]
    end
  end

  def self.covers?(attachment)
    model = attachment.record_type.safe_constantize
    model.respond_to?(:virus_scanned_attachment_names) && model.virus_scanned_attachment_names.include?(attachment.name)
  end

  def self.enqueue_scan(blob)
    enqueue = blob.with_lock do
      next false if ActiveStorageSafety.recorded_scan_status(blob).present?

      blob.update!(metadata: blob.metadata.merge(ActiveStorageSafety::VIRUS_SCAN_STATUS_KEY => "pending"))
      true
    end
    VirusScanJob.perform_later(blob) if enqueue
  end

  private

  def enqueue_virus_scans
    virus_scanned_attachment_names.each do |name|
      attached = public_send(name)
      next unless attached.attached?

      attachments = attached.respond_to?(:attachments) ? attached.attachments : [attached]
      attachments.each { |attachment| ScansForViruses.enqueue_scan(attachment.blob) }
    end
  end
end
