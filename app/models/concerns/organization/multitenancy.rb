# frozen_string_literal: true

module Organization::Multitenancy
  extend ActiveSupport::Concern

  included do
    has_many :memberships, dependent: :destroy
    has_many :users, through: :memberships
    has_many :user_invitations, class_name: "AccessRequest::InviteToOrganization", dependent: :destroy
    has_many :user_requests, class_name: "AccessRequest::UserRequestForOrganization", dependent: :destroy

    after_create :create_owner_membership
  end

  def participant?(user)
    users.include?(user)
  end

  def create_owner_membership
    memberships.create!(user: owner, role: Membership.roles[:admin])
  end
end
