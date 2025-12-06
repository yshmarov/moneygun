# frozen_string_literal: true

module User::Authentication
  extend ActiveSupport::Concern

  included do
    # Include default devise modules. Others available are:
    # :lockable, :timeoutable, :trackable
    devise :database_authenticatable,
           :registerable,
           :recoverable,
           :rememberable,
           :validatable,
           :masqueradable,
           :confirmable

    has_many :connected_accounts, as: :owner, dependent: :destroy
  end

  def remember_me
    true
  end

  class_methods do
    def invite!(attributes = {}, invited_by = nil)
      # Create a user with invitation fields set
      # This replaces devise_invitable's User.invite! method
      user = new(attributes)
      # Set a random password (user can reset it via "Forgot password")
      user.password = Devise.friendly_token[0, 20] if user.password.blank?
      user.invitation_created_at = Time.current
      user.invitation_sent_at = Time.current
      user.invitation_token = Devise.friendly_token
      if invited_by
        user.invited_by_type = invited_by.class.name
        user.invited_by_id = invited_by.id
      end
      # Skip confirmation email for invited users (they'll be confirmed when accepting invitation)
      user.skip_confirmation_notification!
      user.save!
      user
    end

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

      # Auto-confirm OAuth users since the provider has already verified their email
      user.confirmed_at = Time.current if user.confirmed_at.blank?

      ConnectedAccount.create_or_update_from_omniauth(auth_payload, user) if user.save

      user
    end
  end
end
