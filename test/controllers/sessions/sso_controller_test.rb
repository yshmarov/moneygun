# frozen_string_literal: true

require "test_helper"

class Sessions::SsoControllerTest < ActionDispatch::IntegrationTest
  test "unknown domains fail without revealing a tenant" do
    post sso_path, params: { email_address: "person@unknown.example" }
    assert_redirected_to new_sso_path(email_address: "person@unknown.example")
  end

  test "verified domains begin a tenant-bound SAML flow" do
    connection = organizations(:one).create_sso_connection!
    connection.sso_domains.create!(domain: "acme.example", verified_at: Time.current)
    connection.update_column(:enabled, true) # rubocop:disable Rails/SkipsModelValidations

    post sso_path, params: { email_address: "person@acme.example" }

    assert_redirected_to sso_path
    assert_predicate cookies["saml_flow"], :present?
  end

  test "the handoff policy allows only the selected identity provider" do
    create_sso_connection(
      organizations(:one),
      domains: ["acme.example"],
      enabled: true,
      idp_entity_id: "https://idp.example/entity",
      idp_sso_url: "https://idp.example/sso",
      idp_cert: SamlTestCertificate.pem
    )

    post sso_path, params: { email_address: "person@acme.example" }
    follow_redirect!

    form_action = response.headers["Content-Security-Policy"].to_s.split(";").find { |directive| directive.include?("form-action") }
    assert_includes form_action, "https://idp.example/sso"
    assert_not_includes form_action, "https://untrusted.example"
  end
end
