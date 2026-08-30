# frozen_string_literal: true

require "test_helper"

class Organizations::DataExportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    sign_in users(:one)
  end

  test "admin requests an export" do
    assert_difference "DataExport.count", 1 do
      assert_enqueued_with(job: DataExport::GenerateJob) do
        post organization_data_exports_path(@organization)
      end
    end

    assert_redirected_to organization_data_exports_path(@organization)
  end

  test "admin sees the latest export" do
    DataExport.create!(organization: @organization, membership: memberships(:one))
    get organization_data_exports_path(@organization)
    assert_response :success
  end
end
