# frozen_string_literal: true

class Organization::BasePolicy
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

  def create?
    membership.admin?
  end

  def new?
    create?
  end

  def update?
    membership.admin?
  end

  def edit?
    update?
  end

  def destroy?
    membership.admin?
  end

  class Scope
    def initialize(membership, scope)
      raise Pundit::NotAuthorizedError, "must be logged in" unless membership

      @membership = membership
      @scope = scope
    end

    def resolve
      scope.all
    end

    private

    attr_reader :membership, :scope
  end
end
