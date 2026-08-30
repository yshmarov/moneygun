# frozen_string_literal: true

require "test_helper"

class Organizations::SsoConnectionsControllerTest < ActionDispatch::IntegrationTest
  test "admin can save a draft after recent authentication" do
    user = users(:one)
    sign_in user
    authenticate_sudo(user)

    assert_difference "SsoConnection.count", 1 do
      post organization_sso_connection_path(organizations(:one)), params: { sso_connection: { idp_entity_id: "draft" } }
    end
  end
end
