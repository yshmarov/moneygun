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
    if memberships.loaded?
      memberships.any? { |m| m.user_id == user.id }
    else
      memberships.exists?(user: user)
    end
  end

  def pending_invitation_for(user)
    sent_invitations.pending.find_by(user: user)
  end

  def pending_join_request_for(user)
    received_join_requests.pending.find_by(user: user)
  end

  def admin_users
    User.where(id: memberships.where(role: :admin).select(:user_id))
  end

  def membership_status_for(user)
    return :member if participant?(user)

    # In-Ruby filters below must mirror the .pending scope
    if received_join_requests.loaded?
      return :pending_join_request if received_join_requests.select(&:pending?).any? { |r| r.user_id == user.id }
    elsif received_join_requests.pending.exists?(user: user)
      return :pending_join_request
    end

    if sent_invitations.loaded?
      return :invited if sent_invitations.select(&:pending?).any? { |r| r.user_id == user.id }
    elsif sent_invitations.pending.exists?(user: user)
      return :invited
    end

    :none
  end

  private

  def create_owner_membership
    memberships.create!(user: owner, role: Membership.roles[:admin])
  end
end
