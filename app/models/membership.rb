# frozen_string_literal: true

class Membership < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  enum :role, %w[member admin].index_by(&:itself)

  validates :user_id, uniqueness: { scope: :organization_id }
  validates :organization_id, uniqueness: { scope: :user_id }

  validates :role, presence: true
  validate :cannot_change_role_if_only_admin, on: :update
  validate :cannot_demote_owner_from_admin, on: :update

  after_destroy :notify_user_removed

  def try_destroy
    return false if organization.memberships.one?
    return false if admin? && organization.memberships.where(role: "admin").one?
    return false if user_id == organization.owner_id

    destroy
  end

  private

  def notify_user_removed
    Membership::RemovalNotifier.with(
      organization: organization,
      organization_name: organization.name
    ).deliver(user)
  end

  def cannot_change_role_if_only_admin
    return if organization.memberships.where(role: "admin").many?

    return unless role_changed? && role_was == "admin"

    errors.add(:base, I18n.t("errors.models.membership.attributes.base.cannot_change_role_if_only_admin"))
  end

  def cannot_demote_owner_from_admin
    return unless role_changed? && role_was == "admin" && user_id == organization.owner_id

    errors.add(:base, I18n.t("errors.models.membership.attributes.base.cannot_demote_owner_from_admin"))
  end
end
