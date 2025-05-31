module User::Authentication
  extend ActiveSupport::Concern

  included do
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :invitable, :database_authenticatable, :registerable,
           :recoverable, :rememberable, :validatable,
           :omniauthable, omniauth_providers: Devise.omniauth_configs.keys

    has_many :connected_accounts, dependent: :destroy
  end

  class_methods do
    def from_google_onetap(payload)
      user = User.where(email: payload["email"]).first_or_initialize do |user|
        user.email = payload["email"]
        user.password = Devise.friendly_token[0, 20] if user.password.blank?
      end

      user.save
      user
    end

    def from_omniauth(auth_payload)
      data = auth_payload.info
      user = User.where(email: data["email"]).first_or_initialize do |user|
        user.email = data["email"]
        user.password = Devise.friendly_token[0, 20] if user.password.blank?
      end

      user.save

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

      user
    end
  end
end
