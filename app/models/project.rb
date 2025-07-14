class Project < ApplicationRecord
  belongs_to :organization
  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :name, length: { minimum: 3, maximum: 10 }
end
