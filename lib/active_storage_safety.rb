# frozen_string_literal: true

module ActiveStorageSafety
  VIRUS_SCAN_STATUS_KEY = "virus_scan_status"
  VIRUS_SCAN_STATUSES = %w[pending clean failed].freeze
  MAX_IMAGE_DIMENSION = 10_000

  def self.scan_status(blob)
    blob.metadata[VIRUS_SCAN_STATUS_KEY]
  end

  def self.update_scan_status!(blob, status)
    raise ArgumentError, "Unknown virus scan status: #{status}" unless VIRUS_SCAN_STATUSES.include?(status)

    blob.with_lock do
      blob.update!(metadata: blob.metadata.merge(VIRUS_SCAN_STATUS_KEY => status))
    end
  end
end
