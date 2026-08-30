# frozen_string_literal: true

require "test_helper"

class FileMetadataStripperTest < ActiveSupport::TestCase
  test "rewrites an image without changing its dimensions" do
    image = Vips::Image.black(50, 40)
    tempfile = Tempfile.new(["image", ".png"])
    image.write_to_file(tempfile.path)

    FileMetadataStripper.strip!(tempfile.path, "image/png")

    stripped = Vips::Image.new_from_file(tempfile.path)
    assert_equal [50, 40], [stripped.width, stripped.height]
  ensure
    tempfile&.close!
  end

  test "rejects oversized images before rewriting" do
    image = stub(width: ActiveStorageSafety::MAX_IMAGE_DIMENSION + 1, height: 1)
    image.expects(:write_to_file).never
    Vips::Image.stubs(:new_from_file).returns(image)

    assert_raises(FileMetadataStripper::Error) do
      FileMetadataStripper.strip!("/tmp/oversized.jpg", "image/jpeg")
    end
  end

  test "bounds metadata processor execution time" do
    error = assert_raises(FileMetadataStripper::Error) do
      FileMetadataStripper.run_command(RbConfig.ruby, "-e", "sleep 1", timeout: 0.01)
    end

    assert_equal "File metadata processor timed out", error.message
  end
end
