# frozen_string_literal: true

module User::Multitenancy
  extend ActiveSupport::Concern

  included do
    has_many :memberships, dependent: :destroy
    has_many :organizations, through: :memberships
    has_many :owned_organizations, class_name: "Organization", foreign_key: :owner_id, inverse_of: :owner, dependent: :destroy

    has_many :received_invitations, class_name: "AccessRequest::InviteToOrganization", dependent: :destroy
    has_many :sent_join_requests, class_name: "AccessRequest::UserRequestForOrganization", dependent: :destroy

    after_create_commit :create_default_organization
  end

  def organizations_with_pending_invitations
    Organization.where(id: received_invitations.pending.select(:organization_id))
  end

  def organizations_with_pending_join_requests
    Organization.where(id: sent_join_requests.pending.select(:organization_id))
  end

  private

  def create_default_organization
    return if invitation_created_at.present?

    organization_name = email.split("@").first
    organization = Organization.create!(name: organization_name, owner: self)
    organization.memberships.first.update(role: Membership.roles[:admin])
  end
end
