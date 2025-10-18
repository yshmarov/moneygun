class ConnectedAccount < ApplicationRecord
  belongs_to :owner, polymorphic: true

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }

  encrypts :access_token, :refresh_token if Rails.application.credentials.active_record_encryption.present?

  PROVIDER_CONFIG = {
    google_oauth2: {
      name: 'Google',
      icon: :google,
      sign_in: true
    },
    youtube: {
      name: 'YouTube',
      icon: :youtube,
      sign_in: false
    },
    github: {
      name: 'GitHub',
      icon: :github,
      sign_in: true
    },
    telegram: {
      name: 'Telegram',
      icon: :telegram,
      sign_in: false
    },
    tiktok: {
      name: 'TikTok',
      icon: :tiktok,
      sign_in: false
    },
    developer: {
      name: 'Developer',
      icon: 'rocket-launch',
      sign_in: true
    }
  }.freeze

  def name
    payload&.dig('info', 'name')
  end

  def email
    payload&.dig('info', 'email') unless provider == 'youtube'
  end

  def image_url
    payload&.dig('info', 'image')
  end

  def nickname
    payload&.dig('info', 'nickname')
  end

  def platform_url
    case provider
    when 'google_oauth2', 'tiktok'
      payload&.dig('extra', 'raw_info', 'profile_deep_link')
    when 'github'
      payload&.dig('extra', 'raw_info', 'html_url')
    end
  end

  def self.create_or_update_from_omniauth(auth_payload, owner)
    connected_account = owner.connected_accounts.find_or_initialize_by(
      provider: auth_payload.provider,
      uid: auth_payload.uid
    )

    connected_account.payload = auth_payload.to_h

    credentials = auth_payload.credentials
    if credentials.present?
      connected_account.access_token = credentials.token
      connected_account.refresh_token = credentials.refresh_token
      connected_account.expires_at = Time.zone.at(credentials.expires_at) if credentials.expires_at.present?
    end

    connected_account.save
    connected_account
  end
end
