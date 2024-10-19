class Inbox < ApplicationRecord
  # belongs_to :account
  acts_as_tenant :account
  validates :name, presence: true, uniqueness: { scope: :account_id }
end
