# frozen_string_literal: true

# A signed blob id from a download URL is not proof that this user uploaded the
# file. Permit direct-upload ids only for blobs this user created, or for
# blobs already attached to the record being edited.
module UploadParams
  extend ActiveSupport::Concern

  private

  def uploads_only(permitted, record, *keys)
    keys.each do |key|
      value = permitted[key]
      next unless value

      permitted[key] = if value.is_a?(Array)
                         value.select { |attachable| authorized_attachable?(attachable, record, key) }
                       elsif authorized_attachable?(value, record, key)
                         value
                       end
      permitted.delete(key) if permitted[key].nil?
    end
    permitted
  end

  def authorized_attachable?(attachable, record, name)
    return true if attachable.is_a?(ActionDispatch::Http::UploadedFile)
    return false unless attachable.is_a?(String)

    blob = ActiveStorage::Blob.find_signed(attachable)
    return false unless blob
    return true if record.persisted? && blob.attachments.exists?(record:, name: name.to_s)

    blob.attachments.none? && ActiveStorage::DirectUploadAuthorization.owned_by_current_user?(blob)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    false
  end
end
