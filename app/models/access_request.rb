class AccessRequest < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  belongs_to :completed_by, class_name: "User", optional: true, foreign_key: :completed_by

  enum :status, %w[ pending approved rejected ].index_by(&:itself), default: :pending

  validates :status, presence: true
  validates :user_id, uniqueness: { scope: :organization_id, message: "already has a pending request" }

  def approve!
    fail NotImplementedError, "Subclasses must implement this method"
  end

  def reject!
    fail NotImplementedError, "Subclasses must implement this method"
  end
end
