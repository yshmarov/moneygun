class AccountUser < ApplicationRecord
  belongs_to :account
  belongs_to :user

  enum :role, { member: "member", admin: "admin" }
end
