class Inbox < ApplicationRecord
  acts_as_tenant :organization
  validates :name, presence: true, uniqueness: { scope: :organization_id }
end
