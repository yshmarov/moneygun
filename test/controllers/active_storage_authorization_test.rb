# frozen_string_literal: true

require "test_helper"
require "digest/md5"

class ActiveStorageAuthorizationTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @project.document.attach(io: StringIO.new("private"), filename: "private.txt", content_type: "text/plain")
    @blob = @project.document.blob
    ActiveStorageSafety.update_scan_status!(@blob, "clean")
  end

  test "organization member can download a project file" do
    sign_in users(:one)
    get rails_blob_path(@blob, disposition: "attachment")
    assert_response :redirect
  end

  test "unrelated and anonymous visitors cannot download a project file" do
    sign_in users(:unassociated)
    get rails_blob_path(@blob, disposition: "attachment")
    assert_response :forbidden

    sign_out
    get rails_blob_path(@blob, disposition: "attachment")
    assert_response :forbidden
  end

  test "orphan blobs are not downloadable" do
    orphan = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("orphan"), filename: "orphan.txt")
    sign_in users(:one)

    get rails_blob_path(orphan)
    assert_response :forbidden
  end

  test "public avatars remain available without a session" do
    user = users(:one)
    user.avatar.attach(io: file_fixture("superails-logo.png").open, filename: "avatar.png", content_type: "image/png")
    ActiveStorageSafety.update_scan_status!(user.avatar.blob, "clean")

    get rails_blob_path(user.avatar.blob)
    assert_response :redirect
  end

  test "anonymous direct uploads are rejected" do
    assert_no_difference "ActiveStorage::Blob.count" do
      post rails_direct_uploads_path, params: direct_upload_params, as: :json
    end
    assert_response :forbidden
  end

  test "authenticated direct uploads are allowed" do
    sign_in users(:one)
    assert_difference "ActiveStorage::Blob.count", 1 do
      post rails_direct_uploads_path, params: direct_upload_params, as: :json
    end
    assert_response :success
  end

  private

  def direct_upload_params
    {
      blob: {
        filename: "upload.txt",
        byte_size: 1,
        checksum: Base64.strict_encode64(Digest::MD5.digest("x")),
        content_type: "text/plain"
      }
    }
  end
end
