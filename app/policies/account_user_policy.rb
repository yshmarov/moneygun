class AccountUserPolicy < ApplicationPolicy
  def new?
    account_user&.admin?
  end

  def create?
    new?
  end

  def edit?
    new?
  end

  def update?
    new?
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
