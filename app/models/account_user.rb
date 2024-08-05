class AccountUser < ApplicationRecord
  belongs_to :account
  belongs_to :user

  enum :role, { member: "member", admin: "admin" }

  validates_uniqueness_of :user_id, scope: :account_id
  validates_uniqueness_of :account_id, scope: :user_id

  validates :role, presence: true

  def try_destroy
    return false if account.account_users.count == 1
    return false if role == "admin" && account.account_users.where(role: "admin").count == 1

    destroy
  end
end
