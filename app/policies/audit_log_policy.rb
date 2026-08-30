# frozen_string_literal: true

class AuditLogPolicy < Organization::BasePolicy
  def index?
    membership.admin? || membership.viewer?
  end
end
