# frozen_string_literal: true

# Extend the default DirectUpload signed-URL expiry from 5 minutes to 48 hours.
# When a CDN (e.g. Cloudflare) buffers the upload before forwarding to origin,
# the default 5-minute window can expire before the file reaches the storage
# service. 48 hours covers even very large files on slow connections.
#
# Based on Basecamp's fizzy pattern.

module ActiveStorage
  mattr_accessor :service_urls_for_direct_uploads_expire_in, default: 48.hours
end

module ActiveStorageBlobServiceUrlForDirectUploadExpiry
  def service_url_for_direct_upload(expires_in: ActiveStorage.service_urls_for_direct_uploads_expire_in)
    super
  end
end

ActiveSupport.on_load :active_storage_blob do
  prepend ActiveStorageBlobServiceUrlForDirectUploadExpiry
end
