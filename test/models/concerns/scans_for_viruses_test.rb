# frozen_string_literal: true

require "test_helper"

class ScansForVirusesTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "marks each configured attachment pending and enqueues scanning once" do
    project = projects(:one)
    project.document.attach(io: file_fixture("avo-logo.png").open, filename: "document.png", content_type: "image/png")

    assert_equal "pending", project.document.blob.reload.metadata["virus_scan_status"]
    assert_enqueued_jobs 1, only: VirusScanJob

    assert_no_enqueued_jobs(only: VirusScanJob) { project.update!(name: "Renamed project") }
  end

  test "supports multiple attachments" do
    project = projects(:one)

    assert_enqueued_with(job: VirusScanJob) do
      project.attachments.attach(io: file_fixture("avo-logo.png").open, filename: "attachment.png", content_type: "image/png")
    end

    assert_equal "pending", project.attachments.first.blob.reload.metadata["virus_scan_status"]
  end
end
