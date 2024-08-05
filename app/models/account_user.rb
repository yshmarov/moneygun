class AccountUser < ApplicationRecord
  belongs_to :account
  belongs_to :user

  enum :role, { member: "member", admin: "admin" }

  validates_uniqueness_of :user_id, scope: :account_id
  validates_uniqueness_of :account_id, scope: :user_id

  validates :role, presence: true
end
