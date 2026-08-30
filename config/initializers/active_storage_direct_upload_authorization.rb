# frozen_string_literal: true

module ActiveStorage::DirectUploadAuthorization
  extend ActiveSupport::Concern

  included do
    rate_limit to: 60, within: 10.minutes, by: -> { request.remote_ip }, only: :create,
               with: -> { head :too_many_requests }
    before_action :require_direct_upload_session, only: :create
  end

  private

  def require_direct_upload_session
    Current.session = Session.resume_from_cookie(cookies[:session_token], cookies: cookies)
    head :forbidden unless Current.user
  end
end

Rails.application.config.to_prepare do
  ActiveStorage::DirectUploadsController.include(ActiveStorage::DirectUploadAuthorization)
end
