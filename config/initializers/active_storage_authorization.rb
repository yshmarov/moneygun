# frozen_string_literal: true

ActiveSupport.on_load :active_storage_blob do
  def active_storage_accessible_to?(user)
    attachments.includes(:record).any? { |attachment| attachment.active_storage_accessible_to?(user) }
  end

  def active_storage_publicly_accessible?
    attachments.includes(:record).any?(&:active_storage_publicly_accessible?)
  end
end

ActiveSupport.on_load :active_storage_attachment do
  def active_storage_accessible_to?(user)
    record.try(:active_storage_accessible_to?, user)
  end

  def active_storage_publicly_accessible?
    record.try(:active_storage_publicly_accessible?)
  end
end

ActiveSupport.on_load :action_text_rich_text do
  def active_storage_accessible_to?(user)
    record.try(:active_storage_accessible_to?, user)
  end
end

module ActiveStorage::AuthorizationGuard
  extend ActiveSupport::Concern

  included do
    before_action :resume_active_storage_session
    before_action :ensure_blob_authorized
  end

  private

  def resume_active_storage_session
    return if Current.user

    Current.session = Session.resume_from_cookie(cookies[:session_token], cookies: cookies)
  end

  def ensure_blob_authorized
    return if @blob.active_storage_publicly_accessible?
    return if Current.user && @blob.active_storage_accessible_to?(Current.user)

    head :forbidden
  end

  def http_cache_forever(public: false, &)
    super(public: public && @blob.active_storage_publicly_accessible?, &)
  end
end

Rails.application.config.to_prepare do
  ActiveStorage::Blobs::RedirectController.include(ActiveStorage::AuthorizationGuard)
  ActiveStorage::Blobs::ProxyController.include(ActiveStorage::AuthorizationGuard)
  ActiveStorage::Representations::RedirectController.include(ActiveStorage::AuthorizationGuard)
  ActiveStorage::Representations::ProxyController.include(ActiveStorage::AuthorizationGuard)
end
