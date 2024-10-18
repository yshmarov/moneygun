class AccountUser < ApplicationRecord
  belongs_to :account
  belongs_to :user

  enum :role, { member: "member", admin: "admin" }

  validates_uniqueness_of :user_id, scope: :account_id
  validates_uniqueness_of :account_id, scope: :user_id

  validates :role, presence: true
  validate :cannot_change_role_if_only_admin, on: :update

  def try_destroy
    return false if account.account_users.count == 1
    return false if role == "admin" && account.account_users.where(role: "admin").count == 1

    destroy
  end

  private

  def cannot_change_role_if_only_admin
    return if account.account_users.where(role: "admin").count > 1

    if role_changed? && role_was == "admin"
      errors.add(:base, "Role cannot be changed because this is the only admin.")
    end
  end
end
