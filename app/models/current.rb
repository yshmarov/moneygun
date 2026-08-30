# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user, :membership, :organizations, :organization, :request_context, :actor_kind,
            :scim_connection, :sso_connection

  def session=(value)
    super
    self.user = value&.user
  end

  def audit_actor_kind
    actor_kind.presence || (membership ? "member" : "system")
  end
end
