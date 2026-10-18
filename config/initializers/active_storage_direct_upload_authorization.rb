# frozen_string_literal: true

module ActiveStorage::DirectUploadAuthorization
  extend ActiveSupport::Concern

  OWNER_KEY = "direct_upload_owner"
  MAX_AGE = 1.hour

  prepended do
    rate_limit to: 60, within: 10.minutes, by: -> { request.remote_ip }, only: :create,
               with: -> { head :too_many_requests }
    before_action :require_direct_upload_user, only: :create
  end

  def self.owned_by_current_user?(blob)
    user = Current.user
    return false unless user

    owner = blob.metadata[OWNER_KEY]
    owner == owner_digest(user) && blob.created_at >= MAX_AGE.ago
  end

  def self.owner_digest(user)
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, user.id.to_s)
  end

  private

  def require_direct_upload_user
    Current.session = Session.resume_from_cookie(cookies[:session_token], cookies: cookies)
    head :forbidden unless Current.user
  end

  def direct_upload_json(blob)
    blob.update!(metadata: blob.metadata.merge(OWNER_KEY => ActiveStorage::DirectUploadAuthorization.owner_digest(Current.user)))
    super
  end
end

Rails.application.config.to_prepare do
  ActiveStorage::DirectUploadsController.prepend(ActiveStorage::DirectUploadAuthorization)
end
