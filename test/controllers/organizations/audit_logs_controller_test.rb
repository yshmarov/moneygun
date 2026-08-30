# frozen_string_literal: true

require "test_helper"

class Organizations::AuditLogsControllerTest < ActionDispatch::IntegrationTest
  test "admin sees only the current organization's events" do
    sign_in users(:one)
    own = AuditLog.log!(organization: organizations(:one), action: "organization.updated", actor_kind: "system")
    AuditLog.log!(organization: organizations(:two), action: "project.deleted", actor_kind: "system")

    get organization_audit_logs_path(organizations(:one))

    assert_response :success
    assert_includes response.body, own.action
    assert_not_includes response.body, "project.deleted"
  end
end
