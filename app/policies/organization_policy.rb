class OrganizationPolicy < ApplicationPolicy
  def show?
    record.users.include?(user)
  end

  def edit?
    membership = record.memberships.find_by(user:)
    membership&.admin?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end
end
