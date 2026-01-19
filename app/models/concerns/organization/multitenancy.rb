# frozen_string_literal: true

module Organization::Multitenancy
  extend ActiveSupport::Concern

  included do
    has_many :memberships, dependent: :destroy
    has_many :users, through: :memberships
    has_many :sent_invitations, class_name: "AccessRequest::InviteToOrganization", dependent: :destroy
    has_many :received_join_requests, class_name: "AccessRequest::UserRequestForOrganization", dependent: :destroy

    after_create :create_owner_membership
  end

  def participant?(user)
    memberships.exists?(user: user)
  end

  def pending_invitation_for(user)
    sent_invitations.pending.find_by(user: user)
  end

  def pending_join_request_for(user)
    received_join_requests.pending.find_by(user: user)
  end

  def membership_status_for(user)
    return :member if participant?(user)
    return :pending_join_request if received_join_requests.pending.exists?(user: user)
    return :invited if sent_invitations.pending.exists?(user: user)

    :none
  end

  private

  def create_owner_membership
    memberships.create!(user: owner, role: Membership.roles[:admin])
  end
end
