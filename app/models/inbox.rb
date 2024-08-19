class Inbox < ApplicationRecord
  belongs_to :account
  validates :name, presence: true, uniqueness: { scope: :account_id }
end
