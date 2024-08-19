class AccountUserPolicy < ApplicationPolicy
  def edit?
    account_user&.admin?
  end

  def update?
    edit?
  end

  def destroy?
    account_user&.admin? || record.user == user
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  private

  def account_user
    record.account.account_users.find_by(user: user)
  end
end
