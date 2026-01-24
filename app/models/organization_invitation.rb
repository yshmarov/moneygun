# frozen_string_literal: true

class OrganizationInvitation < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  belongs_to :completed_by, class_name: "User", optional: true

  enum :status, %w[pending approved rejected].index_by(&:itself), default: :pending

  validates :status, presence: true
  validates :user_id, uniqueness: { scope: :organization_id, message: :already_has_pending_request }
  validate :user_not_already_member, on: :create

  after_create_commit { Membership::InvitationNotifier.with(organization:).deliver(user) }

  def approve!(completed_by: nil)
    return add_not_pending_error unless pending?

    transaction do
      update!(status: :approved, completed_by:)
      organization.memberships.find_or_create_by!(user:)
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    errors.add(:base, e.message)
    false
  end

  def reject!(completed_by: nil)
    return add_not_pending_error unless pending?

    transaction do
      update!(status: :rejected, completed_by:)
      destroy!
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  end

  private

  def user_not_already_member
    return unless organization&.participant?(user)

    errors.add(:user, :already_member)
  end

  def add_not_pending_error
    errors.add(:base, :not_pending)
    false
  end
end
