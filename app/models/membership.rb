# frozen_string_literal: true

class Membership < ApplicationRecord
  belongs_to :organization
  belongs_to :user, optional: true # Allow nil for archived memberships

  enum :role, %w[member admin].index_by(&:itself)

  scope :accessible, -> { where(suspended_at: nil).where.not(user_id: nil) }

  validates :user_id, uniqueness: { scope: :organization_id }, allow_nil: true
  validates :organization_id, uniqueness: { scope: :user_id }, allow_nil: true
  validates :role, presence: true

  validate :cannot_change_role_if_only_admin, on: :update
  validate :cannot_demote_owner_from_admin, on: :update
  validate :cannot_suspend_owner, on: :update
  validate :cannot_suspend_only_admin, on: :update

  after_destroy :notify_user_removed

  def try_destroy
    return false if organization.memberships.accessible.one?
    return false if admin? && organization.memberships.accessible.where(role: "admin").one?
    return false if user_id == organization.owner_id

    destroy
  end

  def archive!
    update!(user_id: nil, suspended_at: Time.current)
  end

  def suspend!
    update!(suspended_at: Time.current)
  end

  def activate!
    update!(suspended_at: nil)
  end

  def suspended?
    suspended_at.present?
  end

  def active?
    suspended_at.nil?
  end

  def accessible?
    active? && user_id.present?
  end

  private

  def notify_user_removed
    return if user.blank?

    Membership::RemovalNotifier.with(
      organization: organization,
      organization_name: organization.name
    ).deliver(user)
  end

  def cannot_change_role_if_only_admin
    return if organization.memberships.accessible.where(role: "admin").many?

    return unless role_changed? && role_was == "admin"

    errors.add(:base, I18n.t("errors.models.membership.attributes.base.cannot_change_role_if_only_admin"))
  end

  def cannot_demote_owner_from_admin
    return unless role_changed? && role_was == "admin" && user_id == organization.owner_id

    errors.add(:base, I18n.t("errors.models.membership.attributes.base.cannot_demote_owner_from_admin"))
  end

  def cannot_suspend_owner
    return unless suspended_at_changed? && suspended_at.present? && user_id == organization.owner_id

    errors.add(:base, I18n.t("errors.models.membership.attributes.base.cannot_suspend_owner"))
  end

  def cannot_suspend_only_admin
    return unless suspended_at_changed? && suspended_at.present? && admin?
    return if organization.memberships.accessible.where(role: "admin").where.not(id: id).exists?

    errors.add(:base, I18n.t("errors.models.membership.attributes.base.cannot_suspend_only_admin"))
  end
end
