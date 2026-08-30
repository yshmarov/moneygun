# frozen_string_literal: true

require "test_helper"

class AuditLogTest < ActiveSupport::TestCase
  test "records extensible namespaced actions with actor and request snapshots" do
    membership = memberships(:one)
    Current.request_context = { request_id: "request-1", ip_address: "127.0.0.1", user_agent: "test" }

    log = AuditLog.log!(organization: membership.organization, actor: membership,
                        action: "project.archived", actor_kind: "member", mini_app: "projects")

    assert_equal "project.archived", log.action
    assert_equal membership.user.email, log.metadata["actor_email"]
    assert_equal "request-1", log.metadata.dig("request", "request_id")
  end

  test "rejects unnamespaced and malformed actions" do
    log = AuditLog.new(organization: organizations(:one), action: "bad action", actor_kind: "system")
    assert_not log.valid?
  end

  test "is append-only through models and direct SQL updates" do
    log = AuditLog.log!(organization: organizations(:one), action: "organization.updated", actor_kind: "system")

    assert_raises(ActiveRecord::ReadOnlyRecord) { log.update!(action: "organization.deleted") }
    assert_raises(ActiveRecord::StatementInvalid) do
      AuditLog.where(id: log.id).update_all(action: "organization.deleted") # rubocop:disable Rails/SkipsModelValidations
    end
  end

  test "membership removal nullifies the actor while preserving its snapshot" do
    membership = organizations(:one).memberships.create!(user: users(:unassociated))
    log = AuditLog.log!(organization: membership.organization, actor: membership, action: "project.archived", actor_kind: "member")

    membership.destroy!

    assert_nil log.reload.actor
    assert_equal users(:unassociated).email, log.metadata["actor_email"]
  end
end
