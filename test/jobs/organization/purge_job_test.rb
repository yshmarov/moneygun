# frozen_string_literal: true

require "test_helper"

class Organization::PurgeJobTest < ActiveSupport::TestCase
  test "hard deletes organizations after the recovery window" do
    organization = organizations(:one)
    organization.update!(deleted_at: 31.days.ago)

    assert_difference("Organization.count", -1) { Organization::PurgeJob.perform_now }
  end

  test "keeps recently deleted organizations" do
    organization = organizations(:one)
    organization.update!(deleted_at: 1.day.ago)

    assert_no_difference("Organization.count") { Organization::PurgeJob.perform_now }
    assert Organization.exists?(organization.id)
  end
end
