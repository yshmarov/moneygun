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
    return true if membership&.admin?  # Admins can remove anyone
    return true if membership&.member? && record.user_id == membership.user_id  # Members can remove themselves
    false
  end

  private

  def membership
    user # Because we're passing the current_membership as the pundit user
  end
end
