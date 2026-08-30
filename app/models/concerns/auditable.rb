# frozen_string_literal: true

module Auditable
  extend ActiveSupport::Concern

  class_methods do
    def audit_changes(*fields, action:, mini_app:, organization: :organization, subject: :itself,
                      actor: -> { Current.membership },
                      actor_kind: -> { Current.audit_actor_kind })
      fields = fields.map(&:to_s).freeze

      after_update_commit do
        changes = saved_changes.slice(*fields)
        next if changes.empty?

        AuditLog.log!(
          organization: resolve_audit_value(organization),
          mini_app: mini_app,
          subject: resolve_audit_value(subject),
          actor: resolve_audit_value(actor),
          action: action,
          actor_kind: resolve_audit_value(actor_kind),
          metadata: { changes: changes }
        )
      end
    end
  end

  private

  def resolve_audit_value(value)
    case value
    when :itself then self
    when Symbol then public_send(value)
    when Proc then instance_exec(&value)
    else value
    end
  end
end
