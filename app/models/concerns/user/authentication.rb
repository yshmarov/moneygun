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

      # user.name = payload["name"]
      # user.image = payload["picture"]
      # user.provider = "google_oauth2"
      # user.uid = payload["sub"]
      user.save
      user
    end

    def from_omniauth(auth_payload)
      data = auth_payload.info
      user = User.where(email: data["email"]).first_or_initialize do |user|
        user.email = data["email"]
        user.password = Devise.friendly_token[0, 20] if user.password.blank?
      end

      # user.name = auth_payload.info.name
      # user.image = auth_payload.info.image
      # user.provider = auth_payload.provider
      # user.uid = auth_payload.uid
      user.save
      user
    end
  end
end
