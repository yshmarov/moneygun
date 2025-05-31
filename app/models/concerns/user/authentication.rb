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
    def from_google_onetap(onetap_payload)
      user = find_or_initialize_by_email(onetap_payload["email"])
      user.save

      if user.persisted?
        auth_hash = adapt_onetap_payload_to_auth_hash(onetap_payload, "google_oauth2")
        ConnectedAccount.create_or_update_from_omniauth(auth_hash, user)
      end

      user
    end

    def from_omniauth(auth_payload)
      email = auth_payload.info&.email
      email ||= auth_payload.uid if auth_payload.provider == "saml"

      unless email
        Rails.logger.error "OmniAuth: Email not found in payload for provider #{auth_payload.provider}"
        return nil
      end

      user = find_or_initialize_by_email(email)
      user.save

      if user.persisted?
        ConnectedAccount.create_or_update_from_omniauth(auth_payload, user)
      end

      user
    end

    private

    def find_or_initialize_by_email(email)
      User.where(email: email).first_or_initialize do |user|
        user.email = email
        user.password = Devise.friendly_token[0, 20] if user.password.blank?
      end
    end

    def adapt_onetap_payload_to_auth_hash(onetap_payload, provider_name)
      OmniAuth::AuthHash.new({
        provider: provider_name,
        uid: onetap_payload["sub"], # 'sub' is typically the user ID in Google's token
        info: {
          email: onetap_payload["email"],
          name: onetap_payload["name"],
          image: onetap_payload["picture"]
        },
        credentials: {}
        # OneTap doesn't directly provide access/refresh tokens in the same way as a full OAuth2 flow.
        # If you have separate mechanisms to get these for OneTap, they could be added here.
        # For now, credentials will be empty.
      })
    end
  end
end
