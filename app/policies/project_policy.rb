class ProjectPolicy < Organization::BasePolicy
  def index?
    true
    # membership.admin?
  end

  def show?
    true
    # membership.admin?
  end

  def new?
    create?
  end

  def create?
    true
    # membership.admin?
  end

  def edit?
    update?
  end

  def update?
    true
    # membership.admin?
  end

  def destroy?
    true
    # membership.admin?
  end
end
