# frozen_string_literal: true

class VirusScanJob < ApplicationJob
  class ScannerUnavailableError < StandardError; end
  class ScannerError < StandardError; end

  queue_as :virus_scan

  def self.mark_failed(job, error)
    blob = job.arguments.first
    Rails.error.report(error, handled: true, severity: :warning, context: { blob_id: blob.id }, source: "virus_scan")
    ActiveStorageSafety.update_scan_status!(blob, "failed")
  rescue ActiveRecord::RecordNotFound
    nil
  end

  retry_on StandardError, wait: :polynomially_longer, attempts: 3 do |job, error|
    mark_failed(job, error)
  end
  retry_on ScannerUnavailableError, wait: 5.minutes, attempts: 5 do |job, error|
    mark_failed(job, error)
  end
  discard_on ActiveRecord::RecordNotFound

  def perform(blob)
    result = blob.open { |tempfile| AntivirusScanner.client.scan(tempfile.path) }

    case result.status
    when :clean then ActiveStorageSafety.update_scan_status!(blob, "clean")
    when :infected then blob.attachments.each(&:purge)
    when :unavailable then raise ScannerUnavailableError, "Antivirus scanner unavailable for blob##{blob.id}", cause: result.error
    when :error then raise ScannerError, "Antivirus scan failed for blob##{blob.id}", cause: result.error
    end
  end
end
