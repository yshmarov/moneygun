# frozen_string_literal: true

require "test_helper"

class ActiveStorage::Analyzer::SafeImageAnalyzerTest < ActiveSupport::TestCase
  test "flags images beyond the safe processing dimensions" do
    blob = ActiveStorage::Blob.create_and_upload!(io: file_fixture("avo-logo.png").open, filename: "image.png", content_type: "image/png")
    analyzer = ActiveStorage::Analyzer::SafeImageAnalyzer.new(blob)
    analyzer.stubs(:read_image).yields(stub(width: 20_000, height: 20_000))

    assert_equal({ width: 20_000, height: 20_000, safe: false }, analyzer.metadata)
  end
end
