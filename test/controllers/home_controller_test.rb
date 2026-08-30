# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "redirects a visitor to sign in" do
    get root_url

    assert_redirected_to new_session_path
  end

  test "redirects an authenticated user into the application" do
    sign_in users(:one)

    get root_url

    assert_redirected_to organizations_path
  end
end
