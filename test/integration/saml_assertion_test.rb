# frozen_string_literal: true

require "test_helper"

# The SP-initiated round trip against a real IdP: Saml::MockIdp mints genuinely
# signed assertions, so ruby-saml's validation actually runs. The controller
# test next door stubs OmniAuth out entirely and so proves nothing about the
# protocol — this is where signature, audience, conditions, destination, and
# InResponseTo handling are pinned down.
class SamlAssertionTest < ActionDispatch::IntegrationTest
  IDP_ENTITY_ID = "https://idp.example.com/entity"
  ACS_URL = "http://www.example.com/auth/saml/callback"
  SP_ENTITY_ID = "http://www.example.com/auth/saml/metadata"

  setup do
    @idp = Saml::MockIdp.new(entity_id: IDP_ENTITY_ID, sso_url: "https://idp.example.com/sso")
    @organization = organizations(:one)
    @connection = create_sso_connection(@organization,
                                        enabled: true,
                                        domains: ["acme.com"],
                                        idp_entity_id: IDP_ENTITY_ID,
                                        idp_sso_url: "https://idp.example.com/sso",
                                        idp_cert: @idp.certificate_pem)
    @member = User.create!(email: "alice@acme.com", name: "Alice", email_verified_at: Time.current,
                           onboarding_completed_at: Time.current)
    accept_agreement("user_terms", subject: @member)
    @organization.memberships.create!(user: @member, role: :member)
  end

  test "a correctly signed assertion signs the member in" do
    assert_difference -> { @member.sessions.count } => 1 do
      post_assertion
    end

    assert_redirected_to organizations_path
  end

  test "the signed assertion is what carries the identity, not the attribute we read" do
    # Rewriting the email after signing must break the digest rather than
    # quietly sign in someone else.
    assert_no_difference -> { Session.count } do
      post_assertion(tamper: ->(xml) { xml.sub("alice@acme.com", "attacker@acme.com") })
    end

    assert_rejected_by_validation
  end

  # Rotation is the common enterprise SSO support ticket: the IdP issues a new
  # signing certificate with an overlap window, and both have to work through it.
  test "during a rotation an assertion signed by either certificate is accepted" do
    rotated = Saml::MockIdp.generate_keypair
    @connection.update!(idp_cert: [@idp.certificate_pem, rotated.last.to_pem].join)

    assert_difference -> { @member.sessions.count } => 1 do
      post_assertion(signing_keypair: rotated)
    end

    assert_redirected_to organizations_path

    assert_difference -> { @member.sessions.count } => 1 do
      post_assertion
    end

    assert_redirected_to organizations_path
  end

  test "a third key is still refused while two certificates are configured" do
    rotated = Saml::MockIdp.generate_keypair
    @connection.update!(idp_cert: [@idp.certificate_pem, rotated.last.to_pem].join)

    assert_no_difference -> { Session.count } do
      post_assertion(signing_keypair: Saml::MockIdp.generate_keypair)
    end

    assert_rejected_by_validation
  end

  test "an assertion signed by a key we do not trust is refused" do
    foreign = Saml::MockIdp.generate_keypair

    assert_no_difference -> { Session.count } do
      post_assertion(signing_keypair: foreign)
    end

    assert_rejected_by_validation
  end

  test "signing only the response envelope is refused" do
    # want_assertions_signed: an envelope signature leaves the assertion itself
    # swappable, which is the classic signature-wrapping opening.
    assert_no_difference -> { Session.count } do
      post_assertion(sign_assertion: false, sign_response: true)
    end

    assert_rejected_by_validation
  end

  test "an unsigned assertion is refused" do
    assert_no_difference -> { Session.count } do
      post_assertion(sign_assertion: false)
    end

    assert_rejected_by_validation
  end

  test "an assertion minted for a different service provider is refused" do
    assert_no_difference -> { Session.count } do
      post_assertion(audience: "https://someone-else.example/metadata")
    end

    assert_rejected_by_validation
  end

  test "an expired assertion is refused" do
    assert_no_difference -> { Session.count } do
      post_assertion(not_before: 20.minutes.ago, not_on_or_after: 10.minutes.ago)
    end

    assert_rejected_by_validation
  end

  test "an assertion that is not valid yet is refused" do
    assert_no_difference -> { Session.count } do
      post_assertion(not_before: 10.minutes.from_now, not_on_or_after: 20.minutes.from_now)
    end

    assert_rejected_by_validation
  end

  test "an assertion answering a different AuthnRequest is refused" do
    assert_no_difference -> { Session.count } do
      post_assertion(in_response_to: "_someone-elses-request")
    end

    assert_rejected_by_validation
  end

  test "an unsolicited IdP-initiated assertion is refused" do
    # No InResponseTo at all: we support SP-initiated login only.
    assert_no_difference -> { Session.count } do
      post_assertion(in_response_to: nil, subject_in_response_to: nil)
    end

    assert_rejected_by_validation
  end

  test "an assertion addressed to a different destination is refused" do
    assert_no_difference -> { Session.count } do
      post_assertion(destination: "https://evil.example/auth/saml/callback")
    end

    assert_rejected_by_validation
  end

  test "an assertion from an issuer other than the configured IdP is refused" do
    assert_no_difference -> { Session.count } do
      post_assertion(issuer: "https://evil.example/entity", assertion_issuer: "https://evil.example/entity")
    end

    assert_rejected_by_validation
  end

  test "a non-success status is refused" do
    assert_no_difference -> { Session.count } do
      post_assertion(status: "urn:oasis:names:tc:SAML:2.0:status:AuthnFailed")
    end

    assert_rejected_by_validation
  end

  test "an assertion for an email outside the connection's domains is refused" do
    @connection.update!(jit_provisioning: true)

    assert_no_difference ["User.count", "Session.count"] do
      post_assertion(email: "attacker@evil.test")
    end

    assert_denied_by_app
  end

  test "a consumed response cannot be replayed, even with the flow cookie restored" do
    begin_sso
    flow_cookie = cookies[SamlFlowCookie::NAME]
    encoded = sign_in_response(email: "alice@acme.com")
    post "/auth/saml/callback", params: { SAMLResponse: encoded }

    assert_redirected_to organizations_path

    sign_out
    cookies[SamlFlowCookie::NAME] = flow_cookie
    last_login = @connection.reload.last_login_at

    assert_no_difference [-> { Session.count }, -> { AuditLog.where(action: "user.signed_in_via_sso").count }] do
      post "/auth/saml/callback", params: { SAMLResponse: encoded }
    end

    assert_rejected_by_validation
    assert_equal last_login, @connection.reload.last_login_at
  end

  private

  # Drives discovery and the real OmniAuth request phase, then posts back what
  # the IdP would have posted. Returns the encoded response for reuse.
  def begin_sso(email: "alice@acme.com")
    post sso_path, params: { email_address: email }
    post "/auth/saml"

    @request_id = authn_request_id(response.location)
  end

  # discovery_email picks the tenant; email is what the IdP then asserts. They
  # differ only when the point of the test is an IdP asserting someone else.
  def post_assertion(email: "alice@acme.com", discovery_email: "alice@acme.com", tamper: nil, **)
    begin_sso(email: discovery_email)
    encoded = sign_in_response(email: email, **)
    encoded = Base64.strict_encode64(tamper.call(Base64.decode64(encoded))) if tamper
    post "/auth/saml/callback", params: { SAMLResponse: encoded }
    encoded
  end

  def sign_in_response(email:, **)
    @idp.sign_in(email: email, name: "Alice", acs_url: ACS_URL, sp_entity_id: SP_ENTITY_ID,
                 in_response_to: @request_id, **)
  end

  def authn_request_id(location)
    encoded = Rack::Utils.parse_query(URI.parse(location).query)["SAMLRequest"]

    Saml::MockIdp.parse_authn_request(encoded).fetch(:id)
  end

  # The assertion never survived validation: OmniAuth failed the strategy and
  # our callback was never reached.
  def assert_rejected_by_validation
    assert_equal new_sso_path, settle_redirects
    assert_equal I18n.t("sessions.sso.failed"), flash[:alert]
  end

  # Validation passed, but the identity it asserted isn't one we will sign in.
  def assert_denied_by_app
    assert_equal new_sso_path, settle_redirects
    assert_equal I18n.t("sessions.sso.denied"), flash[:alert]
  end

  def settle_redirects
    follow_redirect! while response.redirect?

    path
  end
end
