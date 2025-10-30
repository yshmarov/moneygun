# frozen_string_literal: true

class ProjectPolicy < Organization::BasePolicy
  def index?
    membership.admin?
  end

  def show?
    membership.admin?
  end

  def new?
    create?
  end

  def create?
    membership.admin?
  end

  def edit?
    update?
  end

  def update?
    membership.admin?
  end

  def destroy?
    membership.admin?
  end
end
