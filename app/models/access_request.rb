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

  def approve!(completed_by: nil)
    transaction do
      update!(status: :approved, completed_by:)
      organization.memberships.find_or_create_by!(user:)
      after_approve
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    raise ActiveRecord::Rollback, e.message
  end

  def reject!(completed_by: nil)
    after_reject
    destroy!
  end

  private

  def after_approve = nil
  def after_reject = nil
end
