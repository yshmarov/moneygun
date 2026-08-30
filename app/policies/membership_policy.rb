# frozen_string_literal: true

class MembershipPolicy < ApplicationPolicy
  def index?
    membership.present?
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
    membership&.admin? && !record.owner?
  end

  def reactivate?
    membership&.admin? && record.deactivated? && !record.user.redacted?
  end

  def destroy?
    return false unless membership
    return false if record.owner?
    return true if record.user_id == membership.user_id

    membership.admin? && record.active?
  end

  private

  def membership
    user # Because we're passing the current_membership as the pundit user
  end
end
