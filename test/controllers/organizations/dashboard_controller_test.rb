require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in users(:one)
    get organization_dashboard_url(organizations(:one))
    assert_response :success
  end
end
