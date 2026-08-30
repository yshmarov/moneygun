# frozen_string_literal: true

module StripsFileMetadata
  extend ActiveSupport::Concern

  included do
    before_validation :strip_file_metadata
  end

  private

  def strip_file_metadata
    attachment_changes.each do |name, change|
      pairs = case change
              when ActiveStorage::Attached::Changes::CreateMany then change.attachables.zip(change.blobs)
              when ActiveStorage::Attached::Changes::CreateOne then [[change.attachable, change.blob]]
              else []
              end

      pairs.each do |attachable, blob|
        next unless attachable.is_a?(ActionDispatch::Http::UploadedFile)

        FileMetadataStripper.strip!(attachable.tempfile.path, attachable.content_type)
        blob.unfurl(attachable.open)
      rescue FileMetadataStripper::Error => e
        Rails.logger.warn("File metadata stripping failed for #{name}: #{e.message}")
        errors.add(:base, :metadata_stripping_failed)
      end
    end
  end
end
