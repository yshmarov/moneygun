# frozen_string_literal: true

class Invitation < ApplicationRecord
  EXPIRATION = 14.days
  RESEND_COOLDOWN = 2.minutes

  class TransitionError < StandardError; end

  belongs_to :organization
  belongs_to :invited_by, class_name: "User", optional: true

  has_secure_token :token, length: 36

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :expires_at, presence: true
  validates :role, inclusion: { in: Membership.roles.keys }
  validates :token, presence: true
  validate :recipient_not_already_member, on: :create
  validates :email, uniqueness: { scope: :organization_id, conditions: -> { pending }, message: :already_invited }, on: :create

  normalizes :email, with: ->(value) { value.strip.downcase.presence }

  before_validation :purge_expired_duplicates, on: :create
  before_validation :set_expires_at, on: :create
  before_create -> { self.last_sent_at ||= Time.current }

  scope :pending, -> { where("expires_at > ?", Time.current) }
  scope :expired, -> { where(expires_at: ..Time.current) }
  scope :for_email, ->(value) { where("LOWER(email) = ?", value.to_s.downcase) }

  def to_param
    token
  end

  def expired?
    expires_at.past?
  end

  def resendable?
    last_sent_at.nil? || last_sent_at <= RESEND_COOLDOWN.ago
  end

  def deliver
    MembershipMailer.invitation(self).deliver_later
    recipient = User.find_by(email: email)
    Membership::InvitationNotifier.with(organization: organization, invitation: self).deliver_later(recipient) if recipient
  end

  def resend!
    update!(expires_at: EXPIRATION.from_now, last_sent_at: Time.current)
    deliver
  end

  def accept!(actor_user:)
    locked_transition do
      raise TransitionError, "invitation has expired" if expired?
      raise TransitionError, "recipient email does not match invitation" unless email.casecmp(actor_user.email).zero?

      membership = organization.memberships.find_by(user: actor_user)
      raise TransitionError, "recipient is already an active member" if membership&.active?

      destroy!
      if membership
        membership.update!(role: role, deactivated_at: nil, provisioned_via: "invitation")
      else
        membership = organization.memberships.create!(user: actor_user, role: role, provisioned_via: "invitation")
      end
      actor_user.complete_onboarding! if actor_user.terms_accepted? && actor_user.onboarding_pending?
      log_event("invitation.accepted", actor: membership, actor_user: actor_user)
    end
    notify_inviter(Membership::InvitationAcceptedNotifier)
    actor_user
  end

  def decline!(actor_user:)
    locked_transition do
      raise TransitionError, "invitation has expired" if expired?
      raise TransitionError, "recipient email does not match invitation" unless email.casecmp(actor_user.email).zero?

      log_event("invitation.declined", actor_user: actor_user)
      destroy!
    end
    notify_inviter(Membership::InvitationDeclinedNotifier)
  end

  def revoke!(actor: Current.membership)
    locked_transition do
      raise TransitionError, "invitation has expired" if expired?

      log_event("invitation.revoked", actor: actor)
      destroy!
    end
  end

  def log_created!(actor: Current.membership)
    log_event("invitation.created", actor: actor)
  end

  private

  def set_expires_at
    self.expires_at = EXPIRATION.from_now
  end

  def locked_transition(&)
    raise TransitionError, "invitation no longer exists" if destroyed?

    with_lock(&)
  rescue ActiveRecord::RecordNotFound
    raise TransitionError, "invitation no longer exists"
  end

  def purge_expired_duplicates
    return if email.blank? || organization.blank?

    organization.invitations.expired.where(email: email).delete_all
  end

  def recipient_not_already_member
    return if email.blank? || organization.blank?
    return unless organization.memberships.active.joins(:user).exists?(users: { email: email })

    errors.add(:email, :already_member)
  end

  def notify_inviter(notifier)
    return unless invited_by && organization.participant?(invited_by)

    notifier.with(organization: organization, organization_name: organization.name, email: email).deliver(invited_by)
  end

  def log_event(action, actor: nil, actor_user: nil)
    AuditLog.log!(
      organization: organization,
      mini_app: "organization",
      actor: actor,
      subject: self,
      action: action,
      actor_kind: actor.is_a?(Membership) ? "member" : "system",
      metadata: {
        email: email,
        role: role,
        invited_by_user_id: invited_by_id,
        actor_user_id: actor_user&.id || actor&.user_id,
        expires_at: expires_at&.iso8601
      }.compact
    )
  end
end
