# frozen_string_literal: true

class AccessRequest < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  # rubocop:disable Rails/InverseOf
  belongs_to :completed_by, class_name: "User", optional: true, foreign_key: :completed_by
  # rubocop:enable Rails/InverseOf

  enum :status, %w[pending approved rejected].index_by(&:itself), default: :pending

  validates :status, presence: true
  validates :user_id, uniqueness: { scope: :organization_id, message: :already_has_pending_request }

  def approve!
    raise NotImplementedError, "Subclasses must implement this method"
  end

  def reject!
    raise NotImplementedError, "Subclasses must implement this method"
  end
end
