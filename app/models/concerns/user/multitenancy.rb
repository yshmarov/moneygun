module User::Multitenancy
  extend ActiveSupport::Concern

  included do
    has_many :memberships, dependent: :destroy
    has_many :organizations, through: :memberships
    has_many :owned_organizations, class_name: "Organization", foreign_key: :owner_id, inverse_of: :owner, dependent: :destroy

    has_many :organization_invitations, class_name: "AccessRequest::InviteToOrganization", dependent: :destroy
    has_many :organization_requests, class_name: "AccessRequest::UserRequestForOrganization", dependent: :destroy
  end
end
