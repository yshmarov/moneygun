# frozen_string_literal: true

require "test_helper"

class MaintenanceJobTest < ActiveJob::TestCase
  test "removes expired authentication state" do
    session = users(:one).sessions.create!(user_agent: "old", ip_address: "127.0.0.1", last_seen_at: 15.days.ago)
    magic_link = users(:one).magic_links.create!(expires_at: 1.minute.ago)
    connection = organizations(:one).create_sso_connection!
    request = connection.saml_auth_requests.create!(request_id: "expired", expires_at: 1.minute.ago)

    MaintenanceJob.perform_now

    assert_not Session.exists?(session.id)
    assert_not MagicLink.exists?(magic_link.id)
    assert_not SamlAuthRequest.exists?(request.id)
  end

  test "queues purge for an abandoned direct upload" do
    blob = ActiveStorage::Blob.create_before_direct_upload!(
      filename: "abandoned.txt", byte_size: 1,
      checksum: Base64.strict_encode64(Digest::MD5.digest("x")), content_type: "text/plain"
    )
    blob.update_column(:created_at, 25.hours.ago) # rubocop:disable Rails/SkipsModelValidations

    assert_enqueued_with(job: ActiveStorage::PurgeJob, args: [blob]) do
      MaintenanceJob.perform_now
    end
  end
end
