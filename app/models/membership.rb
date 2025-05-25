class Membership < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  enum :role, { member: "member", admin: "admin" }

  validates :user_id, uniqueness: { scope: :organization_id }
  validates :organization_id, uniqueness: { scope: :user_id }

  validates :role, presence: true
  validate :cannot_change_role_if_only_admin, on: :update
  validate :cannot_demote_owner_from_admin, on: :update

  def try_destroy
    return false if organization.memberships.count == 1
    return false if role == "admin" && organization.memberships.where(role: "admin").count == 1
    return false if user_id == organization.owner_id

    destroy
  end

  private

  def cannot_change_role_if_only_admin
    return if organization.memberships.where(role: "admin").count > 1

    return unless role_changed? && role_was == "admin"

    errors.add(:base, "Role cannot be changed because this is the only admin.")
  end

  def cannot_demote_owner_from_admin
    return unless role_changed? && role_was == "admin" && user_id == organization.owner_id

    errors.add(:base, "Organization owner cannot be demoted from admin role.")
  end
end
