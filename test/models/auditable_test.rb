# frozen_string_literal: true

require "test_helper"

class AuditableOrganizationRecord < ApplicationRecord
  self.table_name = "organizations"

  include Auditable

  audit_changes :name,
                action: "organization.updated",
                mini_app: "organization",
                organization: -> { Organization.find(id) }
end

class AuditableTest < ActiveSupport::TestCase
  test "records selected committed changes" do
    record = AuditableOrganizationRecord.find(organizations(:one).id)
    previous_name = record.name

    record.update!(name: "Changed")

    log = AuditLog.where(action: "organization.updated").order(:id).last
    assert_equal record, log.subject
    assert_equal organizations(:one), log.organization
    assert_equal [previous_name, "Changed"], log.metadata.dig("changes", "name")
  end

  test "ignores undeclared changes" do
    record = AuditableOrganizationRecord.find(organizations(:one).id)

    assert_no_difference -> { AuditLog.where(action: "organization.updated").count } do
      record.update!(updated_at: 1.minute.from_now)
    end
  end
end
