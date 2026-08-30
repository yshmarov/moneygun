# frozen_string_literal: true

require "test_helper"

class Avo::SsoConnectionsTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
    @connection = create_sso_connection(
      organizations(:one),
      enabled: true,
      idp_entity_id: "https://idp.example.com/entity",
      idp_sso_url: "https://idp.example.com/sso",
      idp_cert: SamlTestCertificate.pem
    )
  end

  test "index" do
    get "/admin/avo/resources/sso_connections"

    assert_response :success
  end

  test "show" do
    get "/admin/avo/resources/sso_connections/#{@connection.id}"

    assert_response :success
  end
end
