# frozen_string_literal: true

require "test_helper"

class Organizations::SsoDomainsControllerTest < ActionDispatch::IntegrationTest
  test "admin can claim a domain after recent authentication" do
    organizations(:one).create_sso_connection!
    user = users(:one)
    sign_in user
    authenticate_sudo(user)

    assert_difference -> { organizations(:one).sso_connection.sso_domains.count }, 1 do
      post organization_sso_connection_sso_domains_path(organizations(:one)), params: { sso_domain: { domain: "acme.example" } }
    end
  end
end
