module User::Authentication
  extend ActiveSupport::Concern

  included do
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable
    devise :invitable, :database_authenticatable, :registerable,
           :recoverable, :rememberable, :validatable,
           :omniauthable, omniauth_providers: Devise.omniauth_configs.keys

    has_many :connected_accounts, dependent: :destroy
  end

  class_methods do
    def from_omniauth(auth_payload)
      email = auth_payload.info&.email
      email ||= auth_payload.uid if auth_payload.provider == "saml"

      unless email
        Rails.logger.error "OmniAuth: Email not found in payload for provider #{auth_payload.provider}"
        return nil
      end

      user = User.where(email: email).first_or_initialize do |user|
        user.email = email
        user.password = Devise.friendly_token[0, 20] if user.password.blank?
      end

      user.save

      if user.persisted?
        ConnectedAccount.create_or_update_from_omniauth(auth_payload, user)
      end

      user
    end
  end
end
