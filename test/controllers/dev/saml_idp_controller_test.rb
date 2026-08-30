# frozen_string_literal: true

require "test_helper"

# The browser-drivable mock IdP. The point of the test is the whole loop: a
# person clicking through /sso and this IdP ends up signed in, with a real
# signed assertion in between. If that holds, manual QA works too.
class Dev::SamlIdpControllerTest < ActionDispatch::IntegrationTest
  setup do
    # The integration session browses www.example.com, and the flow cookie is
    # scoped to whatever host set it — so the IdP has to live on that host too,
    # or the callback arrives without it.
    @idp_sso_url = dev_saml_sso_url(host: "www.example.com")
    @idp = Saml::MockIdp.new(entity_id: Dev::SamlIdpController::ENTITY_ID, sso_url: @idp_sso_url)
    @organization = organizations(:one)
    create_sso_connection(@organization,
                          enabled: true,
                          jit_provisioning: true,
                          domains: ["acme.com"],
                          idp_entity_id: @idp.entity_id,
                          idp_sso_url: @idp_sso_url,
                          idp_cert: @idp.certificate_pem)
    @member = User.create!(email: "alice@acme.com", name: "Alice", email_verified_at: Time.current,
                           onboarding_completed_at: Time.current)
    accept_agreement("user_terms", subject: @member)
    @organization.memberships.create!(user: @member, role: :member)
  end

  test "the whole round trip signs a member in through the mock IdP" do
    post sso_path, params: { email_address: "alice@acme.com" }
    post "/auth/saml"

    # The service provider redirects to the IdP; follow it as a browser would.
    get response.location

    assert_response :success
    assert_select "form[action=?]", dev_saml_sign_in_path

    post dev_saml_sign_in_path, params: sign_in_params(email: "alice@acme.com", name: "Alice")

    assert_response :success
    assert_select "form[action=?]", "http://www.example.com/auth/saml/callback"

    assert_difference -> { @member.sessions.count } => 1 do
      post "/auth/saml/callback", params: { SAMLResponse: assertion_from_page }
    end

    assert_redirected_to organizations_path
  end

  test "the metadata endpoint serves the IdP's entity id and signing certificate" do
    get dev_saml_metadata_path

    assert_response :success
    assert_equal "application/xml", response.media_type
    assert_includes response.body, Dev::SamlIdpController::ENTITY_ID
    assert_includes response.body, "X509Certificate"
  end

  test "the sign-on page says so when there is no AuthnRequest to answer" do
    get dev_saml_sso_path

    assert_response :success
    assert_select "form[action=?]", dev_saml_sign_in_path, false
  end

  private

  def sign_in_params(email:, name:)
    document = response.parsed_body
    {
      email: email,
      name: name,
      in_response_to: document.at("input[name='in_response_to']")["value"],
      acs_url: document.at("input[name='acs_url']")["value"],
      sp_entity_id: document.at("input[name='sp_entity_id']")["value"]
    }
  end

  def assertion_from_page = response.parsed_body.at("input[name='SAMLResponse']")["value"]
end
