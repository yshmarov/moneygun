class ConnectedAccount < ApplicationRecord
  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }

  PROVIDER_CONFIG = {
    google_oauth2: {
      name: "Google",
      icon: :google
    },
    github: {
      name: "GitHub",
      icon: :github
    },
    telegram: {
      name: "Telegram",
      icon: :telegram
    }
  }.freeze

  def name
    payload&.dig("info", "name")
  end

  def image_url
    payload&.dig("info", "image")
  end

  def nickname
    payload&.dig("info", "nickname")
  end

  def self.create_or_update_from_omniauth(auth_payload, user)
    # Check if this OAuth account is already connected to a different user
    existing_account = ConnectedAccount.find_by(
      provider: auth_payload.provider,
      uid: auth_payload.uid
    )

    if existing_account && existing_account.user != user
      # OAuth account is already connected to a different user
      new_account = ConnectedAccount.new(
        provider: auth_payload.provider,
        uid: auth_payload.uid,
        user: user
      )
      new_account.errors.add(:base, "This #{auth_payload.provider.humanize} account is already connected to another user")
      return new_account
    end

    connected_account = user.connected_accounts.find_or_initialize_by(
      provider: auth_payload.provider,
      uid: auth_payload.uid
    )

    connected_account.payload = auth_payload.to_h

    credentials = auth_payload.credentials
    if credentials.present?
      connected_account.access_token = credentials.token
      connected_account.refresh_token = credentials.refresh_token
      connected_account.expires_at = Time.at(credentials.expires_at) if credentials.expires_at.present?
    end

    connected_account.save
    connected_account
  end
end
