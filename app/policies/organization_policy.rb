# frozen_string_literal: true

class OrganizationPolicy < ApplicationPolicy
  def show?
    record.memberships.include?(membership)
  end

  def edit?
    record.memberships.include?(membership) && membership.admin?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  private

  def membership
    user
  end
end
