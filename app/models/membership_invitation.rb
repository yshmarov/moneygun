class MembershipInvitation
  include ActiveModel::Model

  attr_accessor :email, :organization, :inviter, :role

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true
  validates :role, inclusion: { in: Membership.roles.keys }

  def save
    return false unless valid?

    user = find_or_invite_user
    return false unless user&.valid?

    create_access_request(user)
  end

  private

  def find_or_invite_user
    User.find_by(email: email) || User.invite!({ email: }, inviter)
  end

  def create_access_request(user)
    membership = user.memberships.find_by(organization: organization)
    if membership.present?
      errors.add(:base, "#{email} is already a member of this organization.")
      false
    else
      organization.user_invitations.create(user:, organization_role: role)
      true
    end
  end
end
