# frozen_string_literal: true

require "test_helper"

class OrganizationAuditTest < ActiveSupport::TestCase
  test "records organization settings after commit" do
    organization = organizations(:one)
    Current.membership = memberships(:one)

    organization.update!(name: "Renamed", website: "https://renamed.example", admin_granted_access: true)

    log = organization.audit_logs.find_by!(action: "organization.updated")
    assert_equal memberships(:one), log.actor
    assert_equal [organization.website_before_last_save, "https://renamed.example"], log.metadata.dig("changes", "website")
    assert_equal [false, true], log.metadata.dig("changes", "admin_granted_access")
  ensure
    Current.reset
  end
end
