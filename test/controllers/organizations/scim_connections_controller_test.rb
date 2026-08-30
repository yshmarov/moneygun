# frozen_string_literal: true

require "test_helper"

class Organizations::ScimConnectionsControllerTest < ActionDispatch::IntegrationTest
  test "admin generates a one-time token after recent authentication" do
    user = users(:one)
    sign_in user
    authenticate_sudo(user)

    assert_difference "ScimConnection.count", 1 do
      post organization_scim_connection_path(organizations(:one))
    end

    assert_predicate flash[:generated_token], :present?
  end
end
