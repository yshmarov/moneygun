class MembershipPolicy < ApplicationPolicy
  def index?
    true
  end

  def new?
    create?
  end

  def create?
    membership&.admin?
  end

  def edit?
    update?
  end

  def update?
    membership&.admin?
  end

  def destroy?
    membership&.admin? || record.user == user
  end

  private

  def membership
    record.organization.memberships.find_by(user:)
  end
end
