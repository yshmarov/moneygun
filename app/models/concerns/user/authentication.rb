# frozen_string_literal: true

module User::Authentication
  extend ActiveSupport::Concern

  BLOCKED_EMAIL_TLDS = %w[.ru .su].freeze

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

    has_many :identities, dependent: :destroy
    belongs_to :invited_by, polymorphic: true, optional: true

    validates :email, nondisposable: true
    validate :reject_blocked_email_tlds
  end

  def remember_me
    true
  end

  private

  def reject_blocked_email_tlds
    return if email.blank?

    domain = email.split("@", 2).last
    return if domain.blank?

    errors.add(:email, :blocked_email) if BLOCKED_EMAIL_TLDS.any? { |tld| domain.downcase.end_with?(tld) }
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
      # Only handle auth providers (Google, Developer)
      # Social providers are handled separately if needed

      # First, check if there's already an identity with this provider and UID
      existing_identity = Identity.find_by(
        provider: auth_payload.provider,
        uid: auth_payload.uid
      )

      if existing_identity
        # Return the user associated with this identity
        return existing_identity.user
      end

      # If no existing identity, proceed with email-based lookup
      email = auth_payload.info&.email
      email ||= auth_payload.uid if auth_payload.provider == "saml"

      user = User.where(email: email).first_or_initialize do |user|
        user.email = email
        user.password = Devise.friendly_token[0, 20] if user.password.blank?
      end

      # Auto-confirm OAuth users since the provider has already verified their email
      user.confirmed_at = Time.current if user.confirmed_at.blank?

      Identity.create_or_update_from_omniauth(auth_payload, user) if user.save

      user
    end
  end
end
