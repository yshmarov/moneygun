class ProjectPolicy < Organization::BasePolicy
  def index?
    true
  end

  def show?
    true
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
