# frozen_string_literal: true

class Membership < ApplicationRecord
  include Membership::ScimProvisionable

  DEACTIVATION_ERRORS = {
    owner: "cannot_deactivate_owner",
    sole_admin: "cannot_deactivate_only_active_admin"
  }.freeze

  belongs_to :organization
  belongs_to :user

  has_many :projects, dependent: :restrict_with_error
  has_many :data_exports, dependent: :destroy

  enum :role, %w[member admin viewer].index_by(&:itself)

  scope :active, -> { where(deactivated_at: nil) }
  scope :deactivated, -> { where.not(deactivated_at: nil) }

  validates :user_id, uniqueness: { scope: :organization_id }
  validates :role, presence: true
  validates :provisioned_via, inclusion: { in: %w[manual invitation sso scim] }
  validate :cannot_change_role_if_only_admin, on: :update
  validate :cannot_demote_owner_from_admin, on: :update
  validate :deactivation_must_be_permitted, if: :deactivating?
  validate :cannot_reactivate_redacted_user, if: :reactivating?

  after_create_commit :log_added
  before_destroy :prevent_owner_destroy, unless: :organization_being_destroyed?
  before_destroy :log_removed, unless: :organization_being_destroyed?
  before_destroy :nullify_audit_log_actor
  after_update_commit :notify_role_changed, if: :saved_change_to_role?
  after_update_commit :log_role_changed, if: :saved_change_to_role?
  after_update_commit :log_deactivation_changed, if: :saved_change_to_deactivated_at?
  after_update_commit :notify_deactivation_changed, if: :saved_change_to_deactivated_at?

  def deactivate
    update(deactivated_at: Time.current)
  end
  alias try_destroy deactivate

  def reactivate
    update(deactivated_at: nil)
  end

  def active?
    deactivated_at.nil?
  end

  def deactivated?
    deactivated_at.present?
  end

  def display_name
    self[:display_name].presence || user&.name
  end

  def owner?
    user_id == organization.owner_id
  end

  def undeactivatable_reasons
    return [:owner] if owner?

    sole_active_admin? ? [:sole_admin] : []
  end

  private

  def log_event(action, metadata = {})
    AuditLog.log!(
      organization: organization,
      mini_app: "organization",
      actor: Current.membership,
      action: action,
      actor_kind: Current.audit_actor_kind,
      metadata: metadata.merge(
        target_user_id: user_id,
        target_user_email: user.email,
        role: role,
        scim_connection_id: Current.scim_connection&.id,
        sso_connection_id: Current.sso_connection&.id
      ).compact
    )
  end

  def log_added
    log_event("membership.added")
  end

  def log_role_changed
    log_event("membership.role_changed", changes: { role: [role_before_last_save, role] })
  end

  def log_removed
    log_event("membership.removed", removed_user_id: user_id, removed_user_email: user.email)
  end

  def log_deactivation_changed
    log_event(deactivated? ? "membership.deactivated" : "membership.reactivated")
  end

  def notify_role_changed
    Membership::RoleChangedNotifier.with(
      organization: organization,
      organization_name: organization.name,
      role: role
    ).deliver(user)
  end

  def notify_deactivation_changed
    return if deactivated? && Current.user&.id == user_id

    notifier = deactivated? ? Membership::RemovalNotifier : Membership::ReactivationNotifier
    notifier.with(
      organization: organization,
      organization_name: organization.name
    ).deliver(user)
  end

  def cannot_change_role_if_only_admin
    return unless role_changed? && role_was == "admin"
    return unless sole_active_admin?

    errors.add(:base, I18n.t("errors.models.membership.attributes.base.cannot_change_role_if_only_admin"))
  end

  def cannot_demote_owner_from_admin
    return unless role_changed? && role_was == "admin" && owner?

    errors.add(:base, I18n.t("errors.models.membership.attributes.base.cannot_demote_owner_from_admin"))
  end

  def deactivating?
    deactivated_at_changed? && deactivated_at.present?
  end

  def reactivating?
    deactivated_at_changed? && deactivated_at.nil?
  end

  def deactivation_must_be_permitted
    undeactivatable_reasons.each do |reason|
      errors.add(:base, I18n.t("errors.models.membership.attributes.base.#{DEACTIVATION_ERRORS.fetch(reason)}"))
    end
  end

  def cannot_reactivate_redacted_user
    errors.add(:base, I18n.t("errors.models.membership.attributes.base.cannot_reactivate_redacted_user")) if user.redacted?
  end

  def sole_active_admin?
    (admin? || role_was == "admin") && !organization.memberships.active.where(role: "admin").where.not(id: id).exists?
  end

  def prevent_owner_destroy
    return unless owner?

    errors.add(:base, I18n.t("errors.models.membership.attributes.base.cannot_remove_owner"))
    throw(:abort)
  end

  def organization_being_destroyed?
    destroyed_by_association.present? || organization.destroyed? || organization.marked_for_destruction?
  end

  def nullify_audit_log_actor
    AuditLog.where(actor: self).update_all(actor_type: nil, actor_id: nil) # rubocop:disable Rails/SkipsModelValidations
  end
end
