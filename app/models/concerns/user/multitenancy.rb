# frozen_string_literal: true

module User::Multitenancy
  extend ActiveSupport::Concern

  included do
    has_many :owned_organizations, class_name: "Organization", foreign_key: :owner_id, inverse_of: :owner, dependent: :restrict_with_error
    has_many :memberships, dependent: :destroy
    has_many :organizations, -> { kept }, through: :memberships

    has_many :sent_join_requests, class_name: "AccessRequest::UserRequestForOrganization", dependent: :destroy
    has_many :sent_invitations, class_name: "Invitation", foreign_key: :invited_by_id, inverse_of: :invited_by, dependent: :nullify

    after_destroy_commit :purge_received_invitations
  end

  def organizations_with_pending_invitations
    Organization.kept.where(id: received_invitations.pending.select(:organization_id))
  end

  def received_invitations
    Invitation.for_email(email)
  end

  def organizations_with_pending_join_requests
    Organization.kept.where(id: sent_join_requests.pending.select(:organization_id))
  end

  private

  def purge_received_invitations
    Invitation.for_email(email).delete_all
  end
end
