# frozen_string_literal: true

require "test_helper"

class AvoAuthTest < ActionDispatch::IntegrationTest
  test "admin user can access avo" do
    user = users(:one)
    sign_in user
    get Avo.configuration.root_path
    assert_redirected_to "/admin/avo/resources/users"
    follow_redirect!
    assert_response :success
  end

  test "non-admin user cannot access avo" do
    user = users(:two)
    sign_in user
    get Avo.configuration.root_path
    assert_response :not_found
  end
end
