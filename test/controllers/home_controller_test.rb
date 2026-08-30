# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "redirects a visitor to the main-domain website" do
    get root_url

    assert_redirected_to "https://example.com"
  end

  test "redirects an authenticated user into the application" do
    sign_in users(:one)

    get root_url

    assert_redirected_to organizations_path
  end
end
