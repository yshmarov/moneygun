# frozen_string_literal: true

class User < ApplicationRecord
  include User::Authentication
  include User::Banning
  include User::MarketingConsent
  include User::Multitenancy
  include User::Onboarding
  include User::Redaction
  include User::TwoFactor

  MAX_AVATAR_SIZE = 3.megabytes.freeze

  generates_token_for(:api, expires_in: 30.days) { email }

  has_referrals
  has_many :notifications, as: :recipient, class_name: "Noticed::Notification", dependent: :destroy

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fit: [256, 256], saver: { strip: true, quality: 80 }, format: :webp
  end

  before_destroy :ensure_no_audit_footprint, prepend: true
  after_save { @preprocess_avatar = attachment_changes["avatar"].present? }
  after_commit :preprocess_avatar, on: %i[create update]
  after_update_commit :log_name_changed, if: :saved_change_to_name?

  validates :name, length: { maximum: 100 }, allow_blank: true
  validates :avatar, content_type: IMAGE_CONTENT_TYPES
  validates :avatar, size: { less_than: MAX_AVATAR_SIZE, message: "must be less than #{MAX_AVATAR_SIZE / 1.megabyte}MB" }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id email]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def unseen_notifications_count
    @unseen_notifications_count ||= notifications.unseen.count
  end

  def name
    self[:name].presence || (redacted? ? I18n.t("users.closed_account_name") : email.split("@").first)
  end

  def display_email
    email unless redacted?
  end

  def avatar_thumbnail
    avatar.variable? ? avatar.variant(:thumb) : avatar
  end

  def active_storage_publicly_accessible?
    true
  end

  def audit_footprint?
    AuditLog.exists?(actor: memberships)
  end

  def retained_footprint?
    audit_footprint? || memberships.joins(:projects).exists?
  end

  def undeletable_reasons
    reasons = []
    reasons << :owns_organizations if owned_organizations.exists?

    memberships.active.includes(:organization).each_with_object(reasons) do |membership, result|
      membership.undeactivatable_reasons.each do |reason|
        result << [reason, { organizations: membership.organization.name }]
      end
    end
  end

  private

  def preprocess_avatar
    ActiveStorage::PreprocessVariantsJob.perform_later(self, "avatar") if @preprocess_avatar && avatar.attached?
  ensure
    @preprocess_avatar = false
  end

  def ensure_no_audit_footprint
    return unless audit_footprint?

    errors.add(:base, :has_audit_footprint)
    throw(:abort)
  end

  def log_name_changed
    AuditLog.log_for_memberships!(
      memberships,
      action: "user.name_changed",
      actor_kind: Current.scim_connection ? "scim" : Current.actor_kind.presence || "member",
      metadata: { changes: { name: saved_change_to_name }, scim_connection_id: Current.scim_connection&.id }.compact
    )
  end
end
