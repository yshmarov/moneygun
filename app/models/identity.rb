# frozen_string_literal: true

class Identity < ApplicationRecord
  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }

  encrypts :access_token, :refresh_token if Rails.application.credentials.active_record_encryption.present?

  # Auth-only providers (used for signing in to the application)
  AUTH_PROVIDERS = {
    google_oauth2: {
      name: "Google",
      icon: :google
    },
    developer: {
      name: "Developer",
      icon: "rocket-launch"
    }
  }.freeze

  # Providers that support OAuth2 token refresh
  REFRESHABLE_PROVIDERS = %w[google_oauth2].freeze

  def name
    payload&.dig("info", "name")
  end

  def email
    payload&.dig("info", "email")
  end

  def image_url
    payload&.dig("info", "image")
  end

  def platform_url
    nil
  end

  def self.create_or_update_from_omniauth(auth_payload, user)
    identity = user.identities.find_or_initialize_by(
      provider: auth_payload.provider,
      uid: auth_payload.uid
    )

    identity.payload = auth_payload.to_h

    credentials = auth_payload.credentials
    if credentials.present?
      identity.access_token = credentials.token
      identity.refresh_token = credentials.refresh_token
      identity.expires_at = Time.zone.at(credentials.expires_at) if credentials.expires_at.present?
      identity.refresh_token_invalidated_at = nil
    end

    identity.save
    identity
  end

  def self.auth_provider?(provider)
    AUTH_PROVIDERS.key?(provider.to_sym)
  end
end
