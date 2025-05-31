require "test_helper"

class Users::OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  include GoogleOauth2Helper

  test "oauth success" do
    assert_difference "User.count", 1 do
      login_with_google_oauth2_oauth
    end

    assert_redirected_to organizations_path
    assert_response :found

    sign_out controller.current_user

    assert_no_difference "User.count" do
      login_with_google_oauth2_oauth
    end
  end
end
