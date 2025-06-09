module User::Authentication
  extend ActiveSupport::Concern

  included do
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable
    devise :invitable, :database_authenticatable, :registerable,
           :recoverable, :rememberable, :validatable,
           :masqueradable,
           :omniauthable, omniauth_providers: Devise.omniauth_configs.keys

    has_many :connected_accounts, dependent: :destroy
  end

  def remember_me
    true
  end

  class_methods do
    def from_omniauth(auth_payload)
      email = auth_payload.info&.email
      email ||= auth_payload.uid if auth_payload.provider == "saml"

      user = User.where(email: email).first_or_initialize do |user|
        user.email = email
        user.password = Devise.friendly_token[0, 20] if user.password.blank?
      end

      if user.save
        ConnectedAccount.create_or_update_from_omniauth(auth_payload, user)
      end

      user
    end
  end
end
