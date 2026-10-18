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
    assert ActiveStorage::Blob.order(:id).last.metadata[ActiveStorage::DirectUploadAuthorization::OWNER_KEY]
  end

  test "a direct upload belongs only to the session that created it" do
    sign_in users(:one)
    post rails_direct_uploads_path, params: direct_upload_params, as: :json
    blob = ActiveStorage::Blob.order(:id).last
    blob.service.upload(blob.key, file_fixture("avo-logo.png").open, checksum: blob.checksum)
    patch user_url, params: { user: { avatar: blob.signed_id } }

    assert_equal blob, users(:one).reload.avatar.blob

    sign_in users(:two)
    patch user_url, params: { user: { avatar: blob.signed_id } }

    assert_not users(:two).reload.avatar.attached?
  end

  private

  def direct_upload_params
    {
      blob: {
        filename: "upload.png",
        byte_size: file_fixture("avo-logo.png").size,
        checksum: Base64.strict_encode64(Digest::MD5.file(file_fixture("avo-logo.png")).digest),
        content_type: "image/png"
      }
    }
  end
end
