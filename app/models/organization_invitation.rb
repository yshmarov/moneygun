# frozen_string_literal: true

class OrganizationInvitation < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  enum :status, %w[pending approved rejected].index_by(&:itself), default: :pending

  validates :status, presence: true
  validates :user_id, uniqueness: { scope: :organization_id, message: :already_has_pending_request }

  after_create_commit { Membership::InvitationNotifier.with(organization:).deliver(user) }

  def approve!
    transaction do
      update!(status: :approved)
      organization.memberships.find_or_create_by!(user:)
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    raise ActiveRecord::Rollback, e.message
  end

  def reject!
    destroy!
  end
end
