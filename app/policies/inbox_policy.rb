class InboxPolicy < ApplicationPolicy
  def index?
    new?
  end

  def show?
    new?
  end

  def new?
    valid_membership&.admin?
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

  def valid_membership
    membership = user
    record.organization.memberships.find_by_id(membership.id)
  end
end
