class InboxPolicy < ApplicationPolicy
  def index?
    new?
  end

  def show?
    new?
  end

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
    new?
  end

  private

  def membership
    return record if record.is_a?(Membership)

    organization = record.organization
    organization.memberships.find_by(user:)
  end
end
