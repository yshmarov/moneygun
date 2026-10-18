# frozen_string_literal: true

require "test_helper"

class VirusScanSweepJobTest < ActiveJob::TestCase
  test "queues a scan that was never enqueued" do
    project = projects(:one)
    project.document.attach(io: file_fixture("avo-logo.png").open, filename: "document.png", content_type: "image/png")
    blob = project.document.blob
    blob.update!(created_at: VirusScanSweepJob::GRACE_PERIOD.ago - 1.minute, metadata: blob.metadata.except("virus_scan_status"))
    clear_enqueued_jobs

    assert_enqueued_with(job: VirusScanJob, args: [blob]) do
      VirusScanSweepJob.perform_now
    end

    assert_equal "pending", blob.reload.metadata["virus_scan_status"]
  end
end
