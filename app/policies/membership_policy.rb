class MembershipPolicy < ApplicationPolicy
  def new?
    membership&.admin?
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
    membership&.admin? || record.user == user
  end

  private

  def membership
    record.organization.memberships.find_by(user:)
  end
end
