# frozen_string_literal: true

module User::Authentication
  extend ActiveSupport::Concern

  included do
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable
    devise :invitable, :database_authenticatable, :registerable,
      :recoverable, :rememberable, :validatable,
      :masqueradable,
      :omniauthable, omniauth_providers: Devise.omniauth_configs.keys

    has_many :connected_accounts, as: :owner, dependent: :destroy
  end

  def remember_me
    true
  end

  class_methods do
    def from_omniauth(auth_payload)
      # First, check if there's already a connected account with this provider and UID
      existing_connected_account = ConnectedAccount.find_by(
        provider: auth_payload.provider,
        uid: auth_payload.uid
      )

      if existing_connected_account
        # Return the owner associated with this connected account
        return existing_connected_account.owner
      end

      # If no existing connected account, proceed with email-based lookup
      email = auth_payload.info&.email
      email ||= auth_payload.uid if auth_payload.provider == "saml"

      user = User.where(email: email).first_or_initialize do |user|
        user.email = email
        user.password = Devise.friendly_token[0, 20] if user.password.blank?
      end

      ConnectedAccount.create_or_update_from_omniauth(auth_payload, user) if user.save

      user
    end
  end
end
