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

    add_user_to_organization(user)
  end

  private

  def find_or_invite_user
    User.find_by(email: email) || User.invite!({ email: }, inviter)
  end

  def add_user_to_organization(user)
    membership = user.memberships.find_by(organization: organization)
    if membership.present?
      errors.add(:base, "#{email} is already a member of this organization.")
      false
    else
      user.memberships.create(organization: organization, role: role)
      true
    end
  end
end
