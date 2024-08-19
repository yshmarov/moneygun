class AccountPolicy < ApplicationPolicy
  def show?
    record.users.include?(user)
  end

  def edit?
    account_user = record.account_users.find_by(user: user)
    account_user&.admin?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
