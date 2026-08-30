# frozen_string_literal: true

class AccessRequest < ApplicationRecord
  def self.ransackable_attributes(_auth_object = nil)
    %w[id type status created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[organization user completed_by]
  end

  belongs_to :organization
  belongs_to :user
  # rubocop:disable Rails/InverseOf
  belongs_to :completed_by, class_name: "User", optional: true, foreign_key: :completed_by
  # rubocop:enable Rails/InverseOf

  enum :status, %w[pending approved rejected].index_by(&:itself), default: :pending

  validates :status, presence: true
  validates :user_id, uniqueness: { scope: :organization_id, message: :already_has_pending_request }

  def approve!(completed_by: nil)
    transaction do
      update!(status: :approved, completed_by:)
      membership = organization.memberships.find_or_initialize_by(user:)
      membership.deactivated_at = nil
      membership.save!
      after_approve
    end
  end

  def reject!(**)
    after_reject
    destroy!
  end

  private

  def after_approve = nil
  def after_reject = nil
end
