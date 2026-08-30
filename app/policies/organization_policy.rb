# frozen_string_literal: true

class OrganizationPolicy < ApplicationPolicy
  def show?
    membership&.active? && membership.organization_id == record.id
  end

  def edit?
    show? && membership.admin?
  end

  def update?
    edit?
  end

  def destroy?
    show? && record.owner_id == membership.user_id
  end

  private

  def membership
    user
  end
end
