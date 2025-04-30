class User < ApplicationRecord
  include User::Authentication
  include User::Multitenancy

  has_many :organization_invitations, class_name: "AccessRequest::InviteToOrganization", dependent: :destroy
  has_many :organization_requests, class_name: "AccessRequest::UserRequestForOrganization", dependent: :destroy
end
