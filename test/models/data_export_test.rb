# frozen_string_literal: true

require "test_helper"

class DataExportTest < ActiveSupport::TestCase
  test "generates a downloadable ZIP with generic organization data" do
    export = DataExport.create!(organization: organizations(:one), membership: memberships(:one))

    DataExport::GenerateJob.perform_now(export)

    assert_predicate export.reload, :downloadable?
    Zip::File.open_buffer(export.file.download) do |zip|
      assert_includes zip.entries.map(&:name), "organization.json"
      assert_includes zip.entries.map(&:name), "memberships.json"
      assert_includes zip.entries.map(&:name), "projects.json"
    end
  end

  test "rejects a membership from another organization" do
    export = DataExport.new(organization: organizations(:one), membership: memberships(:two))
    assert_not export.valid?
  end
end
