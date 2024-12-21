class Membership < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  enum :role, { member: "member", admin: "admin" }
  enum :invitation_status, { pending: "pending", active: "active", disabled: "disabled" }

  validates_uniqueness_of :user_id, scope: :organization_id
  validates_uniqueness_of :organization_id, scope: :user_id

  validates :role, :invitation_status, presence: true
  validate :cannot_change_role_if_only_admin, on: :update
  validate :admin_must_have_active_invitation_status

  def try_destroy
    return false if organization.memberships.count == 1
    return false if single_admin_role_persent?

    destroy
  end

  private

  def admin_must_have_active_invitation_status
    return if single_admin_role_persent?
    return if role == "member" && invitation_status.present?

    errors.add(:invitation_status, "Admins must always have an active invitation status.")
  end

  def cannot_change_role_if_only_admin
    return if organization.memberships.where(role: "admin").count > 1

    if role_changed? && role_was == "admin"
      errors.add(:base, "Role cannot be changed because this is the only admin.")
    end
  end

  def single_admin_role_persent?
    role == "admin" && organization.memberships.where(role: "admin").count == 1
  end
end
