# frozen_string_literal: true

require "test_helper"

class VirusScanJobTest < ActiveSupport::TestCase
  test "marks clean files in blob metadata" do
    blob = ActiveStorage::Blob.create_and_upload!(io: file_fixture("avo-logo.png").open, filename: "test.png", content_type: "image/png")
    AntivirusScanner.client = AntivirusScanner::Fake.new(status: :clean)

    VirusScanJob.perform_now(blob)

    assert_equal "clean", blob.reload.metadata["virus_scan_status"]
  ensure
    AntivirusScanner.client = AntivirusScanner::ClamAv.new
  end

  test "purges infected attachments" do
    project = projects(:one)
    project.document.attach(io: file_fixture("avo-logo.png").open, filename: "test.png", content_type: "image/png")
    AntivirusScanner.client = AntivirusScanner::Fake.new(status: :infected)

    VirusScanJob.perform_now(project.document.blob)

    assert_not project.reload.document.attached?
  ensure
    AntivirusScanner.client = AntivirusScanner::ClamAv.new
  end
end
