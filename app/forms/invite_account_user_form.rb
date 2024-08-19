class InviteAccountUserForm
  include ActiveModel::Model

  attr_accessor :email, :account, :inviter, :role

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true

  def save
    return false unless valid?

    user = find_or_invite_user
    return false unless user&.valid?

    add_user_to_account(user)
  end

  private

  def find_or_invite_user
    User.find_by(email: email) || User.invite!({ email: }, inviter)
  end

  def add_user_to_account(user)
    account_user = user.account_users.find_by(account:)
    if account_user.present?
      errors.add(:base, "#{email} is already a member of this account.")
      false
    else
      user.account_users.create(account:, role:)
      true
    end
  end
end
