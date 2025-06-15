module Organization::Multitenancy
  extend ActiveSupport::Concern

  included do
    has_many :memberships, dependent: :destroy
    has_many :users, through: :memberships
    has_many :user_invitations, class_name: "AccessRequest::InviteToOrganization", dependent: :destroy
    has_many :user_requests, class_name: "AccessRequest::UserRequestForOrganization", dependent: :destroy
  end

  def participant?(user)
    users.include?(user)
  end
end
