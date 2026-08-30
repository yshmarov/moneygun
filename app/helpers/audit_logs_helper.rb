# frozen_string_literal: true

module AuditLogsHelper
  def audit_log_actor(log)
    if log.actor.is_a?(Membership)
      log.actor.display_name
    elsif log.actor_user
      log.actor_user.name.presence || log.actor_user.display_email
    else
      log.metadata["actor_name"].presence || log.metadata["actor_email"].presence || log.actor_kind.humanize
    end
  end

  def audit_log_details(log)
    case log.action
    when "membership.added", "membership.deactivated", "membership.reactivated", "membership.removed"
      log.metadata["target_user_email"].presence || log.metadata["removed_user_email"].presence
    when "invitation.created", "invitation.accepted", "invitation.declined", "invitation.revoked"
      log.metadata["email"].presence
    else
      audit_log_field_changes(log.metadata["changes"])
    end
  end

  private

  def audit_log_field_changes(changes)
    return if changes.blank?

    changes.map do |field, (previous, current)|
      t(
        "organizations.audit_logs.index.field_change",
        field: t("organizations.audit_logs.fields.#{field}", default: field.to_s.humanize),
        previous: audit_log_value(previous),
        current: audit_log_value(current)
      )
    end.join(", ")
  end

  def audit_log_value(value)
    value.presence || "—"
  end
end
