# frozen_string_literal: true

module Organization::Multitenancy
  extend ActiveSupport::Concern

  included do
    has_many :memberships, dependent: :destroy
    has_many :users, through: :memberships
    has_many :invitations, dependent: :destroy
    has_many :audit_logs, dependent: :delete_all
    has_one :sso_connection, dependent: :destroy
    has_one :scim_connection, dependent: :destroy
    has_many :received_join_requests, class_name: "AccessRequest::UserRequestForOrganization", dependent: :destroy

    after_create :create_owner_membership
  end

  def participant?(user)
    if memberships.loaded?
      memberships.any? { |membership| membership.user_id == user.id && membership.active? }
    else
      memberships.active.exists?(user: user)
    end
  end

  def membership_for(user)
    return unless user

    memberships.active.find_by(user: user)
  end

  def pending_invitation_for(user)
    invitations.pending.for_email(user.email).first
  end

  def pending_join_request_for(user)
    received_join_requests.pending.find_by(user: user)
  end

  def admin_users
    User.where(id: memberships.active.where(role: :admin).select(:user_id))
  end

  def membership_status_for(user)
    return :member if participant?(user)

    # In-Ruby filters below must mirror the .pending scope
    if received_join_requests.loaded?
      return :pending_join_request if received_join_requests.select(&:pending?).any? { |r| r.user_id == user.id }
    elsif received_join_requests.pending.exists?(user: user)
      return :pending_join_request
    end

    if invitations.loaded?
      return :invited if invitations.reject(&:expired?).any? { |invitation| invitation.email.casecmp(user.email).zero? }
    elsif invitations.pending.for_email(user.email).exists?
      return :invited
    end

    :none
  end

  private

  def create_owner_membership
    memberships.create!(user: owner, role: Membership.roles[:admin])
  end
end
