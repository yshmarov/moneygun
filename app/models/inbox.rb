class Inbox < ApplicationRecord
  acts_as_tenant :account
  validates :name, presence: true, uniqueness: { scope: :account_id }
end
