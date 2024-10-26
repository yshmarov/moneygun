class InboxPolicy < ApplicationPolicy
  def index?
    new?
  end

  def show?
    new?
  end

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
    new?
  end

  private

  def account_user
    account.account_users.find_by(user:)
  end

  def account
    record.is_a?(Account) ? record : record.account
  end
end
