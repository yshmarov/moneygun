class Inbox < ApplicationRecord
  belongs_to :organization
  validates :name, presence: true, uniqueness: { scope: :organization_id }
end
