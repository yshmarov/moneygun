# frozen_string_literal: true

module ActiveStorage::VirusScanGuard
  extend ActiveSupport::Concern

  included do
    before_action :reject_unscanned_blob
    before_action :reject_unsafe_image
  end

  private

  def reject_unscanned_blob
    status = ActiveStorageSafety.scan_status(@blob)
    head :forbidden unless status.nil? || status == "clean"
  end

  def reject_unsafe_image
    head :forbidden if @blob.metadata["safe"] == false
  end
end
