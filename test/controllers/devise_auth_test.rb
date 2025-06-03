require "test_helper"

class DeviseAuthTest < ActionDispatch::IntegrationTest
  test "user can login" do
    get organizations_path
    assert_response :redirect
    assert_redirected_to new_user_session_path

    user = users(:one)
    sign_in user
    if Rails.application.config_for(:settings).dig(:only_personal_accounts)
      get organizations_path
      assert_response :redirect
      assert_redirected_to organization_dashboard_path(user.default_organization)
    else
      get organizations_path
      assert_response :success
    end
  end
end
