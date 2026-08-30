# frozen_string_literal: true

class Organizations::AuditLogsController < Organizations::BaseController
  def index
    authorize AuditLog
    @pagy, @audit_logs = pagy(@organization.audit_logs.includes(:actor, :subject).recent)
    AuditLog.preload_actor_users(@audit_logs)
  end
end
