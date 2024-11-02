class InboxPolicy < ApplicationPolicy
  attr_reader :membership, :record

  def initialize(membership, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless membership

    @membership = membership
    @record = record
  end

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
