# frozen_string_literal: true

class InvitationPolicy < ApplicationPolicy
  def create?
    membership&.admin?
  end

  def destroy?
    membership&.admin?
  end

  def show?
    invitee? && !record.expired?
  end

  def accept?
    show?
  end

  def decline?
    show?
  end

  private

  def membership
    user if user.is_a?(Membership)
  end

  def invitee?
    user.is_a?(User) && record.email.casecmp(user.email).zero?
  end
end
