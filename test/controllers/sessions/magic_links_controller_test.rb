# frozen_string_literal: true

require "test_helper"

class Sessions::MagicLinksControllerTest < ActionDispatch::IntegrationTest
  test "valid pending code verifies email and creates a session" do
    user = users(:unassociated)
    magic_link = user.magic_links.create!
    verifier = Rails.application.message_verifier(:pending_authentication)
    cookies[:pending_authentication_token] = encrypt_cookie_value(:pending_authentication_token, verifier.generate(user.email, expires_at: magic_link.expires_at))

    assert_difference "Session.count", 1 do
      post session_magic_link_path, params: { code: magic_link.code }
    end

    assert_predicate user.reload, :email_verified?
    assert_predicate cookies[:session_token], :present?
    assert_equal user.email, decrypt_cookie_value(:remembered_email, cookies[:remembered_email])
    assert_not MagicLink.exists?(magic_link.id)
  end

  test "code for a different email is not consumed" do
    expected_user = users(:unassociated)
    other_link = users(:two).magic_links.create!
    verifier = Rails.application.message_verifier(:pending_authentication)
    cookies[:pending_authentication_token] = encrypt_cookie_value(:pending_authentication_token, verifier.generate(expected_user.email, expires_at: 15.minutes.from_now))

    post session_magic_link_path, params: { code: other_link.code }

    assert_redirected_to session_magic_link_path
    assert MagicLink.exists?(other_link.id)
  end

  test "code attempts are rate limited per target account" do
    user = users(:unassociated)
    magic_link = user.magic_links.create!
    verifier = Rails.application.message_verifier(:pending_authentication)
    cookies[:pending_authentication_token] = encrypt_cookie_value(:pending_authentication_token, verifier.generate(user.email, expires_at: magic_link.expires_at))
    counts = 1.upto(11).flat_map { |count| [count, count] }
    Sessions::MagicLinksController.cache_store.stubs(:increment).returns(*counts)

    10.times { post session_magic_link_path, params: { code: "000000" } }
    post session_magic_link_path, params: { code: "000000" }

    assert_redirected_to session_magic_link_path
    assert_equal I18n.t("sessions.magic_links.rate_limited"), flash[:alert]
    assert_predicate cookies[:session_token], :blank?
  end
end
