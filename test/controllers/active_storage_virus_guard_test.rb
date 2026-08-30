# frozen_string_literal: true

require "test_helper"

class ActiveStorageVirusGuardTest < ActionDispatch::IntegrationTest
  setup do
    users(:one).avatar.attach(io: file_fixture("avo-logo.png").open, filename: "test.png", content_type: "image/png")
    @blob = users(:one).avatar.blob
  end

  test "blocks pending files and serves clean files" do
    @blob.update!(metadata: @blob.metadata.merge("virus_scan_status" => "pending"))
    get rails_blob_path(@blob, disposition: "attachment")
    assert_response :forbidden

    @blob.update!(metadata: @blob.metadata.merge("virus_scan_status" => "clean"))
    get rails_blob_path(@blob, disposition: "attachment")
    assert_response :redirect
  end

  test "blocks images flagged as unsafe" do
    @blob.update!(metadata: @blob.metadata.merge("virus_scan_status" => "clean", "safe" => false))
    get rails_blob_path(@blob, disposition: "attachment")
    assert_response :forbidden
  end
end
