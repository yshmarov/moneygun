# frozen_string_literal: true

require "test_helper"

# The IdP returns its assertion as a cross-site POST, and browsers withhold a
# SameSite=Lax cookie from one. SameSite=None needs Secure, which plain http
# can't have — except on localhost, which browsers count as trustworthy. Without
# that exception a real third-party IdP can be driven in development right up to
# the callback, where every attempt fails on a cookie that was never sent.
class SamlFlowCookieTest < ActionDispatch::IntegrationTest
  setup do
    # Test drops a Secure cookie sent over plain http; development writes it
    # anyway, which is why the browser flow works there. Match development, or
    # there is no header here to assert on.
    @always_write_cookie = ActionDispatch::Cookies::CookieJar.always_write_cookie
    ActionDispatch::Cookies::CookieJar.always_write_cookie = true

    @organization = organizations(:one)
    create_sso_connection(@organization, enabled: true,
                                         idp_entity_id: "https://idp.example.com/entity",
                                         idp_sso_url: "https://idp.example.com/sso",
                                         idp_cert: SamlTestCertificate.pem)
  end

  teardown { ActionDispatch::Cookies::CookieJar.always_write_cookie = @always_write_cookie }

  def flow_cookie_header(host)
    host! host
    post sso_path, params: { email_address: "alice@acme.com" }

    Array(response.headers["set-cookie"]).join("\n").lines.find { |line| line.include?(SamlFlowCookie::NAME) }.to_s.downcase
  end

  test "on localhost the flow cookie is sent with a cross-site POST" do
    header = flow_cookie_header("localhost")

    assert_includes header, "samesite=none"
    assert_includes header, "secure"
  end

  test "on a plain-http host that is not localhost it falls back to Lax" do
    header = flow_cookie_header("www.example.com")

    assert_includes header, "samesite=lax"
    assert_not_includes header, "secure"
  end
end
