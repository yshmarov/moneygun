class AccountPolicy < ApplicationPolicy
  def show?
    record.users.include?(user)
  end

  def edit?
    account_user = record.account_users.find_by(user:)
    account_user&.admin?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end
end
