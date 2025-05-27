# test/controllers/omniauth_login_controller_test.rb
require "test_helper"

class Users::OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  include GoogleOauth2Helper

  test "auth success" do
    assert_not User.pluck(:email).include?(JSON.parse(File.read("test/fixtures/google_oauth2.json"))["info"]["email"])
    login_with_google_oauth2_oauth
    post user_google_oauth2_omniauth_callback_path

    # after first login, we redirect to onboarding
    assert_redirected_to user_onboarding_index_path
    assert_response :found

    assert User.pluck(:email).include?(JSON.parse(File.read("test/fixtures/google_oauth2.json"))["info"]["email"])
    assert_equal controller.current_user, User.last

    # after second login, we redirect to root
    sign_out controller.current_user
    sign_in users(:one)
    login_with_google_oauth2_oauth
    post user_google_oauth2_omniauth_callback_path

    assert_redirected_to organizations_path
    assert_response :found
  end

  test "auth failure" do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
    post user_google_oauth2_omniauth_callback_path

    assert_redirected_to new_user_session_path
    assert_nil controller.current_user
  end
end
